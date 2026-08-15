import 'package:flutter/material.dart';

import '../../../app/config/app_config.dart';

/// Landing screen fundament. Radio playback, media notifications and the
/// mini-player are implemented in a later task — this screen only confirms
/// the app shell (theme, routing, DI) boots correctly.
class RadioHomeScreen extends StatelessWidget {
  const RadioHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Radio Żuławy 106.4 FM',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fundament aplikacji gotowy.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (AppConfig.environment.name == 'dev') ...[
                  const SizedBox(height: 24),
                  Text(
                    'Środowisko: ${AppConfig.environment.name}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
