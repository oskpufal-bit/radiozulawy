import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_blur.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Reusable glassmorphism surface: blurred, semi-transparent, with a subtle
/// border. This is the app's *only* blur primitive — used selectively for
/// bottom navigation, the mini-player, overlays and a handful of premium
/// cards. Do not wrap large or frequently-rebuilt surfaces in this; each
/// instance costs a `BackdropFilter` pass. See docs/DESIGN_SYSTEM.md.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    this.child,
    this.padding,
    this.borderRadius = AppRadius.cardRadius,
    this.blurSigma = AppBlur.standard,
    this.backgroundColor = AppColors.surfaceGlass,
    this.borderColor = AppColors.borderGlass,
    this.width,
    this.height,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
