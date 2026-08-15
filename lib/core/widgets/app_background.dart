import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_spacing.dart';

/// Standard full-bleed background wrapper for screens: paints the app's
/// dark green gradient, then optionally applies [SafeArea] and screen
/// padding. Use as the `Scaffold.body`.
///
/// Set [padded] to false for full-bleed screens (e.g. a hero image screen)
/// that want to control their own insets.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.gradient = AppGradients.backgroundPrimary,
    this.safeArea = true,
    this.padded = true,
  });

  final Widget child;

  /// Pass null to render a flat [AppColors.backgroundPrimary] instead.
  final Gradient? gradient;
  final bool safeArea;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padded) {
      content = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          gradient: gradient,
        ),
        child: content,
      ),
    );
  }
}
