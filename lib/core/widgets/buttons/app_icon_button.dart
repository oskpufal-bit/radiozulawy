import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Consistent icon-only button for actions like share, download,
/// favorite/bookmark, more, close. Not a replacement for every [IconButton]
/// in the app — use this specifically where the app-standard tappable
/// circle (with optional filled background) is wanted.
///
/// Always requires [semanticLabel]: icon-only buttons carry no information
/// for screen reader users otherwise.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.filled = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool filled;

  /// Overall tappable diameter. Defaults to 44dp, at the accessible touch
  /// target minimum.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: Material(
        color: filled ? AppColors.surfaceElevated : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: 22,
              color: onPressed == null
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
