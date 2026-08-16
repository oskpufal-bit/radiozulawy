import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_gradients.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_image_surface.dart';

/// Show artwork with a branded fallback when no [artworkUrl] is available
/// yet (dev data never sets one — see docs/RADIO_UI.md). Sized responsively
/// by the caller via [size] rather than a fixed constant, so it scales down
/// on small phones and doesn't balloon on tablets.
class RadioArtwork extends StatelessWidget {
  const RadioArtwork({
    super.key,
    required this.size,
    this.artworkUrl,
    this.isPlaying = false,
  });

  final double size;
  final String? artworkUrl;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: AppColors.brandBright.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: -6,
                ),
              ]
            : const [],
      ),
      child: artworkUrl == null
          ? const _ArtworkFallback()
          : AppImageSurface(
              image: NetworkImage(artworkUrl!),
              borderRadius: AppRadius.cardRadius,
            ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback();

  @override
  Widget build(BuildContext context) {
    // Purely decorative — the station name/frequency is already announced
    // by RadioHeader, so this doesn't need its own semantics node.
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.heroPlayer,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.graphic_eq_rounded,
                size: 44,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 6),
              Text(
                '106.4 FM',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}