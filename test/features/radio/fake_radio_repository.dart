import 'dart:async';

import 'package:radiozulawy/features/radio/domain/radio_playback_state.dart';
import 'package:radiozulawy/features/radio/domain/radio_repository.dart';

/// In-memory [RadioRepository] test double. Lets tests drive
/// `RadioPlaybackController`/UI through every playback state without
/// touching `audio_service`/`just_audio` or the network — see
/// docs/AUDIO.md ("Testability").
///
/// `play`/`pause`/`stop`/`retry` record call counts and apply a small,
/// overridable default transition; tests that need to simulate
/// buffering/errors/reconnects call [emit] directly.
class FakeRadioRepository implements RadioRepository {
  FakeRadioRepository({RadioPlaybackState? initialState})
    : _state = initialState ?? const RadioPlaybackState();

  final StreamController<RadioPlaybackState> _controller =
      StreamController<RadioPlaybackState>.broadcast();

  RadioPlaybackState _state;

  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  int retryCalls = 0;

  /// When set, [play] emits this state instead of the default `playing`
  /// transition — used to simulate a not-configured/network/etc. error.
  RadioPlaybackState? nextPlayResult;

  @override
  RadioPlaybackState get currentState => _state;

  @override
  Stream<RadioPlaybackState> watchPlaybackState() => _controller.stream;

  void emit(RadioPlaybackState state) {
    _state = state;
    _controller.add(state);
  }

  @override
  Future<void> play() async {
    playCalls++;
    emit(
      nextPlayResult ??
          const RadioPlaybackState(status: RadioPlaybackStatus.playing),
    );
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    emit(_state.copyWith(status: RadioPlaybackStatus.paused));
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    emit(const RadioPlaybackState(status: RadioPlaybackStatus.stopped));
  }

  @override
  Future<void> retry() async {
    retryCalls++;
    await play();
  }

  void dispose() => _controller.close();
}
