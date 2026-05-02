import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'features/auth/data/auth_state.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/billing/data/purchases_service.dart';
import 'l10n/generated/app_localizations.dart';

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
///
/// NOT: Orientation Info.plist tarafindan yonetiliyor (Portrait + Landscape
/// her iki yon). setPreferredOrientations cagrilmiyor cunku async olarak
/// runApp sonrasi calisinca ilk frame'lerde rotation lock yanlis uygulanip
/// otomatik donusu engelleyebiliyordu.
Future<void> _bootstrapInBackground() async {
  await Future.wait([
    _initFirebaseAndAnalytics(),
    _initMediaKit(),
  ], eagerError: false);

  await _migrateSecrets();

  // RevenueCat — Firebase init'inden SONRA olmali cunku appUserID Firebase
  // anon/authenticated user'in UID'sini kullaniyor. Fail olsa devam (paywall
  // sonradan friendly hata gosterir).
  unawaited(_initRevenueCat());

  unawaited(DemoSeedService.seedIfNeeded());
}

/// RevenueCat configure — boş API key ise atlanır (BuildConfig kontrol).
/// Init fail etse uygulama açılmaya devam eder; paywall'a basıldığında
/// "Satın alma yapılandırılmadı" friendly mesaj gösterilir.
Future<void> _initRevenueCat() async {
  try {
    await PurchasesService.instance
        .configure()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('RevenueCat init failed or timed out: $e');
  }
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
        await ref.read(localeProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Locale load failed: $e');
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
    final locale    = ref.watch(localeProvider);

    // Adim 22 Phase C: Firebase Auth state -> RevenueCat user binding.
    // Anon UID, login UID veya null hangi olursa olsun RC'yi senkron tut.
    // Build icindeki ref.listen Riverpod kurali (initState'te degil).
    ref.listen(authStateProvider, (prev, next) {
      final auth = next.valueOrNull;
      final uid = auth?.userOrNull?.uid;
      if (uid != null && uid.isNotEmpty) {
        PurchasesService.instance.logIn(uid);
      } else {
        PurchasesService.instance.logOut();
      }
    });

    return MaterialApp.router(
      onGenerateTitle:            (ctx) => AppLocalizations.of(ctx).appName,
      debugShowCheckedModeBanner: false,
      themeMode:                  themeMode,
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      routerConfig:               appRouter,

      // Localization — `locale: null` means follow system.
      locale:                     locale,
      localizationsDelegates:     AppLocalizations.localizationsDelegates,
      supportedLocales:           AppLocalizations.supportedLocales,
    );
  }
}
