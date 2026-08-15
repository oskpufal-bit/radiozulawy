import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_detail_page.dart';
import '../../features/more/presentation/more_page.dart';
import '../../features/news/presentation/news_article_page.dart';
import '../../features/news/presentation/news_page.dart';
import '../../features/podcasts/presentation/podcast_episode_page.dart';
import '../../features/podcasts/presentation/podcasts_page.dart';
import '../../features/radio/presentation/radio_home_screen.dart';
import '../../features/submit/presentation/submit_page.dart';
import '../dev/design_system_preview_page.dart';
import '../shell/app_shell.dart';
import '../theme/app_durations.dart';

/// Route path constants, kept centralized so features and deep links
/// (notifications, articles, podcasts, ...) reference a single source of
/// truth instead of magic strings scattered across `context.go(...)` calls.
abstract class AppRoutes {
  const AppRoutes._();

  // Main navigation branches (bottom navigation, each keeps its own stack
  // and state — see StatefulShellRoute.indexedStack in [appRouterProvider]).
  static const String radio = '/';
  static const String news = '/news';
  static const String submit = '/submit';
  static const String podcasts = '/podcasts';
  static const String more = '/more';

  /// Detail route nested under [news] — pushed onto the news branch's own
  /// stack, so the bottom navigation stays visible and the branch keeps its
  /// scroll position when the user comes back.
  static String newsArticle(String slug) => '$news/$slug';

  /// Detail route nested under [podcasts], same rationale as [newsArticle].
  static String podcastEpisode(String id) => '$podcasts/$id';

  // "More" destinations. These are full-screen routes pushed above the
  // entire shell (bottom navigation hidden), matching how Settings/About/
  // legal screens typically behave — see docs/NAVIGATION.md.
  static const String schedule = '/schedule';
  static const String contests = '/contests';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';

  /// Development-only Design System catalog (see
  /// `lib/app/dev/design_system_preview_page.dart`). Not linked from any
  /// in-app navigation — reachable only by typing the route directly.
  static const String devDesignSystem = '/dev/design-system';
}

/// Root navigator, used as [GoRouter.navigatorKey] and referenced by
/// [GoRoute.parentNavigatorKey] on routes that should cover the whole
/// screen — including the bottom navigation — instead of living inside one
/// branch's own stack (see the "More" destinations below).
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Central router configuration: a five-branch [StatefulShellRoute] (Radio,
/// Newsy, Zgłoś, Podcasty, Więcej) wrapped by [AppShell], plus full-screen
/// routes for secondary "More" destinations and the dev-only Design System
/// catalog. Nested detail routes (article, episode) can be added under
/// their branch without restructuring this tree.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.radio,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.radio,
                builder: (context, state) => const RadioHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.news,
                builder: (context, state) => const NewsPage(),
                routes: [
                  GoRoute(
                    path: ':slug',
                    pageBuilder: (context, state) => _fadeTransitionPage(
                      state: state,
                      child: NewsArticlePage(
                        slug: state.pathParameters['slug']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.submit,
                builder: (context, state) => const SubmitPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.podcasts,
                builder: (context, state) => const PodcastsPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _fadeTransitionPage(
                      state: state,
                      child: PodcastEpisodePage(
                        episodeId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MorePage(),
              ),
            ],
          ),
        ],
      ),

      // "More" destinations: full-screen over the whole shell (bottom nav
      // hidden), each a lightweight placeholder until its real feature
      // lands. See docs/NAVIGATION.md for why these sit outside the shell.
      GoRoute(
        path: AppRoutes.schedule,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'Ramówka',
            icon: Icons.calendar_month_outlined,
            description:
                'Harmonogram audycji pojawi się w kolejnym etapie developmentu.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.contests,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'Konkursy',
            icon: Icons.emoji_events_outlined,
            description:
                'Lista konkursów pojawi się w kolejnym etapie developmentu.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'Ustawienia',
            icon: Icons.settings_outlined,
            description:
                'Ustawienia aplikacji pojawią się w kolejnym etapie developmentu.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.about,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'O radiu',
            icon: Icons.info_outline_rounded,
            description:
                'Informacje o Radiu Żuławy pojawią się w kolejnym etapie developmentu.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.contact,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'Kontakt',
            icon: Icons.mail_outline_rounded,
            description:
                'Dane kontaktowe pojawią się w kolejnym etapie developmentu.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeTransitionPage(
          state: state,
          child: const AppDetailPage(
            eyebrow: 'Więcej',
            title: 'Polityka prywatności',
            icon: Icons.privacy_tip_outlined,
            description:
                'Treść polityki prywatności zostanie dodana przed wydaniem produkcyjnym.',
            fallbackLocation: AppRoutes.more,
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.devDesignSystem,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DesignSystemPreviewPage(),
      ),
    ],
  );
});

/// Subtle fade for secondary/detail screens — main branch switches
/// (StatefulShellRoute's IndexedStack) intentionally have no transition of
/// their own, see docs/NAVIGATION.md.
CustomTransitionPage<void> _fadeTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
