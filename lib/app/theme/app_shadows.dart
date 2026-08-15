import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central elevation styles. In a dark UI, heavy drop shadows read as muddy
/// — these are intentionally subtle. Prefer a border/surface contrast bump
/// over reaching for a higher elevation level when in doubt.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> low = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x40000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 32, offset: Offset(0, 14)),
  ];

  /// Soft brand-colored glow, used sparingly behind active/premium elements
  /// (e.g. the central "Zgłoś" action) instead of a literal drop shadow.
  static List<BoxShadow> brandGlow({double opacity = 0.35}) => [
    BoxShadow(
      color: AppColors.brandBright.withValues(alpha: opacity),
      blurRadius: 24,
      spreadRadius: -2,
    ),
  ];
}
