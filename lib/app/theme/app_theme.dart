import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Foundational dark theme. Placeholder for the full design system
/// (gradients, glassmorphism surfaces, typography scale) planned for a
/// later task — intentionally minimal for now.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brightGreen,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
