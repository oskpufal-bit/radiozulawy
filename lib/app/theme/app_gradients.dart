import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central gradients. All are green-based and deliberately restrained —
/// premium, not neon. See docs/DESIGN_SYSTEM.md for when to use which.
class AppGradients {
  const AppGradients._();

  /// Default full-screen background gradient.
  static const LinearGradient backgroundPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.backgroundSecondary, AppColors.backgroundPrimary],
  );

  /// Used behind hero/player surfaces that want more brand presence.
  static const LinearGradient heroPlayer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brandPrimary, AppColors.brandDark],
  );

  /// Scrim gradient for text/controls overlaid on a photo (bottom-anchored).
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, AppColors.scrim],
  );

  /// Soft radial glow, e.g. behind an active/live element.
  static RadialGradient glow({
    Color color = AppColors.brandBright,
    double opacity = 0.28,
  }) {
    return RadialGradient(
      colors: [
        color.withValues(alpha: opacity),
        color.withValues(alpha: 0),
      ],
    );
  }
}
