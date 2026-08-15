import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Central [ThemeData]. Dark-first by design — Radio Żuławy does not offer
/// a light theme yet, but nothing here assumes dark is the only possible
/// mode, so one can be added later without restructuring this file.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.brandBright,
      onPrimary: Color(0xFF06140A),
      primaryContainer: AppColors.brandPrimary,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.brandPrimary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceElevated,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderSubtle,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brandBright,
        selectionColor: AppColors.brandPrimary,
        selectionHandleColor: AppColors.brandBright,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandBright,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.brandBright, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimary,
      ),
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.textSecondary,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
    );
  }
}
