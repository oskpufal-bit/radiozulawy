import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radiozulawy/core/widgets/states/empty_state.dart';
import 'package:radiozulawy/core/widgets/states/error_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Brak zgłoszeń',
              description: 'Nie masz jeszcze żadnych zgłoszeń.',
            ),
          ),
        ),
      );

      expect(find.text('Brak zgłoszeń'), findsOneWidget);
      expect(find.text('Nie masz jeszcze żadnych zgłoszeń.'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('renders without a retry button when onRetry is omitted', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorState(title: 'Nie udało się wczytać')),
        ),
      );

      expect(find.text('Nie udało się wczytać'), findsOneWidget);
      expect(find.text('Spróbuj ponownie'), findsNothing);
    });

    testWidgets('invokes onRetry when the retry button is tapped', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Nie udało się wczytać',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spróbuj ponownie'));
      expect(retried, isTrue);
    });
  });
}
