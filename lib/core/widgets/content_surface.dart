import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

/// Flat base surface for content cards (news, podcasts, contests, schedule
/// items, ...). Deliberately minimal — feature cards should compose this
/// rather than this widget growing feature-specific parameters.
class ContentSurface extends StatelessWidget {
  const ContentSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.cardRadius,
    this.color,
    this.elevated = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;

  /// Elevated surfaces sit a shade lighter with a soft shadow — use for
  /// content that should stand out from the section around it.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color:
                color ??
                (elevated ? AppColors.surfaceElevated : AppColors.surface),
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: elevated ? AppShadows.low : AppShadows.none,
          ),
          child: child,
        ),
      ),
    );
  }
}
