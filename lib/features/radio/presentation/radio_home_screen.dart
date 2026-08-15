import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_gradients.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/buttons/app_primary_button.dart';
import '../../../core/widgets/live_badge.dart';
import '../../../core/widgets/states/error_state.dart';
import '../domain/radio_playback_state.dart';
import 'radio_playback_controller.dart';
import 'radio_providers.dart';

/// Default tab on launch. Technical/intermediate screen for this stage: it
/// wires the real playback engine (play/pause/retry, loading/buffering,
/// errors) through `radioPlaybackControllerProvider`, but is not the final
/// Radio Live layout (no hero artwork/current-show metadata yet — that's a
/// later task, see docs/AUDIO.md).
class RadioHomeScreen extends ConsumerWidget {
  const RadioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioPlaybackControllerProvider);
    final controller = ref.read(radioPlaybackControllerProvider.notifier);

    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Radio Żuławy',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '106.4 FM · Żuławy i okolice',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: AppGradients.heroPlayer,
                    borderRadius: AppRadius.lgRadius,
                    boxShadow: AppShadows.medium,
                  ),
                  child: state.hasError
                      ? ErrorState(
                          title: 'Nie udało się połączyć',
                          description: state.errorMessage,
                          onRetry: controller.retry,
                          icon: Icons.signal_wifi_off_rounded,
                        )
                      : _PlayerContent(state: state, controller: controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerContent extends StatelessWidget {
  const _PlayerContent({required this.state, required this.controller});

  final RadioPlaybackState state;
  final RadioPlaybackController controller;

  String get _actionLabel => switch (state.status) {
    RadioPlaybackStatus.playing => 'Pauza',
    RadioPlaybackStatus.loading => 'Łączenie...',
    RadioPlaybackStatus.buffering => 'Buforowanie...',
    _ => 'Słuchaj na żywo',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LiveBadge(),
        const SizedBox(height: AppSpacing.lg),
        const Icon(Icons.graphic_eq_rounded, size: 56, color: Colors.white),
        const SizedBox(height: AppSpacing.md),
        Text(
          '106.4 FM',
          style: AppTypography.displayLarge.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          label: _actionLabel,
          icon: state.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          isLoading: state.isBuffering,
          expand: false,
          onPressed: controller.togglePlayback,
        ),
      ],
    );
  }
}
