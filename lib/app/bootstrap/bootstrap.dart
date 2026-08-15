import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../core/utils/app_logger.dart';

/// App entry point, factored out of `main.dart` so it can be exercised from
/// widget tests without duplicating startup wiring.
///
/// Initializes bindings and async singletons (currently just
/// [SharedPreferences]) before handing the resulting [ProviderScope] to
/// [runApp].
Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error('Uncaught Flutter error', details.exception, details.stack);
  };

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: appBuilder(),
    ),
  );
}
