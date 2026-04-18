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

void main() {
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

  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // Sync, hizli — blocking olmaz.
    DeviceProfile.init();

    // iOS 26.4.1'de Firebase/MediaKit gibi agir init'ler bazen
    // runApp oncesinde takiliyor ve siyah ekrana yol aciyor.
    // runApp'i HEMEN cagir, kalan init'leri arka planda timeout ile yap.
    runApp(const ProviderScope(child: IPTVAIPlayerApp()));

    unawaited(_bootstrapInBackground());
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

/// runApp sonrasi arka planda calisir; UI'i bloklamaz.
/// Her init bagimsiz timeout ile korunur — biri takilirsa digerleri devam eder.
Future<void> _bootstrapInBackground() async {
  await Future.wait([
    _initFirebaseAndAnalytics(),
    _initMediaKit(),
    _initOrientation(),
  ], eagerError: false);

  await _migrateSecrets();

  unawaited(DemoSeedService.seedIfNeeded());
}

Future<void> _initFirebaseAndAnalytics() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    await Analytics.init().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Firebase/Analytics init failed or timed out: $e');
  }
}

Future<void> _initMediaKit() async {
  try {
    // ensureInitialized() sync ama native tarafta takilma ihtimaline karsi
    // Future'a sarilir ve timeout uygulanir.
    await Future(() => MediaKit.ensureInitialized())
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('MediaKit init failed or timed out: $e');
  }
}

Future<void> _initOrientation() async {
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]).timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('Orientation init failed: $e');
  }
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
