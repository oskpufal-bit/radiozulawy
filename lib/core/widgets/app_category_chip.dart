import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

/// Reusable tag/chip for categories, locations, podcast tags and filters.
/// Supports selected/unselected/disabled states.
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && onTap != null;

    final Color background;
    final Color foreground;
    final Color border;
    if (!enabled) {
      background = AppColors.surface;
      foreground = AppColors.textMuted;
      border = AppColors.borderSubtle;
    } else if (selected) {
      background = AppColors.brandPrimary;
      foreground = Colors.white;
      border = AppColors.brandBright;
    } else {
      background = AppColors.surfaceElevated;
      foreground = AppColors.textSecondary;
      border = AppColors.borderSubtle;
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: InkWell(
        onTap: isInteractive ? onTap : null,
        borderRadius: AppRadius.fullRadius,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.fullRadius,
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
