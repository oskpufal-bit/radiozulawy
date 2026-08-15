import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radiozulawy/app/app.dart';
import 'package:radiozulawy/core/providers.dart';

void main() {
  testWidgets('App boots and shows the radio home screen', (tester) async {
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
    // Not pumpAndSettle: the Radio tab's LiveBadge pulses continuously
    // (see docs/DESIGN_SYSTEM.md), so it never "settles".
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The app starts on the Radio tab (see AppRoutes.radio).
    expect(find.text('Radio Żuławy'), findsOneWidget);
  });
}
