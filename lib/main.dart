import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: StreamBoxApp()));
}

class StreamBoxApp extends ConsumerStatefulWidget {
  const StreamBoxApp({super.key});

  @override
  ConsumerState<StreamBoxApp> createState() => _StreamBoxAppState();
}

class _StreamBoxAppState extends ConsumerState<StreamBoxApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(themeModeProvider.notifier).loadFromDb();
      await ref.read(activePlaylistProvider.notifier).loadFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title:                      'StreamBox',
      debugShowCheckedModeBanner: false,
      themeMode:                  themeMode,
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      routerConfig:               appRouter,
    );
  }
}
