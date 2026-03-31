import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/disclaimer_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/search/search_screen.dart';

abstract final class AppRoutes {
  static const disclaimer = '/disclaimer';
  static const home       = '/';
  static const player     = '/player';
  static const settings   = '/settings';
  static const playlists  = '/playlists';
  static const search     = '/search';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.disclaimer,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.disclaimer,
      builder: (ctx, state) => DisclaimerScreen(
        onAccepted: () => ctx.go(AppRoutes.home),
      ),
    ),
    GoRoute(
      path:    AppRoutes.home,
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PlayerScreen(
          channelId:  extra['channelId']  as String,
          channelUrl: extra['channelUrl'] as String,
          title:      extra['title']      as String,
        );
      },
    ),
    GoRoute(
      path:    AppRoutes.settings,
      builder: (ctx, state) => const SettingsScreen(),
    ),
    GoRoute(
      path:    AppRoutes.playlists,
      builder: (ctx, state) => const PlaylistsScreen(),
    ),
    GoRoute(
      path:    AppRoutes.search,
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SearchScreen(playlistId: extra?['playlistId'] as String? ?? '');
      },
    ),
  ],
);
