import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/current_show.dart';

/// The "TERAZ" block: show title (the most important text after branding),
/// host and time range as secondary information. Renders
/// `CurrentShow.fallback` the same way as real data — see docs/RADIO_UI.md
/// ("Empty metadata").
class CurrentShowInfo extends StatelessWidget {
  const CurrentShowInfo({super.key, required this.show});

  final CurrentShow show;

  @override
  Widget build(BuildContext context) {
    final subtitle = show.hasTimeRange
        ? '${show.hostName} · ${show.timeRange}'
        : show.hostName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TERAZ',
          style: AppTypography.overline.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          show.title,
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}