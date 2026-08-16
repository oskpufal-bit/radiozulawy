import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_secondary_button.dart';

/// Secondary actions below the fold: share the station, jump to the full
/// schedule. Both delegate to the caller — this widget owns no
/// share/navigation logic itself.
///
/// Stacked (not side-by-side): two half-width `AppSecondaryButton`s with
/// icon + label text overflow on narrow phones (~360dp) once
/// `AppSecondaryButton`'s fixed horizontal padding is accounted for — full
/// width avoids that without touching the shared button component.
class RadioQuickActions extends StatelessWidget {
  const RadioQuickActions({
    super.key,
    required this.onShare,
    required this.onSeeFullSchedule,
  });

  final VoidCallback onShare;
  final VoidCallback onSeeFullSchedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSecondaryButton(
          label: 'Udostępnij',
          icon: Icons.share_rounded,
          onPressed: onShare,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: 'Ramówka',
          icon: Icons.calendar_month_outlined,
          onPressed: onSeeFullSchedule,
        ),
      ],
    );
  }
}