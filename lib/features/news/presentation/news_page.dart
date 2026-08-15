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

class _DemoArticle {
  const _DemoArticle({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.category,
  });

  final String slug;
  final String title;
  final String excerpt;
  final String category;
}

// Local, presentational placeholder data — replaced by the WordPress REST
// API integration in a later task (see docs/DEV_PLACEHOLDERS.md PH-003).
// Not a registered dev placeholder itself: it's demo content, not a
// URL/key/config value.
const List<_DemoArticle> _demoArticles = [
  _DemoArticle(
    slug: 'nowy-most-na-nogacie',
    title: 'Nowy most na Nogacie oficjalnie otwarty',
    excerpt: 'Kierowcy zyskują szybszy przejazd między powiatami.',
    category: 'Powiat malborski',
  ),
  _DemoArticle(
    slug: 'festyn-w-nowym-dworze',
    title: 'Festyn rodzinny w Nowym Dworze Gdańskim',
    excerpt: 'Atrakcje dla dzieci, koncerty i lokalni wystawcy.',
    category: 'Powiat nowodworski',
  ),
  _DemoArticle(
    slug: 'remont-drogi-elblaska',
    title: 'Remont drogi elbląskiej — utrudnienia w ruchu',
    excerpt: 'Objazdy obowiązują do końca miesiąca.',
    category: 'Powiat malborski',
  ),
];

const List<String> _demoCategories = [
  'Wszystkie',
  'Powiat malborski',
  'Powiat nowodworski',
];

/// Structural placeholder for the news module: header, category filters and
/// a demo article list. Content is static/local — no WordPress API call
/// happens on this screen yet.
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String _selectedCategory = _demoCategories.first;

  @override
  Widget build(BuildContext context) {
    final articles = _selectedCategory == _demoCategories.first
        ? _demoArticles
        : _demoArticles
              .where((article) => article.category == _selectedCategory)
              .toList();

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
                      title: 'Newsy',
                      subtitle: 'Aktualności z Żuław',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final category in _demoCategories)
                          AppCategoryChip(
                            label: category,
                            selected: _selectedCategory == category,
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                          ),
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
                itemCount: articles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ContentSurface(
                    onTap: () => context.go('/news/${article.slug}'),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: AppImageSurface(
                            borderRadius: AppRadius.smRadius,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                article.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                article.excerpt,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
