import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: IPTVAIPlayerApp()));
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
      await ref.read(themeModeProvider.notifier).loadFromDb();
      await ref.read(activePlaylistProvider.notifier).loadFromDb();
      // Skip disclaimer if already accepted
      final accepted = await ref
          .read(settingsRepoProvider)
          .get(SettingsKeys.disclaimerAccepted);
      if (accepted == 'true' && mounted) {
        appRouter.go(AppRoutes.home);
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
