import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radiozulawy/app/app.dart';
import 'package:radiozulawy/core/providers.dart';
import 'package:radiozulawy/core/widgets/app_category_chip.dart';

// Not pumpAndSettle anywhere in this file: StatefulShellRoute.indexedStack
// keeps every branch alive (that's how it preserves state), so the Radio
// tab's continuously-pulsing LiveBadge (see docs/DESIGN_SYSTEM.md) is
// always ticking in the background and would make pumpAndSettle hang.
// A couple of bounded pumps is enough to let route/fade transitions finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
}
