import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radiozulawy/core/widgets/live_badge.dart';

void main() {
  testWidgets('renders the NA ŻYWO label by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LiveBadge())),
    );

    expect(find.text('NA ŻYWO'), findsOneWidget);
  });

  testWidgets('exposes the label via semantics, not color alone', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LiveBadge())),
    );

    final semantics = tester.getSemantics(find.byType(LiveBadge));
    expect(semantics.label, 'NA ŻYWO');

    handle.dispose();
  });

  testWidgets('supports a custom label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LiveBadge(label: 'LIVE')),
      ),
    );

    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('does not animate when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Scaffold(body: LiveBadge())),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(LiveBadge),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });
}
