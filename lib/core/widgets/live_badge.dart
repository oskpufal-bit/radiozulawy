import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

/// Small, unambiguous "on air" indicator. Always paired with the text label
/// (never color alone) so it reads correctly for colorblind users and in
/// screenshots/screen readers alike.
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key, this.label = 'NA ŻYWO', this.animate = true});

  final String label;

  /// Whether the dot pulses. Automatically disabled when the platform
  /// requests reduced motion.
  final bool animate;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  // Created eagerly (not lazily) so it never gets its first-ever access
  // inside dispose(), which would try to create a ticker against an
  // already-deactivated element.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow * 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant LiveBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final shouldAnimate =
        widget.animate && !MediaQuery.of(context).disableAnimations;
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animate = widget.animate && !reduceMotion;

    return Semantics(
      label: widget.label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.live.withValues(alpha: 0.16),
            borderRadius: AppRadius.fullRadius,
            border: Border.all(color: AppColors.live.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              animate
                  ? FadeTransition(
                      opacity: Tween(begin: 0.4, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: _dot(),
                    )
                  : _dot(),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: AppTypography.overline.copyWith(color: AppColors.live),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.live,
        shape: BoxShape.circle,
      ),
    );
  }
}
