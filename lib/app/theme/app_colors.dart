import 'package:flutter/material.dart';

/// Central color palette for Radio Żuławy.
///
/// Built from the two brand colors ([brandDark], [brandPrimary]) plus a
/// bright accent ([brandBright]). Every other token in the app (theme,
/// gradients, shadows, components) should reference these constants instead
/// of introducing new hardcoded colors — this is the single source of truth
/// for color in the app. See docs/DESIGN_SYSTEM.md.
class AppColors {
  const AppColors._();

  // Brand.
  static const Color brandDark = Color(0xFF1A3D1F);
  static const Color brandPrimary = Color(0xFF2D7A35);
  static const Color brandBright = Color(0xFF4FC463);

  // Backgrounds. Deliberately not pure black — a dark, slightly green
  // charcoal keeps the "bottle green" identity even in the deepest surfaces.
  static const Color backgroundPrimary = Color(0xFF0B140F);
  static const Color backgroundSecondary = Color(0xFF101C15);

  // Surfaces (cards, sheets, elevated containers).
  static const Color surface = Color(0xFF16241C);
  static const Color surfaceElevated = Color(0xFF1E3226);
  static const Color surfaceGlass = Color(0x2BFFFFFF);

  // Text.
  static const Color textPrimary = Color(0xFFF3F7F4);
  static const Color textSecondary = Color(0xFFAFC2B6);
  static const Color textMuted = Color(0xFF7C9084);

  // Borders.
  static const Color borderSubtle = Color(0xFF2A3D32);
  static const Color borderGlass = Color(0x33FFFFFF);

  // Semantic.
  static const Color success = Color(0xFF4FC463);
  static const Color warning = Color(0xFFE3A947);
  static const Color error = Color(0xFFE5615C);
  static const Color info = Color(0xFF5BA8E0);

  // Live indicator. Kept separate from brand green so "on air" always reads
  // unambiguously, but never relied on alone — always paired with a text
  // label (see LiveBadge).
  static const Color live = Color(0xFFFF4B4B);

  // Scrim used under text/controls overlaid on photos.
  static const Color scrim = Color(0xCC0A100D);
}
