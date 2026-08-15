import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_service_radio_repository.dart';
import '../data/radio_audio_handler.dart';
import '../domain/radio_playback_state.dart';
import '../domain/radio_repository.dart';
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
