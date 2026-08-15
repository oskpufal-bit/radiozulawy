import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_category_chip.dart';
import '../../../core/widgets/app_image_surface.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/content_surface.dart';

class _DemoEpisode {
  const _DemoEpisode(this.id, this.title, this.series);

  final String id;
  final String title;
  final String series;
}

// Local, presentational placeholder data — replaced once the podcasts API
// and player exist. Not a registered dev placeholder: demo content, not a
// URL/key/config value.
const List<_DemoEpisode> _demoEpisodes = [
  _DemoEpisode('001', 'Poranek na Żuławach — odc. 1', 'Poranek na Żuławach'),
  _DemoEpisode('002', 'Historie znad Nogatu — odc. 4', 'Historie znad Nogatu'),
  _DemoEpisode('003', 'Sport lokalny — podsumowanie tygodnia', 'Sport lokalny'),
];

const List<String> _demoSeries = [
  'Poranek na Żuławach',
  'Historie znad Nogatu',
  'Sport lokalny',
];

/// Structural placeholder for the podcasts module: latest episodes, series
/// and categories. No podcast player or download logic yet.
class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padded: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Podcasty',
                      subtitle: 'Najnowsze odcinki',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final series in _demoSeries)
                          AppCategoryChip(label: series),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              sliver: SliverList.separated(
                itemCount: _demoEpisodes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final episode = _demoEpisodes[index];
                  return ContentSurface(
                    onTap: () => context.go('/podcasts/${episode.id}'),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: AppImageSurface(
                            borderRadius: AppRadius.smRadius,
                            placeholderIcon: Icons.podcasts_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                episode.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                episode.series,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppColors.brandBright,
                          size: 28,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }
}
