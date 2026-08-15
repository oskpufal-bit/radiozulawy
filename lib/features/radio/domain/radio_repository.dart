import 'radio_playback_state.dart';

/// Contract for controlling live radio playback, independent of the concrete
/// audio engine. This is the seam that keeps `RadioPlaybackController` (and
/// its tests) decoupled from `just_audio`/`audio_service` — see
/// docs/AUDIO.md.
abstract class RadioRepository {
  /// Current state, read synchronously (e.g. to seed a controller).
  RadioPlaybackState get currentState;

  /// Broadcast stream of state changes. Implementations must emit
  /// [currentState] on every change (not just push updates going forward).
  Stream<RadioPlaybackState> watchPlaybackState();

  /// Connects to the live stream and starts playback. If a production
  /// `RADIO_STREAM_URL` isn't configured, resolves to a
  /// [RadioPlaybackErrorType.notConfigured] error state instead of
  /// attempting any network request.
  Future<void> play();

  /// Pauses playback. The engine may keep the session held so [play] can
  /// resume quickly; for a live stream, resuming always rejoins at the
  /// current live point rather than seeking backwards.
  Future<void> pause();

  /// Fully stops playback and releases the stream connection.
  Future<void> stop();

  /// Re-attempts a connection after an error, from a clean state.
  Future<void> retry();
}
