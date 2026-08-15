import '../domain/radio_playback_state.dart';
import '../domain/radio_repository.dart';
import 'radio_audio_handler.dart';

/// Thin adapter exposing the app-wide [RadioAudioHandler] as a
/// [RadioRepository], so the presentation layer never touches
/// `audio_service`/`just_audio` types directly. See docs/AUDIO.md.
class AudioServiceRadioRepository implements RadioRepository {
  const AudioServiceRadioRepository(this._handler);

  final RadioAudioHandler _handler;

  @override
  RadioPlaybackState get currentState => _handler.currentRadioState;

  @override
  Stream<RadioPlaybackState> watchPlaybackState() =>
      _handler.radioPlaybackState;

  @override
  Future<void> play() => _handler.play();

  @override
  Future<void> pause() => _handler.pause();

  @override
  Future<void> stop() => _handler.stop();

  @override
  Future<void> retry() => _handler.retry();
}
