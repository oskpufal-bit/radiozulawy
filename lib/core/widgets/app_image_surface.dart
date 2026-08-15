import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';
import '../../app/theme/app_radius.dart';

/// Presents an image (cover art, article thumbnail, ...) with rounded
/// corners, a placeholder while [image] is null, an error fallback, and an
/// optional bottom scrim for overlaid text.
///
/// Does not implement any actual image loading/caching — that belongs to
/// whichever feature introduces a real image API. [image] simply accepts
/// any [ImageProvider] (asset, memory, network) once one exists.
class AppImageSurface extends StatelessWidget {
  const AppImageSurface({
    super.key,
    this.image,
    this.borderRadius = AppRadius.cardRadius,
    this.aspectRatio,
    this.gradientOverlay = false,
    this.placeholderIcon = Icons.radio_rounded,
  });

  final ImageProvider? image;
  final BorderRadius borderRadius;
  final double? aspectRatio;
  final bool gradientOverlay;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    Widget content = image == null
        ? _Placeholder(icon: placeholderIcon)
        : Image(
            image: image!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _Placeholder(icon: placeholderIcon),
          );

    if (gradientOverlay) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          content,
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.imageOverlay),
          ),
        ],
      );
    }

    content = ClipRRect(borderRadius: borderRadius, child: content);

    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }

    return content;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceElevated,
      child: Center(child: Icon(icon, color: AppColors.textMuted, size: 28)),
    );
  }
}
