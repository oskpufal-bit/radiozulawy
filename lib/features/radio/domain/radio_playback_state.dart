import 'package:flutter/foundation.dart';

/// Playback status of the live radio stream.
///
/// This models a live broadcast, not a seekable audio file: there is no
/// "position"/"duration" concept, only whether we're connected to the
/// current live point of the stream.
enum RadioPlaybackStatus {
  /// Nothing has been requested yet since app start.
  idle,

  /// Initial connection to the stream is in progress.
  loading,

  /// Playback started but the engine is (re)buffering.
  buffering,

  /// Audio is playing.
  playing,

  /// Playback is paused; the session may still be held by the engine.
  paused,

  /// Playback was explicitly stopped by the user.
  stopped,

  /// Playback could not start/continue. See [RadioPlaybackState.errorType]
  /// and [RadioPlaybackState.errorMessage].
  error,
}

/// User-facing categories of what went wrong, used to decide whether a retry
/// is meaningful and to keep [RadioPlaybackState.errorMessage] mapped to a
/// small, known set of causes instead of raw exceptions.
enum RadioPlaybackErrorType {
  /// `RADIO_STREAM_URL` is unset/still a development placeholder.
  notConfigured,

  /// No usable network connection.
  network,

  /// The connection attempt took too long.
  timeout,

  /// The stream source could not be read/decoded.
  source,

  /// Anything that doesn't fit the categories above.
  unknown,
}

/// Snapshot of the live radio playback session. Single source of truth,
/// exposed to the presentation layer via `RadioPlaybackController` — see
/// docs/AUDIO.md.
@immutable
class RadioPlaybackState {
  const RadioPlaybackState({
    this.status = RadioPlaybackStatus.idle,
    this.streamUrl,
    this.errorType,
    this.errorMessage,
  });

  final RadioPlaybackStatus status;

  /// The stream URL this state refers to (from `AppConfig.radioStreamUrl`),
  /// once a connection attempt has been made. Null before the first `play()`.
  final String? streamUrl;

  /// Set only when [status] is [RadioPlaybackStatus.error].
  final RadioPlaybackErrorType? errorType;

  /// User-facing (already localized, non-technical) error description. Set
  /// only when [status] is [RadioPlaybackStatus.error].
  final String? errorMessage;

  bool get isPlaying => status == RadioPlaybackStatus.playing;

  bool get isBuffering =>
      status == RadioPlaybackStatus.loading ||
      status == RadioPlaybackStatus.buffering;

  bool get hasError => status == RadioPlaybackStatus.error;

  /// Whether there is an active/relevant playback session — used to decide
  /// mini-player visibility (see docs/NAVIGATION.md).
  bool get isSessionActive =>
      status == RadioPlaybackStatus.loading ||
      status == RadioPlaybackStatus.buffering ||
      status == RadioPlaybackStatus.playing ||
      status == RadioPlaybackStatus.paused;

  RadioPlaybackState copyWith({
    RadioPlaybackStatus? status,
    String? streamUrl,
    RadioPlaybackErrorType? errorType,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RadioPlaybackState(
      status: status ?? this.status,
      streamUrl: streamUrl ?? this.streamUrl,
      errorType: clearError ? null : (errorType ?? this.errorType),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RadioPlaybackState &&
          other.status == status &&
          other.streamUrl == streamUrl &&
          other.errorType == errorType &&
          other.errorMessage == errorMessage);

  @override
  int get hashCode => Object.hash(status, streamUrl, errorType, errorMessage);

  @override
  String toString() =>
      'RadioPlaybackState(status: $status, streamUrl: $streamUrl, '
      'errorType: $errorType, errorMessage: $errorMessage)';
}
