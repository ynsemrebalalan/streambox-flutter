import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/account_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/billing/screens/paywall_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/disclaimer_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/settings/category_filter_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/epg/epg_guide_screen.dart';
import '../../features/parental/parental_lock_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/profiles/profiles_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/theme_picker_screen.dart';
import '../../features/watchlist/watchlist_screen.dart';

abstract final class AppRoutes {
  static const disclaimer = '/disclaimer';
  static const welcome    = '/welcome';   // Phase F'de eklenecek
  static const home       = '/';
  static const player     = '/player';
  static const settings   = '/settings';
  static const playlists  = '/playlists';
  static const search         = '/search';
  static const categoryFilter = '/category-filter';
  static const login    = '/login';
  static const register = '/register';
  static const account  = '/account';
  static const paywall  = '/paywall';     // Phase D'de eklenecek
  // Phase 1 (Pro features):
  static const watchlist     = '/watchlist';
  static const parentalLock  = '/parental-lock';
  static const themePicker   = '/theme-picker';
  // Phase 3:
  static const epgGuide      = '/epg-guide';
  // Phase 6:
  static const profiles      = '/profiles';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.disclaimer,
  debugLogDiagnostics: false,
  // Bilinmeyen path veya navigation hatasinda crash yerine home'a yonlendir.
  errorBuilder: (ctx, state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctx.mounted) ctx.go(AppRoutes.home);
    });
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  },
  routes: [
    GoRoute(
      path: AppRoutes.disclaimer,
      builder: (ctx, state) => DisclaimerScreen(
        // Adim 22 Phase F: disclaimer kabul edilince welcome ekranina goz
        // (welcomeShown=true ise main.dart accepted check welcome'i atlar).
        onAccepted: () => ctx.go(AppRoutes.welcome),
      ),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (ctx, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path:    AppRoutes.home,
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (ctx, state) {
        // Defensive: extra null veya yanlis tipte gelirse home'a geri don.
        // Player'a manuel navigation hatasinda crash yerine graceful fallback.
        final raw = state.extra;
        if (raw is! Map) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) ctx.go(AppRoutes.home);
          });
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final extra = Map<String, dynamic>.from(raw);
        final channelId  = extra['channelId']  as String? ?? '';
        final channelUrl = extra['channelUrl'] as String? ?? '';
        final title      = extra['title']      as String? ?? '';
        if (channelUrl.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) ctx.go(AppRoutes.home);
          });
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Yayin URL bulunamadi',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }
        return PlayerScreen(
          channelId:       channelId,
          channelUrl:      channelUrl,
          title:           title,
          initialPosition: extra['initialPosition'] as int? ?? 0,
          streamType:      extra['streamType']      as String? ?? 'live',
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
      path:    AppRoutes.categoryFilter,
      builder: (ctx, state) => const CategoryFilterScreen(),
    ),
    GoRoute(
      path:    AppRoutes.search,
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SearchScreen(playlistId: extra?['playlistId'] as String? ?? '');
      },
    ),
    GoRoute(
      path:    AppRoutes.login,
      builder: (ctx, state) => const LoginScreen(),
    ),
    GoRoute(
      path:    AppRoutes.register,
      builder: (ctx, state) => const RegisterScreen(),
    ),
    GoRoute(
      path:    AppRoutes.account,
      builder: (ctx, state) => const AccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.paywall,
      builder: (ctx, state) {
        final extra = state.extra;
        final trigger = (extra is Map && extra['trigger'] is String)
            ? extra['trigger'] as String
            : 'unknown';
        return PaywallScreen(trigger: trigger);
      },
    ),
    // Phase 1 — Pro feature ekranları
    GoRoute(
      path:    AppRoutes.watchlist,
      builder: (ctx, state) => const WatchlistScreen(),
    ),
    GoRoute(
      path:    AppRoutes.parentalLock,
      builder: (ctx, state) => const ParentalLockScreen(),
    ),
    GoRoute(
      path:    AppRoutes.themePicker,
      builder: (ctx, state) => const ThemePickerScreen(),
    ),
    GoRoute(
      path:    AppRoutes.epgGuide,
      builder: (ctx, state) => const EpgGuideScreen(),
    ),
    GoRoute(
      path:    AppRoutes.profiles,
      builder: (ctx, state) => const ProfilesScreen(),
    ),
  ],
);
