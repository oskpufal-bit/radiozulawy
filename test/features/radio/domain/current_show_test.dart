import 'package:flutter_test/flutter_test.dart';
import 'package:radiozulawy/features/radio/domain/current_show.dart';

void main() {
  test('timeRange formats start/end when both are known', () {
    const show = CurrentShow(
      title: 'Dzień dobry Żuławy',
      hostName: 'Redakcja',
      startTime: '08:00',
      endTime: '10:00',
    );

    expect(show.hasTimeRange, isTrue);
    expect(show.timeRange, '08:00–10:00');
  });

  test('timeRange is null when either bound is missing', () {
    const show = CurrentShow(title: 'Muzyka', hostName: 'Redakcja');

    expect(show.hasTimeRange, isFalse);
    expect(show.timeRange, isNull);
  });

  test('fallback carries station branding, not a real show', () {
    expect(CurrentShow.fallback.title, 'Radio Żuławy 106.4 FM');
    expect(CurrentShow.fallback.hostName, 'Na żywo');
    expect(CurrentShow.fallback.hasTimeRange, isFalse);
  });

  test('equality compares by value', () {
    const a = CurrentShow(
      title: 'Dzień dobry Żuławy',
      hostName: 'Redakcja',
      startTime: '08:00',
      endTime: '10:00',
    );
    const b = CurrentShow(
      title: 'Dzień dobry Żuławy',
      hostName: 'Redakcja',
      startTime: '08:00',
      endTime: '10:00',
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}