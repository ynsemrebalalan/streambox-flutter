import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository.dart';

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

    runApp(const ProviderScope(child: IPTVAIPlayerApp()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
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
