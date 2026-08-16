import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:radiozulawy/features/radio/data/dev_show_schedule_data.dart';
import 'package:radiozulawy/features/radio/domain/current_show.dart';
import 'package:radiozulawy/features/radio/domain/radio_playback_state.dart';
import 'package:radiozulawy/features/radio/domain/schedule_entry.dart';
import 'package:radiozulawy/features/radio/presentation/radio_home_screen.dart';
import 'package:radiozulawy/features/radio/presentation/radio_providers.dart';

import 'fake_radio_repository.dart';

Future<void> _pumpRadioHomeScreen(
  WidgetTester tester,
  FakeRadioRepository repository, {
  CurrentShow? currentShow = devCurrentShow,
  List<ScheduleEntry> schedule = devSchedulePreview,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RadioHomeScreen()),
      GoRoute(
        path: '/schedule',
        builder: (context, state) =>
            const Scaffold(body: Text('Ramówka strona')),
      ),
    ],
  );

  // Tall enough that every section (hero player, "Co dalej", quick actions)
  // is actually built by the ListView's sliver (off-viewport children in a
  // Sliver-backed ListView aren't part of the Element tree at all, so
  // `find.text` wouldn't see them otherwise) without needing to scroll in
  // each test.
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.physicalSize = const Size(400, 1800);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        radioRepositoryProvider.overrideWithValue(repository),
        currentShowProvider.overrideWithValue(currentShow),
        schedulePreviewProvider.overrideWithValue(schedule),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
}

void main() {
  late FakeRadioRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeRadioRepository();
  });

  tearDown(() => fakeRepository.dispose());

  testWidgets('renders current show metadata', (tester) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(find.text('Radio Żuławy'), findsOneWidget);
    expect(find.text('Dzień dobry Żuławy'), findsOneWidget);
    expect(find.text('Redakcja Radia Żuławy · 08:00–10:00'), findsOneWidget);
  });

  testWidgets('tapping play calls the repository and shows the pause icon', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    expect(fakeRepository.playCalls, 1);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.text('Słuchasz na żywo'), findsOneWidget);
  });

  testWidgets('tapping pause while playing calls the repository', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();

    expect(fakeRepository.pauseCalls, 1);
  });

  testWidgets('reflects buffering state with a spinner and caption', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    fakeRepository.emit(
      const RadioPlaybackState(status: RadioPlaybackStatus.buffering),
    );
    // Two pumps: unlike the idle/playing LiveBadge pulse, nothing is
    // actively ticking while buffering, so the fake broadcast stream's
    // microtask needs an explicit extra frame to be observed here.
    await tester.pump();
    await tester.pump();

    expect(find.text('Buforowanie…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error state renders without crashing and offers retry', (
    tester,
  ) async {
    fakeRepository.dispose();
    fakeRepository = FakeRadioRepository(
      initialState: const RadioPlaybackState(
        status: RadioPlaybackStatus.error,
        errorType: RadioPlaybackErrorType.notConfigured,
        errorMessage: 'Stream radia nie został jeszcze skonfigurowany.',
      ),
    );
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(tester.takeException(), isNull);
    expect(find.text('Nie udało się połączyć'), findsOneWidget);
    expect(
      find.text('Stream radia nie został jeszcze skonfigurowany.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pump();

    expect(fakeRepository.retryCalls, 1);
  });

  testWidgets('missing show metadata falls back to station branding', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository, currentShow: null);

    expect(find.text('Radio Żuławy 106.4 FM'), findsOneWidget);
    expect(find.text('Na żywo'), findsOneWidget);
  });

  testWidgets('renders the "Co dalej" schedule preview', (tester) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(find.text('Co dalej'), findsOneWidget);
    for (final entry in devSchedulePreview) {
      expect(find.text(entry.title), findsOneWidget);
      expect(find.text(entry.time), findsOneWidget);
    }
  });

  testWidgets('an empty schedule preview shows an empty state', (tester) async {
    await _pumpRadioHomeScreen(tester, fakeRepository, schedule: const []);

    expect(find.text('Brak zaplanowanych audycji'), findsOneWidget);
  });

  testWidgets('opening the full schedule navigates to /schedule', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    await tester.tap(find.text('Zobacz pełną ramówkę'));
    await tester.pumpAndSettle();

    expect(find.text('Ramówka strona'), findsOneWidget);
  });

  testWidgets('the "Ramówka" quick action also navigates to /schedule', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Ramówka'));
    await tester.pumpAndSettle();

    expect(find.text('Ramówka strona'), findsOneWidget);
  });

  testWidgets('the main play/pause control exposes accessible semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(
      find.bySemanticsLabel('Odtwarzaj Radio Żuławy na żywo'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    expect(find.bySemanticsLabel('Wstrzymaj Radio Żuławy'), findsOneWidget);

    semantics.dispose();
  });
}