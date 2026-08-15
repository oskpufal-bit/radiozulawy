import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiozulawy/features/radio/domain/radio_playback_state.dart';
import 'package:radiozulawy/features/radio/presentation/radio_home_screen.dart';
import 'package:radiozulawy/features/radio/presentation/radio_providers.dart';

import 'fake_radio_repository.dart';

Future<void> _pumpRadioHomeScreen(
  WidgetTester tester,
  FakeRadioRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [radioRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: RadioHomeScreen()),
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

  testWidgets('shows the idle play call-to-action by default', (tester) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    expect(find.text('Słuchaj na żywo'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('tapping play calls the repository and reflects playing state', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    await tester.tap(find.text('Słuchaj na żywo'));
    await tester.pump();

    expect(fakeRepository.playCalls, 1);
    expect(find.text('Pauza'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('reflects buffering state with a loading indicator', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);

    fakeRepository.emit(
      const RadioPlaybackState(status: RadioPlaybackStatus.buffering),
    );
    await tester.pump();

    expect(find.text('Buforowanie...'), findsOneWidget);
  });

  testWidgets('tapping pause while playing calls the repository', (
    tester,
  ) async {
    await _pumpRadioHomeScreen(tester, fakeRepository);
    await tester.tap(find.text('Słuchaj na żywo'));
    await tester.pump();

    await tester.tap(find.text('Pauza'));
    await tester.pump();

    expect(fakeRepository.pauseCalls, 1);
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
}
