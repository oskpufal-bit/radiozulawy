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
    await tester.pumpAndSettle();

    // The app's initial route is currently the dev-only Design System
    // Preview (see AppRoutes.devDesignSystem) — this stage is about the
    // design system, not the final navigation shell.
    expect(find.text('Design System'), findsOneWidget);
  });
}
