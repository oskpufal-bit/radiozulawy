import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_durations.dart';
import '../../../../app/theme/app_gradients.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../domain/current_show.dart';
import '../../domain/radio_playback_state.dart';
import '../radio_playback_controller.dart';
import 'current_show_info.dart';
import 'playback_status.dart';
import 'radio_artwork.dart';
import 'radio_main_control.dart';

/// The screen's centerpiece: artwork, current-show metadata, the main
/// play/pause control and a status line, on a branded gradient card. Swaps
/// to [ErrorState] (still inside the same card, so the player never
/// disappears) when [state] has an error — see docs/RADIO_UI.md.
class RadioHeroPlayer extends StatelessWidget {
  const RadioHeroPlayer({
    super.key,
    required this.state,
    required this.currentShow,
    required this.controller,
  });

  final RadioPlaybackState state;

  /// Null when show metadata isn't available yet — see
  /// `CurrentShow.fallback` and docs/RADIO_UI.md ("Empty metadata").
  final CurrentShow? currentShow;
  final RadioPlaybackController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppCurves.standard,
      width: double.infinity,
      // ErrorState already applies its own generous internal padding — on a
      // narrow phone, adding this card's full padding on top of that left
      // too little width for the retry button's icon+label Row and caused
      // an overflow, so the error branch only gets a thin inset instead.
      padding: state.hasError
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
      decoration: BoxDecoration(
        gradient: AppGradients.heroPlayer,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: state.isPlaying
              ? AppColors.brandBright.withValues(alpha: 0.4)
              : AppColors.borderGlass,
        ),
        boxShadow: state.isPlaying
            ? AppShadows.brandGlow(opacity: 0.22)
            : AppShadows.medium,
      ),
      child: state.hasError
          ? ErrorState(
              title: 'Nie udało się połączyć',
              description: state.errorMessage,
              onRetry: controller.retry,
              icon: Icons.signal_wifi_off_rounded,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final artworkSize = constraints.maxWidth.isFinite
                    ? (constraints.maxWidth * 0.5).clamp(140.0, 220.0)
                    : 180.0;
                final show = currentShow ?? CurrentShow.fallback;
                return Semantics(
                  // Without this, none of Artwork/CurrentShowInfo/
                  // PlaybackStatus create their own semantics boundary, so
                  // their text silently merges into RadioMainControl's
                  // button node — a screen reader would announce the whole
                  // card as a single "Odtwarzaj..." button. explicitChildNodes
                  // forces each direct child below to stay a separate node.
                  container: true,
                  explicitChildNodes: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioArtwork(
                        size: artworkSize,
                        artworkUrl: show.artworkUrl,
                        isPlaying: state.isPlaying,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CurrentShowInfo(show: show),
                      const SizedBox(height: AppSpacing.lg),
                      RadioMainControl(state: state, controller: controller),
                      const SizedBox(height: AppSpacing.sm),
                      PlaybackStatus(state: state),
                    ],
                  ),
                );
              },
            ),
    );
  }
}