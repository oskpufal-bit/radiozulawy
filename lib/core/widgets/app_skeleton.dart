import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Lightweight shimmer placeholder for content still loading (list items,
/// cards, ...). No external package — a single looping gradient sweep.
/// Automatically becomes a static block when the platform requests reduced
/// motion.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.smRadius,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  // Created eagerly (not lazily) so it never gets its first-ever access
  // inside dispose(), which would try to create a ticker against an
  // already-deactivated element.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
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

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: reduceMotion
            ? const ColoredBox(color: AppColors.surfaceElevated)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1 + 3 * _controller.value, 0),
                        end: Alignment(1 + 3 * _controller.value, 0),
                        colors: const [
                          AppColors.surfaceElevated,
                          AppColors.surface,
                          AppColors.surfaceElevated,
                        ],
                        stops: const [0.35, 0.5, 0.65],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
