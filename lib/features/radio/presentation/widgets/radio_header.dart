import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/live_badge.dart';

/// Top-of-screen branding: station name, frequency and the "on air"
/// indicator. Purely presentational — [animateLive] is driven by whichever
/// `RadioPlaybackState` the caller is watching (the badge always reads "NA
/// ŻYWO" since the station broadcasts continuously; only the pulse reflects
/// *this device's* playing state).
class RadioHeader extends StatelessWidget {
  const RadioHeader({super.key, required this.animateLive});

  final bool animateLive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Radio Żuławy',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '106.4 FM',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        LiveBadge(animate: animateLive),
      ],
    );
  }
}