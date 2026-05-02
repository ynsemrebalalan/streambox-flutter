import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';

/// Disclaimer SONRASI tek seferlik onboarding ekranı.
/// "Hesap aç → Pro'yu dene" + "Şimdi atla" + "Zaten hesabım var".
/// `welcomeShown=true` flag'i set edilince bir daha gösterilmez.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;

  Future<void> _markSeenAndGo(String route) async {
    if (_busy) return;
    setState(() => _busy = true);
    // Best-effort: DB write fail/timeout olsa bile navigation'i blokama
    // (disclaimer ile ayni pattern — feedback_disclaimer_navigation_fallback).
    try {
      await ref
          .read(settingsRepoProvider)
          .set(SettingsKeys.welcomeShown, 'true')
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Welcome flag set failed: $e');
    }
    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(Icons.celebration,
                    size: 72, color: AppColors.accent),
                const SizedBox(height: 20),
                Text(
                  l.welcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  l.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                _Feature(
                    icon: Icons.tv,
                    title: l.welcomeFeatureUnlimited),
                _Feature(
                    icon: Icons.subtitles,
                    title: l.welcomeFeatureSubtitles),
                _Feature(
                    icon: Icons.cloud_sync,
                    title: l.welcomeFeatureSync),
                const Spacer(),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _markSeenAndGo(AppRoutes.register),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 50)),
                  child: Text(l.welcomeStartFreeButton),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed:
                      _busy ? null : () => _markSeenAndGo(AppRoutes.home),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24)),
                  child: Text(l.welcomeSkipButton),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed:
                      _busy ? null : () => _markSeenAndGo(AppRoutes.login),
                  child: Text(l.welcomeSignInLink,
                      style:
                          const TextStyle(color: Colors.white60)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Feature({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
