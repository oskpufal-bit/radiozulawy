import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radiozulawy/app/app.dart';
import 'package:radiozulawy/core/providers.dart';
import 'package:radiozulawy/core/widgets/app_category_chip.dart';
import 'package:radiozulawy/core/widgets/mini_player_shell.dart';
import 'package:radiozulawy/features/radio/domain/radio_playback_state.dart';
import 'package:radiozulawy/features/radio/presentation/radio_providers.dart';

import '../features/radio/fake_radio_repository.dart';

// Not pumpAndSettle anywhere in this file: StatefulShellRoute.indexedStack
// keeps every branch alive (that's how it preserves state), so the Radio
// tab's continuously-pulsing LiveBadge (see docs/DESIGN_SYSTEM.md) is
// always ticking in the background and would make pumpAndSettle hang.
// A couple of bounded pumps is enough to let route/fade transitions finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpApp(
  WidgetTester tester, {
  FakeRadioRepository? radioRepository,
}) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final fakeRadioRepository = radioRepository ?? FakeRadioRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        radioRepositoryProvider.overrideWithValue(fakeRadioRepository),
      ],
      child: const RadioZulawyApp(),
    ),
  );
  await _settle(tester);
}

void main() {
  testWidgets('starts on the Radio tab', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Radio Żuławy'), findsOneWidget);
  });

  testWidgets('tapping Newsy shows NewsPage', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Newsy'));
    await _settle(tester);

    expect(find.text('Aktualności z Żuław'), findsOneWidget);
  });

  testWidgets('tapping the central Zgłoś action shows SubmitPage', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Zgłoś'));
    await _settle(tester);

    expect(find.text('Zgłoś zdarzenie'), findsOneWidget);
  });

  testWidgets('the central Zgłoś action is exposed via semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await _pumpApp(tester);

    expect(find.bySemanticsLabel('Zgłoś zdarzenie'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('tapping Podcasty shows PodcastsPage', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Podcasty'));
    await _settle(tester);

    expect(find.text('Najnowsze odcinki'), findsOneWidget);
  });

  testWidgets('tapping Więcej shows MorePage', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Więcej'));
    await _settle(tester);

    expect(find.text('Ramówka'), findsOneWidget);
    expect(find.text('Ustawienia'), findsOneWidget);
  });

  testWidgets('opening a news article and going back returns to the list', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Newsy'));
    await _settle(tester);

    await tester.tap(find.text('Nowy most na Nogacie oficjalnie otwarty'));
    await _settle(tester);

    expect(find.text('Aktualności z Żuław'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);

    expect(find.text('Aktualności z Żuław'), findsOneWidget);
  });

  testWidgets('branch state (selected filter) survives switching tabs', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Newsy'));
    await _settle(tester);

    await tester.tap(find.text('Powiat nowodworski'));
    await _settle(tester);
    expect(
      tester
          .widget<AppCategoryChip>(
            find.widgetWithText(AppCategoryChip, 'Powiat nowodworski'),
          )
          .selected,
      isTrue,
    );

    await tester.tap(find.text('Radio'));
    await _settle(tester);
    await tester.tap(find.text('Newsy'));
    await _settle(tester);

    expect(
      tester
          .widget<AppCategoryChip>(
            find.widgetWithText(AppCategoryChip, 'Powiat nowodworski'),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('mini-player is hidden while radio is idle', (tester) async {
    await _pumpApp(tester);

    expect(
      find.byKey(const ValueKey('mini-player-slot-hidden')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('mini-player-slot-visible')),
      findsNothing,
    );
  });

  testWidgets(
    'mini-player appears for an active session and survives switching tabs',
    (tester) async {
      final fakeRadioRepository = FakeRadioRepository();
      addTearDown(fakeRadioRepository.dispose);
      await _pumpApp(tester, radioRepository: fakeRadioRepository);

      fakeRadioRepository.emit(
        const RadioPlaybackState(status: RadioPlaybackStatus.playing),
      );
      await _settle(tester);

      expect(
        find.byKey(const ValueKey('mini-player-slot-visible')),
        findsOneWidget,
      );
      expect(find.text('Na żywo'), findsOneWidget);

      await tester.tap(find.text('Newsy'));
      await _settle(tester);

      expect(
        find.byKey(const ValueKey('mini-player-slot-visible')),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping the mini-player play/pause button toggles playback', (
    tester,
  ) async {
    final fakeRadioRepository = FakeRadioRepository();
    addTearDown(fakeRadioRepository.dispose);
    await _pumpApp(tester, radioRepository: fakeRadioRepository);

    fakeRadioRepository.emit(
      const RadioPlaybackState(status: RadioPlaybackStatus.playing),
    );
    await _settle(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(MiniPlayerShell),
        matching: find.byIcon(Icons.pause_rounded),
      ),
    );
    await _settle(tester);

    expect(fakeRadioRepository.pauseCalls, 1);
  });
}
