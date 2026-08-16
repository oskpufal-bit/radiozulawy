import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/providers.dart';
import '../../../core/services/share_service.dart';
import '../../../core/widgets/app_background.dart';
import 'radio_providers.dart';
import 'widgets/radio_header.dart';
import 'widgets/radio_hero_player.dart';
import 'widgets/radio_quick_actions.dart';
import 'widgets/schedule_preview.dart';

/// Final Radio Live screen: header/branding, the hero player (artwork,
/// current show, play/pause, status), a "Co dalej" schedule preview and
/// quick actions (share, full schedule).
///
/// Playback comes from `radioPlaybackControllerProvider` — the exact same
/// state the global mini-player uses (see docs/AUDIO.md); show/schedule
/// metadata is a deliberately separate concern, see docs/RADIO_UI.md. The
/// global mini-player hides itself while this screen is active (see
/// `AppShell`) so the two never show at once.
class RadioHomeScreen extends ConsumerWidget {
  const RadioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioPlaybackControllerProvider);
    final controller = ref.read(radioPlaybackControllerProvider.notifier);
    final currentShow = ref.watch(currentShowProvider);
    final schedule = ref.watch(schedulePreviewProvider);

    return Scaffold(
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xxl,
          ),
          children: [
            RadioHeader(animateLive: state.isPlaying),
            const SizedBox(height: AppSpacing.lg),
            RadioHeroPlayer(
              state: state,
              currentShow: currentShow,
              controller: controller,
            ),
            const SizedBox(height: AppSpacing.xl),
            SchedulePreview(
              entries: schedule,
              onSeeFullSchedule: () => context.go('/schedule'),
            ),
            const SizedBox(height: AppSpacing.xl),
            RadioQuickActions(
              onShare: () => _share(context, ref.read(shareServiceProvider)),
              onSeeFullSchedule: () => context.go('/schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, ShareService shareService) async {
    await shareService.share('Słuchaj Radia Żuławy 106.4 FM');
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Skopiowano do schowka')));
  }
}