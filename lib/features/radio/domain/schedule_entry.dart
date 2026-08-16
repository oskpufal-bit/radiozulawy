import 'package:flutter/foundation.dart';

/// One upcoming item in the "Co dalej" preview. Deliberately minimal — the
/// full schedule domain (recurring slots, days, timezone handling, ...) is a
/// later task once a real schedule source exists. See docs/RADIO_UI.md.
@immutable
class ScheduleEntry {
  const ScheduleEntry({
    required this.time,
    required this.title,
    this.hostName,
  });

  final String time;
  final String title;
  final String? hostName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleEntry &&
          other.time == time &&
          other.title == title &&
          other.hostName == hostName);

  @override
  int get hashCode => Object.hash(time, title, hostName);

  @override
  String toString() =>
      'ScheduleEntry(time: $time, title: $title, hostName: $hostName)';
}