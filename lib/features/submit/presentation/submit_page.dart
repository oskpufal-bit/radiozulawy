import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/content_surface.dart';

class _SubmitKind {
  const _SubmitKind(this.icon, this.label);

  final IconData icon;
  final String label;
}

const List<_SubmitKind> _submitKinds = [
  _SubmitKind(Icons.photo_camera_outlined, 'Zdjęcie'),
  _SubmitKind(Icons.videocam_outlined, 'Wideo'),
  _SubmitKind(Icons.mic_outlined, 'Audio'),
  _SubmitKind(Icons.graphic_eq_rounded, 'Wiadomość głosowa'),
];

/// Placeholder for the app's signature "Zgłoś" flow: communicates what the
/// feature is for and previews the four submission kinds. No file picker,
/// permissions or upload logic yet — that's a dedicated later task.
class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Zgłoś zdarzenie',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Wyślij redakcji zdjęcie, wideo, audio lub opis tego, co '
              'dzieje się w Twojej okolicy.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.3,
                children: [
                  for (final kind in _submitKinds)
                    ContentSurface(
                      elevated: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${kind.label} — dostępne w kolejnym etapie developmentu.',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            kind.icon,
                            size: 32,
                            color: AppColors.brandBright,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            kind.label,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
