import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/analytics/analytics.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/device_tier.dart';
import 'core/utils/secure_storage.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/demo_seed_service.dart';

void main() async {
  // Catch all uncaught Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // Catch all uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformError: $error\n$stack');
    return true;
  };

  // Replace red error screen with a user-friendly grey screen
  ErrorWidget.builder = (details) => Material(
    color: Colors.black,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong.\nPlease restart the app.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    ),
  );

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Cihaz performans katmanini tespit et (RAM, core).
    // Tum servisler buna gore adaptive strateji kullanir.
    DeviceProfile.init();

    // Firebase (analytics, firestore, auth)
    try {
      await Firebase.initializeApp();
      await Analytics.init();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }

    try {
      MediaKit.ensureInitialized();
    } catch (e) {
      debugPrint('MediaKit init failed: $e');
      // Non-fatal: video playback may be limited
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    // Migrate plain-text secrets to encrypted storage (one-time).
    _migrateSecrets();

    // Seed CC-licensed public demo content on first launch.
    // Apple 4.2.2 Minimum Functionality guarantee: the app is usable
    // before the user adds their own M3U/Xtream playlist.
    unawaited(DemoSeedService.seedIfNeeded());

    // NOTE: FirebaseSyncService.fetchAndCacheProxySecret() deliberately NOT
    // called on startup. Anonymous auth + Firestore fetch on first launch
    // can cause iOS assertion crashes (App Review). Invoked lazily from
    // Settings / playlist import when the user opts in.

    runApp(const ProviderScope(child: IPTVAIPlayerApp()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

/// One-time migration: plain settings → encrypted Keychain storage.
Future<void> _migrateSecrets() async {
  try {
    final repo = SettingsRepository();
    final migrated = await repo.get(SettingsKeys.secureStorageMigrated);
    if (migrated == 'true') return;
    await SecureStorage.migrateFromPlainSettings(repo.get, repo.delete);
    await repo.set(SettingsKeys.secureStorageMigrated, 'true');
  } catch (e) {
    debugPrint('Secret migration failed: $e');
  }
}

class IPTVAIPlayerApp extends ConsumerStatefulWidget {
  const IPTVAIPlayerApp({super.key});

  @override
  ConsumerState<IPTVAIPlayerApp> createState() => _IPTVAIPlayerAppState();
}

class _IPTVAIPlayerAppState extends ConsumerState<IPTVAIPlayerApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await ref.read(themeModeProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Theme load failed: $e');
      }
      try {
        await ref.read(activePlaylistProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Playlist load failed: $e');
      }
      try {
        final accepted = await ref
            .read(settingsRepoProvider)
            .get(SettingsKeys.disclaimerAccepted);
        if (accepted == 'true' && mounted) {
          appRouter.go(AppRoutes.home);
        }
      } catch (e) {
        debugPrint('Settings load failed: $e');
        // Stay on disclaimer screen (safe default)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title:                      'IPTV AI Player',
      debugShowCheckedModeBanner: false,
      themeMode:                  themeMode,
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      routerConfig:               appRouter,
    );
  }
}
