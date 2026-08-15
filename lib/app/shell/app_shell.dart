import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_bottom_navigation.dart';
import '../../core/widgets/mini_player_shell.dart';
import '../theme/app_durations.dart';
import '../theme/app_spacing.dart';

/// Root App Shell: hosts the five main navigation branches (Radio, Newsy,
/// Zgłoś, Podcasty, Więcej) behind [AppBottomNavigation], reserves a slot
/// above it for the future global mini-player, and normalizes the Android
/// back button so switching branches never piles them onto the system back
/// stack. See docs/NAVIGATION.md.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    this.showMiniPlayerPreview = false,
  });

  final StatefulNavigationShell navigationShell;

  /// Development-only seam to visually verify the mini-player slot before
  /// real playback state exists. The future audio feature replaces this
  /// with a provider reflecting whether a stream is actually playing —
  /// intentionally not a Riverpod provider itself, so there's nothing to
  /// unwind later beyond deleting this parameter.
  final bool showMiniPlayerPreview;

  /// Bottom-nav "regular" positions (Radio, Newsy, Podcasty, Więcej) mapped
  /// to their [navigationShell] branch index. "Zgłoś" (branch 2) has no
  /// regular position — it's the raised central action, see
  /// [_onReportTap].
  static const List<int> _branchForNavIndex = [0, 1, 3, 4];
  static const int _submitBranchIndex = 2;
  static const int _radioBranchIndex = 0;

  int get _navIndexForCurrentBranch =>
      _branchForNavIndex.indexOf(navigationShell.currentIndex);

  void _onIndexSelected(int navIndex) {
    final targetBranch = _branchForNavIndex[navIndex];
    navigationShell.goBranch(
      targetBranch,
      // Tapping the already-active tab resets it to its initial location,
      // matching common bottom-nav convention.
      initialLocation: targetBranch == navigationShell.currentIndex,
    );
  }

  void _onReportTap() => navigationShell.goBranch(_submitBranchIndex);

  @override
  Widget build(BuildContext context) {
    final isOnRadioBranch = navigationShell.currentIndex == _radioBranchIndex;

    return PopScope(
      // When we're not on the initial (Radio) branch, back should return
      // there instead of exiting the app. Popping a pushed detail route
      // within a branch (e.g. a news article) is already handled by
      // go_router itself before this is ever consulted.
      canPop: isOnRadioBranch,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        navigationShell.goBranch(_radioBranchIndex);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppDurations.normal,
              child: showMiniPlayerPreview
                  ? Padding(
                      key: const ValueKey('mini-player-slot-visible'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.xs,
                      ),
                      child: MiniPlayerShell(
                        title: 'Radio Żuławy 106.4 FM',
                        subtitle: 'Podgląd deweloperski — bez audio',
                        isLive: true,
                        isPlaying: true,
                        onPlayPauseTap: () {},
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('mini-player-slot-hidden'),
                    ),
            ),
            AppBottomNavigation(
              currentIndex: _navIndexForCurrentBranch,
              onIndexSelected: _onIndexSelected,
              onReportTap: _onReportTap,
            ),
          ],
        ),
      ),
    );
  }
}
