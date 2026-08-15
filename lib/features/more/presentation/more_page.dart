import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/content_surface.dart';

class _MoreEntry {
  const _MoreEntry(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}

const List<_MoreEntry> _entries = [
  _MoreEntry(Icons.calendar_month_outlined, 'Ramówka', '/schedule'),
  _MoreEntry(Icons.emoji_events_outlined, 'Konkursy', '/contests'),
  _MoreEntry(Icons.settings_outlined, 'Ustawienia', '/settings'),
  _MoreEntry(Icons.info_outline_rounded, 'O radiu', '/about'),
  _MoreEntry(Icons.mail_outline_rounded, 'Kontakt', '/contact'),
  _MoreEntry(Icons.privacy_tip_outlined, 'Polityka prywatności', '/privacy'),
];

/// Entry points to secondary destinations (schedule, contests, settings,
/// about, contact, privacy policy). Each pushes a full-screen placeholder
/// route above the app shell — see docs/NAVIGATION.md.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const AppSectionHeader(title: 'Więcej'),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemCount: _entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return ContentSurface(
                    onTap: () => context.go(entry.route),
                    child: Row(
                      children: [
                        Icon(
                          entry.icon,
                          color: AppColors.brandBright,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            entry.label,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
