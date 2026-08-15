import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiozulawy/features/radio/domain/radio_playback_state.dart';
import 'package:radiozulawy/features/radio/presentation/radio_providers.dart';

import 'fake_radio_repository.dart';

void main() {
  late FakeRadioRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeRadioRepository();
    container = ProviderContainer(
      overrides: [radioRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    addTearDown(fakeRepository.dispose);
  });

  test('initial state mirrors the repository (idle)', () {
    final state = container.read(radioPlaybackControllerProvider);

    expect(state.status, RadioPlaybackStatus.idle);
  });

  test(
    'play() delegates to the repository and reflects playing state',
    () async {
      final notifier = container.read(radioPlaybackControllerProvider.notifier);

      await notifier.play();

      expect(fakeRepository.playCalls, 1);
      expect(
        container.read(radioPlaybackControllerProvider).status,
        RadioPlaybackStatus.playing,
      );
    },
  );

  test(
    'pause() delegates to the repository and reflects paused state',
    () async {
      final notifier = container.read(radioPlaybackControllerProvider.notifier);
      await notifier.play();

      await notifier.pause();

      expect(fakeRepository.pauseCalls, 1);
      expect(
        container.read(radioPlaybackControllerProvider).status,
        RadioPlaybackStatus.paused,
      );
    },
  );

  test(
    'stop() delegates to the repository and reflects stopped state',
    () async {
      final notifier = container.read(radioPlaybackControllerProvider.notifier);
      await notifier.play();

      await notifier.stop();

      expect(fakeRepository.stopCalls, 1);
      expect(
        container.read(radioPlaybackControllerProvider).status,
        RadioPlaybackStatus.stopped,
      );
    },
  );

  test('togglePlayback() plays when not playing/buffering', () async {
    final notifier = container.read(radioPlaybackControllerProvider.notifier);

    await notifier.togglePlayback();

    expect(fakeRepository.playCalls, 1);
    expect(fakeRepository.pauseCalls, 0);
  });

  test('togglePlayback() pauses when currently playing', () async {
    final notifier = container.read(radioPlaybackControllerProvider.notifier);
    await notifier.play();

    await notifier.togglePlayback();

    expect(fakeRepository.pauseCalls, 1);
  });

  test('togglePlayback() pauses when currently buffering', () async {
    fakeRepository.emit(
      const RadioPlaybackState(status: RadioPlaybackStatus.buffering),
    );
    final notifier = container.read(radioPlaybackControllerProvider.notifier);
    container.read(radioPlaybackControllerProvider); // ensure listening started

    await notifier.togglePlayback();

    expect(fakeRepository.pauseCalls, 1);
    expect(fakeRepository.playCalls, 0);
  });

  test('a repository error is surfaced as an error state', () async {
    fakeRepository.nextPlayResult = const RadioPlaybackState(
      status: RadioPlaybackStatus.error,
      errorType: RadioPlaybackErrorType.notConfigured,
      errorMessage: 'Stream radia nie został jeszcze skonfigurowany.',
    );
    final notifier = container.read(radioPlaybackControllerProvider.notifier);

    await notifier.play();

    final state = container.read(radioPlaybackControllerProvider);
    expect(state.status, RadioPlaybackStatus.error);
    expect(state.errorType, RadioPlaybackErrorType.notConfigured);
    expect(state.hasError, isTrue);
  });

  test(
    'retry() delegates to the repository and can recover from an error',
    () async {
      fakeRepository.nextPlayResult = const RadioPlaybackState(
        status: RadioPlaybackStatus.error,
        errorType: RadioPlaybackErrorType.network,
        errorMessage: 'Brak połączenia z internetem.',
      );
      final notifier = container.read(radioPlaybackControllerProvider.notifier);
      await notifier.play();
      expect(
        container.read(radioPlaybackControllerProvider).status,
        RadioPlaybackStatus.error,
      );

      fakeRepository.nextPlayResult = null;
      await notifier.retry();

      expect(fakeRepository.retryCalls, 1);
      expect(
        container.read(radioPlaybackControllerProvider).status,
        RadioPlaybackStatus.playing,
      );
    },
  );

  test(
    'play() without a configured stream URL surfaces notConfigured without retry loops',
    () async {
      fakeRepository.nextPlayResult = const RadioPlaybackState(
        status: RadioPlaybackStatus.error,
        errorType: RadioPlaybackErrorType.notConfigured,
        errorMessage: 'Stream radia nie został jeszcze skonfigurowany.',
      );
      final notifier = container.read(radioPlaybackControllerProvider.notifier);

      await notifier.play();

      expect(fakeRepository.playCalls, 1);
      final state = container.read(radioPlaybackControllerProvider);
      expect(state.errorType, RadioPlaybackErrorType.notConfigured);
      expect(state.isSessionActive, isFalse);
    },
  );
}
