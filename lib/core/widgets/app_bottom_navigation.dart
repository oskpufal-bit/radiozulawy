import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_typography.dart';
import 'glass_surface.dart';

/// Visual definition of one regular (non-"Zgłoś") bottom nav destination.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const List<AppBottomNavItem> _defaultItems = [
  AppBottomNavItem(
    icon: Icons.radio_outlined,
    selectedIcon: Icons.radio_rounded,
    label: 'Radio',
  ),
  AppBottomNavItem(
    icon: Icons.article_outlined,
    selectedIcon: Icons.article_rounded,
    label: 'Newsy',
  ),
  AppBottomNavItem(
    icon: Icons.podcasts_outlined,
    selectedIcon: Icons.podcasts_rounded,
    label: 'Podcasty',
  ),
  AppBottomNavItem(
    icon: Icons.more_horiz_rounded,
    selectedIcon: Icons.more_horiz_rounded,
    label: 'Więcej',
  ),
];

/// Purely visual bottom navigation shell: four regular destinations plus a
/// raised, centered "Zgłoś" action — the app's signature feature, so it
/// gets the most prominent slot. Glass surface, respects [SafeArea].
///
/// This does not wire up go_router — the navigation shell task wires
/// [onIndexSelected]/[onReportTap] to real routes.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexSelected,
    required this.onReportTap,
    this.items = _defaultItems,
  });

  /// Index into [items] (regular destinations only; "Zgłoś" has no index).
  final int currentIndex;
  final ValueChanged<int> onIndexSelected;
  final VoidCallback onReportTap;
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    assert(items.length == 4, 'AppBottomNavigation expects 4 regular items.');

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 68,
              child: GlassSurface(
                borderRadius: AppRadius.lgRadius,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavButton(
                        item: items[0],
                        selected: currentIndex == 0,
                        onTap: () => onIndexSelected(0),
                      ),
                    ),
                    Expanded(
                      child: _NavButton(
                        item: items[1],
                        selected: currentIndex == 1,
                        onTap: () => onIndexSelected(1),
                      ),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      child: _NavButton(
                        item: items[2],
                        selected: currentIndex == 2,
                        onTap: () => onIndexSelected(2),
                      ),
                    ),
                    Expanded(
                      child: _NavButton(
                        item: items[3],
                        selected: currentIndex == 3,
                        onTap: () => onIndexSelected(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(bottom: 40, child: _ReportButton(onTap: onReportTap)),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandBright : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            // Excluded from semantics: it repeats `item.label` above, and
            // (unlike the Icon) Text auto-generates its own semantics node,
            // which would otherwise merge in and announce the label twice.
            ExcludeSemantics(
              child: Text(
                item.label,
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Zgłoś zdarzenie',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppDurations.fast,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandBright, AppColors.brandPrimary],
                ),
                boxShadow: AppShadows.brandGlow(),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Color(0xFF06140A),
                size: 26,
              ),
            ),
            const SizedBox(height: 3),
            // Excluded from semantics: it repeats the Semantics label above
            // ("Zgłoś zdarzenie"), and Text auto-generates its own
            // semantics node, which would otherwise merge in and announce
            // the label twice.
            ExcludeSemantics(
              child: Text(
                'Zgłoś',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
