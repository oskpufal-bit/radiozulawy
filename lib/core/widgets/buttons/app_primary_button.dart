import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// The app's primary call-to-action button (e.g. "SŁUCHAJ NA ŻYWO",
/// "WYŚLIJ ZGŁOSZENIE"). Solid brand-green fill, pill radius, loading and
/// disabled states, minimum 48dp touch target.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandBright,
          foregroundColor: const Color(0xFF06140A),
          disabledBackgroundColor: AppColors.brandBright.withValues(
            alpha: 0.35,
          ),
          disabledForegroundColor: const Color(
            0xFF06140A,
          ).withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.fullRadius),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF06140A)),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  // Flexible + ellipsis: on very narrow constraints (e.g. a
                  // button nested inside a padded card on a small phone)
                  // this shrinks gracefully instead of overflowing.
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}