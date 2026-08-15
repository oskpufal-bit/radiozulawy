import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_background.dart';
import 'buttons/app_icon_button.dart';

/// Generic back-navigable detail screen shell for lightweight secondary
/// routes (article/episode placeholders, "More" destinations like Ramówka
/// or Ustawienia) before they get real feature-specific content and their
/// own bespoke header. Screens with a custom hero/header compose
/// [AppBackground] directly instead of this.
class AppDetailPage extends StatelessWidget {
  const AppDetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.fallbackLocation,
    this.eyebrow,
  });

  final String title;
  final IconData icon;
  final String description;
  final String? eyebrow;

  /// Where to navigate when there's nothing left to pop (e.g. this route
  /// was opened directly, such as from a future deep link).
  final String fallbackLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              semanticLabel: 'Wstecz',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(fallbackLocation);
                }
              },
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 48, color: AppColors.brandBright),
                      const SizedBox(height: AppSpacing.md),
                      if (eyebrow != null) ...[
                        Text(
                          eyebrow!.toUpperCase(),
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                      ],
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
