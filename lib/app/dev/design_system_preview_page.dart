import 'package:flutter/material.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_bottom_navigation.dart';
import '../../core/widgets/app_category_chip.dart';
import '../../core/widgets/app_image_surface.dart';
import '../../core/widgets/app_section_header.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/buttons/app_icon_button.dart';
import '../../core/widgets/buttons/app_primary_button.dart';
import '../../core/widgets/buttons/app_secondary_button.dart';
import '../../core/widgets/content_surface.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/live_badge.dart';
import '../../core/widgets/mini_player_shell.dart';
import '../../core/widgets/states/empty_state.dart';
import '../../core/widgets/states/error_state.dart';
import '../../core/widgets/states/loading_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Development-only catalog of every Design System token and component.
///
/// Not part of the real app flow — reachable at the `/dev/design-system`
/// route only. Safe to delete this file and its route once feature screens
/// exist and this stops being useful for visual QA.
class DesignSystemPreviewPage extends StatefulWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  State<DesignSystemPreviewPage> createState() =>
      _DesignSystemPreviewPageState();
}

class _DesignSystemPreviewPageState extends State<DesignSystemPreviewPage> {
  int _navIndex = 0;
  bool _isLoadingDemo = false;
  bool _chipSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padded: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                140,
              ),
              children: [
                Text(
                  'Design System',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Radio Żuławy 106.4 FM — katalog komponentów (dev only)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Paleta kolorów'),
                _colorPalette(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Typografia'),
                _typography(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Przyciski'),
                _buttons(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Icon buttons'),
                _iconButtons(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Glass surface'),
                _glassSurfaceDemo(),
                const SizedBox(height: AppSpacing.xl),

                const AppSectionHeader(
                  title: 'Teraz na antenie',
                  subtitle: 'Przykład Section Header',
                  actionLabel: 'Zobacz wszystkie',
                ),
                const SizedBox(height: AppSpacing.md),
                _contentCardDemo(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Live badge'),
                const Row(children: [LiveBadge()]),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Category chips'),
                _chipsDemo(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Mini-player shell'),
                MiniPlayerShell(
                  title: 'Radio Żuławy 106.4 FM',
                  subtitle: 'Dzień dobry Żuławy',
                  isPlaying: true,
                  isLive: true,
                  onPlayPauseTap: () {},
                ),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Stany: loading / empty / error'),
                _statesDemo(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Skeleton'),
                _skeletonDemo(),
                const SizedBox(height: AppSpacing.xl),

                _sectionTitle('Bottom navigation'),
                Text(
                  'Poniżej: przypięty na dole ekranu (bottomNavigationBar).',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onIndexSelected: (index) => setState(() => _navIndex = index),
        onReportTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zgłoś — demo, brak formularza')),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _colorPalette() {
    const swatches = <(String, Color)>[
      ('brandDark', AppColors.brandDark),
      ('brandPrimary', AppColors.brandPrimary),
      ('brandBright', AppColors.brandBright),
      ('backgroundPrimary', AppColors.backgroundPrimary),
      ('backgroundSecondary', AppColors.backgroundSecondary),
      ('surface', AppColors.surface),
      ('surfaceElevated', AppColors.surfaceElevated),
      ('textPrimary', AppColors.textPrimary),
      ('textSecondary', AppColors.textSecondary),
      ('textMuted', AppColors.textMuted),
      ('borderSubtle', AppColors.borderSubtle),
      ('success', AppColors.success),
      ('warning', AppColors.warning),
      ('error', AppColors.error),
      ('info', AppColors.info),
      ('live', AppColors.live),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (name, color) in swatches)
          SizedBox(
            width: 92,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _typography() {
    final styles = <(String, TextStyle)>[
      ('Display Large', AppTypography.displayLarge),
      ('Headline Medium', AppTypography.headlineMedium),
      ('Title Large', AppTypography.titleLarge),
      ('Body Large', AppTypography.bodyLarge),
      ('Body Medium', AppTypography.bodyMedium),
      ('Label Large', AppTypography.labelLarge),
      ('Caption', AppTypography.caption),
      ('Overline', AppTypography.overline),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in styles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Radio Żuławy — $name',
              style: style.copyWith(color: AppColors.textPrimary),
            ),
          ),
      ],
    );
  }

  Widget _buttons() {
    return Column(
      children: [
        AppPrimaryButton(
          label: 'SŁUCHAJ NA ŻYWO',
          icon: Icons.play_arrow_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: 'ŁADOWANIE…',
          isLoading: _isLoadingDemo,
          onPressed: () => setState(() => _isLoadingDemo = !_isLoadingDemo),
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppPrimaryButton(label: 'NIEDOSTĘPNE', onPressed: null),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: 'WEŹ UDZIAŁ',
          icon: Icons.campaign_outlined,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _iconButtons() {
    return Row(
      children: [
        AppIconButton(
          icon: Icons.share_rounded,
          semanticLabel: 'Udostępnij',
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.download_rounded,
          semanticLabel: 'Pobierz',
          onPressed: () {},
          filled: true,
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.bookmark_border_rounded,
          semanticLabel: 'Zapisz',
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.more_vert_rounded,
          semanticLabel: 'Więcej',
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.close_rounded,
          semanticLabel: 'Zamknij',
          onPressed: null,
        ),
      ],
    );
  }

  Widget _glassSurfaceDemo() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgRadius,
        gradient: AppGradients.heroPlayer,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'GlassSurface nad gradientem',
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _contentCardDemo() {
    return ContentSurface(
      onTap: () {},
      elevated: true,
      child: Row(
        children: [
          const AppImageSurface(
            borderRadius: AppRadius.smRadius,
            aspectRatio: 1,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dzień dobry Żuławy',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prowadzi: Anna Kowalska · 08:00–10:00',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipsDemo() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        AppCategoryChip(
          label: 'Powiat malborski',
          selected: _chipSelected,
          onTap: () => setState(() => _chipSelected = !_chipSelected),
        ),
        const AppCategoryChip(label: 'Podcasty'),
        const AppCategoryChip(label: 'Konkursy'),
        const AppCategoryChip(label: 'Niedostępne', enabled: false),
      ],
    );
  }

  Widget _statesDemo() {
    return Column(
      children: [
        const SizedBox(height: 120, child: LoadingState(message: 'Ładowanie…')),
        const SizedBox(height: AppSpacing.md),
        const SizedBox(
          height: 160,
          child: EmptyState(
            title: 'Brak zgłoszeń',
            description: 'Nie masz jeszcze żadnych zgłoszeń.',
            icon: Icons.inbox_outlined,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: ErrorState(
            title: 'Nie udało się wczytać',
            description: 'Sprawdź połączenie z internetem.',
            onRetry: () {},
          ),
        ),
      ],
    );
  }

  Widget _skeletonDemo() {
    return const Row(
      children: [
        AppSkeleton(width: 56, height: 56, borderRadius: AppRadius.smRadius),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSkeleton(width: double.infinity, height: 16),
              SizedBox(height: AppSpacing.xs),
              AppSkeleton(width: 160, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
