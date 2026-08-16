import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/radio_playback_state.dart';

/// Status line under the main control: what's currently happening with the
/// connection ("Łączenie…", "Buforowanie…", "Słuchasz na żywo", ...), plus a
/// purely decorative micro-animation while playing. Never renders a raw
/// exception — `RadioPlaybackState.errorMessage` is already user-facing (see
/// docs/AUDIO.md); the error case itself is handled by `ErrorState` one
/// level up in `RadioHeroPlayer`, not here.
class PlaybackStatus extends StatelessWidget {
  const PlaybackStatus({super.key, required this.state});

  final RadioPlaybackState state;

  String get _label => switch (state.status) {
    RadioPlaybackStatus.playing => 'Słuchasz na żywo',
    RadioPlaybackStatus.loading => 'Łączenie z radiem…',
    RadioPlaybackStatus.buffering => 'Buforowanie…',
    RadioPlaybackStatus.paused => 'Wstrzymano',
    // `error` never actually reaches this widget — RadioHeroPlayer swaps to
    // ErrorState instead — but the switch stays exhaustive on purpose.
    RadioPlaybackStatus.stopped ||
    RadioPlaybackStatus.idle ||
    RadioPlaybackStatus.error => 'Gotowe do słuchania',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.isPlaying) ...[
          const _AudioVisualizerBars(),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          _label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

/// Purely decorative "audio is active" cue — three bars with staggered,
/// looping heights. Not a real spectrum analyzer (no signal analysis), and
/// respects reduced motion by freezing at a static height instead of
/// animating.
class _AudioVisualizerBars extends StatefulWidget {
  const _AudioVisualizerBars();

  @override
  State<_AudioVisualizerBars> createState() => _AudioVisualizerBarsState();
}

class _AudioVisualizerBarsState extends State<_AudioVisualizerBars>
    with SingleTickerProviderStateMixin {
  // Created eagerly so it's never first-accessed inside dispose() against an
  // already-deactivated element (same pattern as AppSkeleton/LiveBadge).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  static const List<double> _phases = [0, 0.25, 0.5];

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

    return SizedBox(
      width: 16,
      height: 12,
      child: reduceMotion
          ? _bars(const [0.6, 0.6, 0.6])
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) =>
                  _bars([for (final phase in _phases) _heightFor(phase)]),
            ),
    );
  }

  double _heightFor(double phase) {
    final t = _controller.value + phase;
    return 0.3 + 0.7 * (0.5 + 0.5 * math.sin(2 * math.pi * t));
  }

  Widget _bars(List<double> heights) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in heights)
          Container(
            width: 3,
            height: 12 * height,
            decoration: BoxDecoration(
              color: AppColors.brandBright,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}