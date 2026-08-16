import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/radio_playback_state.dart';
import '../radio_playback_controller.dart';

/// Central play/pause control. Talks only to [RadioPlaybackController] —
/// never creates or touches the audio engine directly (see docs/AUDIO.md).
/// Disabled (no tap target) while buffering, showing a spinner instead of
/// swapping the whole player for a full-screen loader.
class RadioMainControl extends StatelessWidget {
  const RadioMainControl({
    super.key,
    required this.state,
    required this.controller,
  });

  final RadioPlaybackState state;
  final RadioPlaybackController controller;

  @override
  Widget build(BuildContext context) {
    final isBuffering = state.isBuffering;
    final isPlaying = state.isPlaying;
    final semanticLabel = isPlaying
        ? 'Wstrzymaj Radio Żuławy'
        : 'Odtwarzaj Radio Żuławy na żywo';

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: !isBuffering,
      child: Material(
        color: AppColors.brandBright,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isBuffering
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  controller.togglePlayback();
                },
          child: SizedBox(
            width: 84,
            height: 84,
            child: Center(
              child: isBuffering
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF06140A)),
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 42,
                      color: const Color(0xFF06140A),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}