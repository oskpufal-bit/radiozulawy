import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/radio_playback_state.dart';
import 'radio_providers.dart';

/// Presentation-layer API for radio playback. Widgets never call
/// `RadioRepository`/the audio engine directly — they watch
/// `radioPlaybackControllerProvider` for state and call these methods.
///
/// Backed by [radioRepositoryProvider], which stays alive for the app's
/// lifetime, so this controller's state survives tab switches and isn't
/// tied to `RadioPage`'s lifecycle — see docs/AUDIO.md.
class RadioPlaybackController extends Notifier<RadioPlaybackState> {
  StreamSubscription<RadioPlaybackState>? _subscription;

  @override
  RadioPlaybackState build() {
    final repository = ref.watch(radioRepositoryProvider);
    _subscription = repository.watchPlaybackState().listen((next) {
      state = next;
    });
    ref.onDispose(() => _subscription?.cancel());
    return repository.currentState;
  }

  Future<void> play() => ref.read(radioRepositoryProvider).play();

  Future<void> pause() => ref.read(radioRepositoryProvider).pause();

  Future<void> stop() => ref.read(radioRepositoryProvider).stop();

  Future<void> retry() => ref.read(radioRepositoryProvider).retry();

  /// Convenience for the mini-player/RadioPage's single play/pause control.
  Future<void> togglePlayback() {
    if (state.isPlaying || state.isBuffering) {
      return pause();
    }
    return play();
  }
}
