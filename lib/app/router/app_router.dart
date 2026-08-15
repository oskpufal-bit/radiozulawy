import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/radio/presentation/radio_home_screen.dart';
import '../dev/design_system_preview_page.dart';

/// Route path constants, kept centralized so features and deep links
/// (notifications, articles, podcasts, ...) reference a single source of
/// truth instead of magic strings.
abstract class AppRoutes {
  const AppRoutes._();

  static const String radio = '/';

  /// Development-only Design System catalog (see
  /// `lib/app/dev/design_system_preview_page.dart`). Not linked from any
  /// in-app navigation — remove this route once real feature screens exist
  /// and it's no longer the app's initial location.
  static const String devDesignSystem = '/dev/design-system';
}

/// Central router configuration.
///
/// Bottom navigation, nested routes per feature (news article, podcast
/// episode, submission form, ...) and notification deep links are added as
/// those features are implemented, without needing to restructure this
/// provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // TODO(design-system-stage): point back to AppRoutes.radio once the
    // real navigation shell (bottom nav + feature screens) exists — see
    // docs/DEV_PLACEHOLDERS.md.
    initialLocation: AppRoutes.devDesignSystem,
    routes: [
      GoRoute(
        path: AppRoutes.radio,
        builder: (context, state) => const RadioHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.devDesignSystem,
        builder: (context, state) => const DesignSystemPreviewPage(),
      ),
    ],
  );
});
