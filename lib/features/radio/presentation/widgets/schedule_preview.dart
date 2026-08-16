import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/content_surface.dart';
import '../../../../core/widgets/states/empty_state.dart';
import '../../domain/schedule_entry.dart';

/// "Co dalej" section: a short, read-only preview of upcoming schedule
/// items. Data comes from `schedulePreviewProvider` (`radio_providers.dart`)
/// — a dev placeholder today, a real schedule repository later (see
/// docs/RADIO_UI.md); this widget only renders whatever list it's given.
class SchedulePreview extends StatelessWidget {
  const SchedulePreview({
    super.key,
    required this.entries,
    required this.onSeeFullSchedule,
  });

  final List<ScheduleEntry> entries;
  final VoidCallback onSeeFullSchedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Co dalej',
          actionLabel: 'Zobacz pełną ramówkę',
          onActionTap: onSeeFullSchedule,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          const EmptyState(
            title: 'Brak zaplanowanych audycji',
            description: 'Ramówka pojawi się wkrótce.',
            icon: Icons.calendar_month_outlined,
          )
        else
          ContentSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _ScheduleRow(entry: entries[i]),
                  if (i != entries.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.entry});

  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              entry.time,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.brandBright,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (entry.hostName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Prowadzi: ${entry.hostName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}