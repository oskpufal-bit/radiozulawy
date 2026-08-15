import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/radio_playback_state.dart';

/// Bounded backoff schedule for automatic reconnects after a dropped
/// connection. Kept short and finite on purpose — see docs/AUDIO.md
/// ("Reconnect") — the user can always stop playback to cancel it.
const List<Duration> _reconnectDelays = [
  Duration(seconds: 2),
  Duration(seconds: 5),
  Duration(seconds: 10),
];

const String _notConfiguredMessage =
    'Stream radia nie został jeszcze skonfigurowany.';
const String _sourceErrorMessage =
    'Nie udało się połączyć ze strumieniem radia.';
const String _droppedErrorMessage =
    'Połączenie ze strumieniem radia zostało przerwane.';
const String _networkErrorMessage = 'Brak połączenia z internetem.';
const String _timeoutErrorMessage =
    'Przekroczono czas oczekiwania na połączenie ze strumieniem.';
const String _unknownErrorMessage = 'Wystąpił nieoczekiwany błąd odtwarzania.';

/// The single, app-wide audio engine for Radio Żuławy live playback.
///
/// This is the only place `just_audio`'s `AudioPlayer` is created/used —
/// everything else (UI, Riverpod controller) talks to `RadioRepository`
/// instead. Extending `BaseAudioHandler` also wires this into `audio_service`
/// for background playback, the system media notification and lock-screen
/// controls. See docs/AUDIO.md.
///
/// Created exactly once, in app bootstrap (`AudioService.init`), and lives
/// for the app's lifetime — never constructed by widgets/pages.
class RadioAudioHandler extends BaseAudioHandler {
  RadioAudioHandler() : _player = AudioPlayer() {
    _initialize();
  }

  final AudioPlayer _player;
  final StreamController<RadioPlaybackState> _stateController =
      StreamController<RadioPlaybackState>.broadcast();

  RadioPlaybackState _state = const RadioPlaybackState();
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;

  static const MediaItem _liveMediaItem = MediaItem(
    id: AppConfig.radioStreamUrl,
    title: 'Radio Żuławy 106.4 FM',
    artist: 'Na żywo',
    album: 'Radio Żuławy',
    playable: true,
    isLive: true,
  );

  static bool get _isStreamConfigured =>
      AppConfig.radioStreamUrl.isNotEmpty &&
      !AppConfig.radioStreamUrl.contains('.invalid');

  RadioPlaybackState get currentRadioState => _state;

  Stream<RadioPlaybackState> get radioPlaybackState => _stateController.stream;

  void _initialize() {
    mediaItem.add(_liveMediaItem);
    _player.playerStateStream.listen(_handlePlayerState);
    _player.errorStream.listen(_handlePlayerError);
    _broadcastMediaControlState();
  }

  @override
  Future<void> play() async {
    _cancelReconnect();
    if (!_isStreamConfigured) {
      AppLogger.warning(
        'radio playback requested without a configured stream URL',
      );
      _emit(
        const RadioPlaybackState(
          status: RadioPlaybackStatus.error,
          errorType: RadioPlaybackErrorType.notConfigured,
          errorMessage: _notConfiguredMessage,
        ),
      );
      return;
    }

    AppLogger.info('radio playback requested');
    final needsConnect = _state.status != RadioPlaybackStatus.paused;
    try {
      if (needsConnect) {
        _emit(
          const RadioPlaybackState(
            status: RadioPlaybackStatus.loading,
            streamUrl: AppConfig.radioStreamUrl,
          ),
        );
        await _player.setUrl(AppConfig.radioStreamUrl);
      }
      await _player.play();
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  @override
  Future<void> pause() async {
    _cancelReconnect();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _cancelReconnect();
    _reconnectAttempt = 0;
    await _player.stop();
    AppLogger.info('radio playback stopped');
    _emit(const RadioPlaybackState(status: RadioPlaybackStatus.stopped));
  }

  Future<void> retry() async {
    _cancelReconnect();
    _reconnectAttempt = 0;
    await play();
  }

  void _handlePlayerState(PlayerState playerState) {
    switch (playerState.processingState) {
      case ProcessingState.idle:
        break;
      case ProcessingState.loading:
        AppLogger.info('radio buffering');
        _emit(
          _state.copyWith(
            status: RadioPlaybackStatus.loading,
            clearError: true,
          ),
        );
        break;
      case ProcessingState.buffering:
        AppLogger.info('radio buffering');
        _emit(
          _state.copyWith(
            status: RadioPlaybackStatus.buffering,
            clearError: true,
          ),
        );
        break;
      case ProcessingState.ready:
        if (playerState.playing) {
          _reconnectAttempt = 0;
          AppLogger.info('radio playing');
          _emit(
            _state.copyWith(
              status: RadioPlaybackStatus.playing,
              clearError: true,
            ),
          );
        } else if (_state.status == RadioPlaybackStatus.loading ||
            _state.status == RadioPlaybackStatus.buffering ||
            _state.status == RadioPlaybackStatus.playing) {
          AppLogger.info('radio paused');
          _emit(
            _state.copyWith(
              status: RadioPlaybackStatus.paused,
              clearError: true,
            ),
          );
        }
        break;
      case ProcessingState.completed:
        _handleUnexpectedStop();
        break;
    }
  }

  void _handleUnexpectedStop() {
    final wasActive =
        _state.status == RadioPlaybackStatus.playing ||
        _state.status == RadioPlaybackStatus.buffering ||
        _state.status == RadioPlaybackStatus.loading;
    if (!wasActive) return;
    _emitError(RadioPlaybackErrorType.source, _droppedErrorMessage);
    _scheduleReconnect();
  }

  void _handlePlayerError(PlayerException error) {
    _handleError(error, StackTrace.current);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    AppLogger.error('radio playback error', error, stackTrace);
    final wasActive =
        _state.status == RadioPlaybackStatus.playing ||
        _state.status == RadioPlaybackStatus.buffering ||
        _state.status == RadioPlaybackStatus.loading;
    final (type, message) = _mapError(error);
    _emitError(type, message);
    if (wasActive) _scheduleReconnect();
  }

  (RadioPlaybackErrorType, String) _mapError(Object error) {
    if (error is TimeoutException) {
      return (RadioPlaybackErrorType.timeout, _timeoutErrorMessage);
    }
    if (error is SocketException) {
      return (RadioPlaybackErrorType.network, _networkErrorMessage);
    }
    if (error is PlayerException || error is FormatException) {
      return (RadioPlaybackErrorType.source, _sourceErrorMessage);
    }
    return (RadioPlaybackErrorType.unknown, _unknownErrorMessage);
  }

  void _emitError(RadioPlaybackErrorType type, String message) {
    _emit(
      _state.copyWith(
        status: RadioPlaybackStatus.error,
        errorType: type,
        errorMessage: message,
      ),
    );
  }

  void _scheduleReconnect() {
    if (_reconnectAttempt >= _reconnectDelays.length) return;
    final delay = _reconnectDelays[_reconnectAttempt];
    _reconnectAttempt++;
    AppLogger.info(
      'radio reconnect scheduled in ${delay.inSeconds}s (attempt $_reconnectAttempt)',
    );
    _reconnectTimer = Timer(delay, () {
      // The user may have stopped/retried in the meantime — only follow
      // through if we're still sitting in the error state that scheduled
      // this attempt.
      if (_state.status != RadioPlaybackStatus.error) return;
      play();
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _emit(RadioPlaybackState newState) {
    _state = newState;
    _stateController.add(newState);
    _broadcastMediaControlState();
  }

  void _broadcastMediaControlState() {
    final playing = _state.status == RadioPlaybackStatus.playing;
    final processingState = switch (_state.status) {
      RadioPlaybackStatus.idle ||
      RadioPlaybackStatus.stopped => AudioProcessingState.idle,
      RadioPlaybackStatus.loading => AudioProcessingState.loading,
      RadioPlaybackStatus.buffering => AudioProcessingState.buffering,
      RadioPlaybackStatus.playing ||
      RadioPlaybackStatus.paused => AudioProcessingState.ready,
      RadioPlaybackStatus.error => AudioProcessingState.error,
    };
    playbackState.add(
      PlaybackState(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: processingState,
        playing: playing,
        errorMessage: _state.errorMessage,
      ),
    );
  }
}
