import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service_radio_repository.dart';
import '../data/dev_show_schedule_data.dart';
import '../data/radio_audio_handler.dart';
import '../domain/current_show.dart';
import '../domain/radio_playback_state.dart';
import '../domain/radio_repository.dart';
import '../domain/schedule_entry.dart';
import 'radio_playback_controller.dart';

/// The single [RadioAudioHandler] instance for the app. Created once in
/// `bootstrap()` via `AudioService.init` and provided here as a value
/// override — mirrors `sharedPreferencesProvider` in `core/providers.dart`.
/// Must be overridden before use (in `bootstrap`, or with a fake
/// [RadioRepository] override in tests — see docs/AUDIO.md).
final radioAudioHandlerProvider = Provider<RadioAudioHandler>(
  (ref) => throw UnimplementedError(
    'radioAudioHandlerProvider must be overridden in bootstrap',
  ),
);

/// Single source of truth for radio playback, consumed by
/// [radioPlaybackControllerProvider]. Override this directly with a fake in
/// tests to avoid touching `audio_service`/`just_audio` at all.
final radioRepositoryProvider = Provider<RadioRepository>(
  (ref) => AudioServiceRadioRepository(ref.watch(radioAudioHandlerProvider)),
);

/// App-wide radio playback state and controls (`play`/`pause`/
/// `togglePlayback`/`stop`/`retry`). Consumed by `RadioHomeScreen`, the
/// global mini-player and (later) system UI — never duplicate this state
/// elsewhere.
final radioPlaybackControllerProvider =
    NotifierProvider<RadioPlaybackController, RadioPlaybackState>(
      RadioPlaybackController.new,
    );

/// What's currently on air — independent of [radioPlaybackControllerProvider]
/// (see docs/RADIO_UI.md, "Playback vs metadata"). Backed by static dev data
/// today (`DEV_PLACEHOLDER` — see docs/DEV_PLACEHOLDERS.md,
/// `CURRENT_SHOW_SOURCE`); a future task swaps the body for a real
/// repository/API call without touching any widget. Null models "no show
/// metadata available yet" — `RadioHeroPlayer` falls back to
/// [CurrentShow.fallback] rather than blocking playback.
final currentShowProvider = Provider<CurrentShow?>((ref) => devCurrentShow);

/// Preview of the next few schedule items ("Co dalej"). Backed by static dev
/// data today (`DEV_PLACEHOLDER` — see docs/DEV_PLACEHOLDERS.md,
/// `SCHEDULE_SOURCE`); a future task swaps the body for a real schedule
/// repository without touching `SchedulePreview`.
final schedulePreviewProvider = Provider<List<ScheduleEntry>>(
  (ref) => devSchedulePreview,
);