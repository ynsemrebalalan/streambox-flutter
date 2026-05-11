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
import 'data/repositories/channel_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/demo_seed_service.dart';
import 'features/ads/ads_service.dart';
import 'features/auth/data/auth_state.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/billing/data/purchases_service.dart';
import 'features/cloud_sync/cloud_sync_controller.dart';
import 'features/epg/epg_auto_refresh_controller.dart';
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

  // AdMob — Free user banner reklamlari icin. Pro user'da widget reklam
  // yuklenmez ama init yine yapilir (Pro -> Free downgrade'de gecikme yok).
  unawaited(_initAdMob());

  unawaited(DemoSeedService.seedIfNeeded());

  // One-time DB migration (2026-05-11): mevcut yanlış classify edilmiş
  // kanalları yeni _detectStreamType ile yeniden değerlendir. Settings
  // flag ile bir kere çalışır.
  unawaited(_runStreamTypeMigration());
}

Future<void> _runStreamTypeMigration() async {
  try {
    final settings = SettingsRepository();
    // v3 zorla yeniden classify (URL-first mantık ile). Eski v2 flag varsa
    // bile v3 ayrı kontrol — yeni mantık tüm DB'yi yeniden değerlendirir.
    final done = await settings.get(SettingsKeys.streamTypeMigratedV3);
    if (done == 'true') return;
    final repo = ChannelRepository();
    // ignore: avoid_print
    print('[migration] streamType v3 başlıyor...');
    final changed = await repo.reclassifyAll().timeout(
        const Duration(seconds: 60));
    // ignore: avoid_print
    print('[migration] streamType v3: $changed channels reclassified');
    await settings.set(SettingsKeys.streamTypeMigratedV3, 'true');
  } catch (e) {
    // ignore: avoid_print
    print('[migration] streamType v3 failed: $e');
  }
}

Future<void> _initAdMob() async {
  try {
    await AdsService.instance
        .ensureInitialized()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('AdMob init failed or timed out: $e');
  }
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

class _IPTVAIPlayerAppState extends ConsumerState<IPTVAIPlayerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      // Cloud sync UI için son sync timestamp'ini yükle.
      try {
        await ref
            .read(cloudSyncControllerProvider.notifier)
            .loadLastSyncedAt();
      } catch (_) {}
    });
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
        await ref.read(themeVariantProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Theme variant load failed: $e');
      }
      try {
        await ref.read(epgAutoRefreshProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('EPG auto-refresh load failed: $e');
      }
      try {
        await ref.read(activePlaylistProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Playlist load failed: $e');
      }
      try {
        await ref.read(activeProfileProvider.notifier).loadFromDb();
      } catch (e) {
        debugPrint('Profile load failed: $e');
      }
      try {
        final repo = ref.read(settingsRepoProvider);
        final accepted = await repo.get(SettingsKeys.disclaimerAccepted);
        if (accepted == 'true' && mounted) {
          // Adim 22 Phase F: welcome bir kez gosterildi mi?
          final welcomeShown =
              await repo.get(SettingsKeys.welcomeShown);
          if (!mounted) return;
          appRouter.go(welcomeShown == 'true'
              ? AppRoutes.home
              : AppRoutes.welcome);
        }
      } catch (e) {
        debugPrint('Settings load failed: $e');
        // Stay on disclaimer screen (safe default)
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App foreground'a döndüğünde cloud pull + EPG auto-refresh tetikle.
    // Pro değilse iki controller da no-op döner.
    if (state == AppLifecycleState.resumed) {
      // ignore: unawaited_futures
      ref.read(cloudSyncControllerProvider.notifier).syncNow();
      // ignore: unawaited_futures
      ref.read(epgAutoRefreshProvider.notifier).maybeRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode    = ref.watch(themeModeProvider);
    final themeVariant = ref.watch(themeVariantProvider);
    final locale       = ref.watch(localeProvider);

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
      // Phase 2 Cloud Sync: login + Pro user'a geçişte otomatik pull
      // (auth Authenticated'a transition oldu mu kontrol).
      final wasAuth = prev?.valueOrNull is AuthAuthenticated;
      final nowAuth = auth is AuthAuthenticated;
      if (!wasAuth && nowAuth) {
        // ignore: unawaited_futures
        ref.read(cloudSyncControllerProvider.notifier).syncNow();
      }
    });

    // Premium theme variant: Pro kullanıcı default DIŞINDA bir varyant
    // seçtiyse hem light hem dark slot'una aynı tema verilir, ThemeMode
    // override'ı pratikte iptal olur (kullanıcı bir tema seçti, sistem
    // dark/light modu o tema içinde anlamsız). Default seçimde mevcut
    // light/dark + system mode davranışı korunur.
    final isPremium = themeVariant != PremiumTheme.defaultDark &&
                      themeVariant != PremiumTheme.defaultLight;

    return MaterialApp.router(
      onGenerateTitle:            (ctx) => AppLocalizations.of(ctx).appName,
      debugShowCheckedModeBanner: false,
      themeMode:                  isPremium ? ThemeMode.dark : themeMode,
      theme:                      isPremium ? AppTheme.of(themeVariant) : AppTheme.light,
      darkTheme:                  isPremium ? AppTheme.of(themeVariant) : AppTheme.dark,
      routerConfig:               appRouter,

      // Localization — `locale: null` means follow system.
      locale:                     locale,
      localizationsDelegates:     AppLocalizations.localizationsDelegates,
      supportedLocales:           AppLocalizations.supportedLocales,
    );
  }
}
