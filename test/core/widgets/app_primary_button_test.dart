import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radiozulawy/core/widgets/buttons/app_primary_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'SŁUCHAJ NA ŻYWO',
            onPressed: onPressed,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  testWidgets('renders its label', (tester) async {
    await pumpButton(tester, onPressed: () {});

    expect(find.text('SŁUCHAJ NA ŻYWO'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpButton(tester, onPressed: () => tapped = true);

    await tester.tap(find.byType(AppPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await pumpButton(tester, onPressed: null);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows a spinner and disables tap while loading', (tester) async {
    var tapped = false;
    await pumpButton(tester, onPressed: () => tapped = true, isLoading: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('SŁUCHAJ NA ŻYWO'), findsNothing);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(tapped, isFalse);
  });
}
