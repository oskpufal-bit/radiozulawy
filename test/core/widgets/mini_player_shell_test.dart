import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radiozulawy/core/widgets/live_badge.dart';
import 'package:radiozulawy/core/widgets/mini_player_shell.dart';

void main() {
  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MiniPlayerShell(
            title: 'Radio Żuławy 106.4 FM',
            subtitle: 'Dzień dobry Żuławy',
          ),
        ),
      ),
    );

    expect(find.text('Radio Żuławy 106.4 FM'), findsOneWidget);
    expect(find.text('Dzień dobry Żuławy'), findsOneWidget);
  });

  testWidgets('shows play icon when not playing and invokes callback', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniPlayerShell(
            title: 'Radio Żuławy 106.4 FM',
            subtitle: 'Dzień dobry Żuławy',
            onPlayPauseTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    expect(tapped, isTrue);
  });

  testWidgets('shows pause icon when playing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MiniPlayerShell(
            title: 'Radio Żuławy 106.4 FM',
            subtitle: 'Dzień dobry Żuławy',
            isPlaying: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('shows a live badge when isLive is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MiniPlayerShell(
            title: 'Radio Żuławy 106.4 FM',
            subtitle: 'Dzień dobry Żuławy',
            isLive: true,
          ),
        ),
      ),
    );

    expect(find.byType(LiveBadge), findsOneWidget);
  });
}
