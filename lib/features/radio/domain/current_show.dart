import 'package:flutter/foundation.dart';

/// What's currently on air — presentation data about the broadcast, kept
/// deliberately separate from `RadioPlaybackState` (which only describes
/// whether *this device* is connected/playing, not what's being aired).
/// See docs/RADIO_UI.md.
@immutable
class CurrentShow {
  const CurrentShow({
    required this.title,
    required this.hostName,
    this.startTime,
    this.endTime,
    this.artworkUrl,
  });

  final String title;
  final String hostName;

  /// Formatted local time, e.g. "08:00". Null when unknown.
  final String? startTime;
  final String? endTime;

  /// Future network artwork. Null renders the branded fallback artwork —
  /// see `RadioArtwork` in `presentation/widgets/radio_artwork.dart`.
  final String? artworkUrl;

  bool get hasTimeRange => startTime != null && endTime != null;

  String? get timeRange => hasTimeRange ? '$startTime–$endTime' : null;

  /// Shown when show metadata isn't available yet — playback keeps working
  /// regardless, see docs/RADIO_UI.md ("Empty metadata").
  static const CurrentShow fallback = CurrentShow(
    title: 'Radio Żuławy 106.4 FM',
    hostName: 'Na żywo',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrentShow &&
          other.title == title &&
          other.hostName == hostName &&
          other.startTime == startTime &&
          other.endTime == endTime &&
          other.artworkUrl == artworkUrl);

  @override
  int get hashCode =>
      Object.hash(title, hostName, startTime, endTime, artworkUrl);

  @override
  String toString() =>
      'CurrentShow(title: $title, hostName: $hostName, '
      'startTime: $startTime, endTime: $endTime)';
}