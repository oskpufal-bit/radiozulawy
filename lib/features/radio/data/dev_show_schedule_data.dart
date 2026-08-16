import '../domain/current_show.dart';
import '../domain/schedule_entry.dart';

/// DEV_PLACEHOLDER — see docs/DEV_PLACEHOLDERS.md (`CURRENT_SHOW_SOURCE`,
/// `SCHEDULE_SOURCE`): static development data standing in for real ICY/
/// schedule metadata. Consumed only through `currentShowProvider`/
/// `schedulePreviewProvider` in `radio_providers.dart` — that provider layer
/// is the seam a future repository/API implementation swaps in without
/// touching any widget. Not real production data — see docs/RADIO_UI.md.
const CurrentShow devCurrentShow = CurrentShow(
  title: 'Dzień dobry Żuławy',
  hostName: 'Redakcja Radia Żuławy',
  startTime: '08:00',
  endTime: '10:00',
);

const List<ScheduleEntry> devSchedulePreview = [
  ScheduleEntry(time: '10:00', title: 'Wiadomości'),
  ScheduleEntry(time: '10:10', title: 'Gość dnia', hostName: 'Anna Kowalska'),
  ScheduleEntry(time: '11:00', title: 'Muzyka bez granic'),
  ScheduleEntry(time: '12:00', title: 'Serwis regionalny'),
];