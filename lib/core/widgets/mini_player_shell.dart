import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_image_surface.dart';
import 'glass_surface.dart';
import 'live_badge.dart';

/// Purely visual shell for the persistent mini-player: thumbnail, title,
/// subtitle, play/pause control and an optional live indicator, on a
/// glass surface. Carries no audio/playback logic — the future audio task
/// wraps this with real player state and wires [onPlayPauseTap].
class MiniPlayerShell extends StatelessWidget {
  const MiniPlayerShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPlaying = false,
    this.isLive = false,
    this.onPlayPauseTap,
    this.onTap,
    this.image,
  });

  final String title;
  final String subtitle;
  final bool isPlaying;
  final bool isLive;
  final VoidCallback? onPlayPauseTap;
  final VoidCallback? onTap;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: AppRadius.cardRadius,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              // Fixed box, not `aspectRatio`: this Row sits in contexts
              // (e.g. inside a scrolling list, or the app shell's bottom
              // nav slot) that can hand AppImageSurface unbounded
              // constraints, which AspectRatio cannot resolve on its own.
              child: AppImageSurface(
                image: image,
                borderRadius: AppRadius.smRadius,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLive) ...[
                    const LiveBadge(animate: false),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _PlayPauseButton(isPlaying: isPlaying, onTap: onPlayPauseTap),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? 'Pauza' : 'Odtwórz',
      child: Material(
        color: AppColors.brandBright,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF06140A),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
