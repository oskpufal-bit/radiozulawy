import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../core/utils/app_logger.dart';
import '../../features/radio/data/radio_audio_handler.dart';
import '../../features/radio/presentation/radio_providers.dart';

/// App entry point, factored out of `main.dart` so it can be exercised from
/// widget tests without duplicating startup wiring.
///
/// Initializes bindings and async singletons (currently [SharedPreferences]
/// and the [RadioAudioHandler]/`audio_service` session) before handing the
/// resulting [ProviderScope] to [runApp]. The audio handler is created here
/// — once, for the app's lifetime — rather than lazily by a provider default,
/// so background playback survives navigation and widget rebuilds. See
/// docs/AUDIO.md.
Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error('Uncaught Flutter error', details.exception, details.stack);
  };

  final sharedPreferences = await SharedPreferences.getInstance();

  final radioAudioHandler = await AudioService.init(
    builder: RadioAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'pl.radiozulawy.radiozulawy.audio',
      androidNotificationChannelName: 'Radio Żuławy',
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        radioAudioHandlerProvider.overrideWithValue(radioAudioHandler),
      ],
      child: appBuilder(),
    ),
  );
}
