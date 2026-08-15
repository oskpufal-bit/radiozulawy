import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radiozulawy/core/widgets/app_bottom_navigation.dart';

void main() {
  testWidgets('renders the four regular destinations and Zgłoś', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: 0,
            onIndexSelected: (_) {},
            onReportTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Radio'), findsOneWidget);
    expect(find.text('Newsy'), findsOneWidget);
    expect(find.text('Podcasty'), findsOneWidget);
    expect(find.text('Więcej'), findsOneWidget);
    expect(find.text('Zgłoś'), findsOneWidget);
  });

  testWidgets('invokes onIndexSelected with the tapped destination', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: 0,
            onIndexSelected: (index) => selected = index,
            onReportTap: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Newsy'));
    expect(selected, 1);

    await tester.tap(find.text('Podcasty'));
    expect(selected, 2);
  });

  testWidgets('invokes onReportTap when the central action is tapped', (
    tester,
  ) async {
    var reported = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: 0,
            onIndexSelected: (_) {},
            onReportTap: () => reported = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Zgłoś'));
    expect(reported, isTrue);
  });
}
