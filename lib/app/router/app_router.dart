import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/radio/presentation/radio_home_screen.dart';

/// Route path constants, kept centralized so features and deep links
/// (notifications, articles, podcasts, ...) reference a single source of
/// truth instead of magic strings.
abstract class AppRoutes {
  const AppRoutes._();

  static const String radio = '/';
}

/// Central router configuration.
///
/// Currently exposes a single route so the app has a working shell. Bottom
/// navigation, nested routes per feature (news article, podcast episode,
/// submission form, ...) and notification deep links are added as those
/// features are implemented, without needing to restructure this provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.radio,
    routes: [
      GoRoute(
        path: AppRoutes.radio,
        builder: (context, state) => const RadioHomeScreen(),
      ),
    ],
  );
});
