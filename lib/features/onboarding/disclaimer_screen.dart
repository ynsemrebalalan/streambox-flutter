import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/settings_repository.dart';
import 'legal_notice_screen.dart';

/// Yumusatilmis welcome ekrani.
///
/// Rationale: Onceki surumde cok uzun + sert yasal disclaimer vardi.
/// Apple App Review "scary warning" red sebebi olusturabilir.
/// VLC / GSE Smart IPTV / Smarters Pro pattern'ine gore:
/// - Kisa welcome + "Continue" CTA
/// - Tum yasal metin ayri ekranda ("Legal Notice" butonu)
/// - Bundled demo content (DemoSeedService) reviewer'a hemen gorunur
class DisclaimerScreen extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;
  const DisclaimerScreen({super.key, required this.onAccepted});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool _accepting = false;

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);
    try {
      await ref
          .read(settingsRepoProvider)
          .set(SettingsKeys.disclaimerAccepted, 'true');
      widget.onAccepted();
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  void _openLegal() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const LegalNoticeScreen(),
      fullscreenDialog: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(Icons.play_circle_outline,
                    size: 72, color: AppColors.accent),
                const SizedBox(height: 20),
                const Text(
                  'IPTV AI Player',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 28),
                // Kisa aciklama (EN + TR), VLC/GSE pattern
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'IPTV AI Player is a media player for your own '
                        'M3U playlists and Xtream Codes sources.\n\n'
                        'This app does not provide, host, or distribute '
                        'any content. You must supply your own legally '
                        'obtained playlist URL.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(height: 1, color: Colors.white12),
                      SizedBox(height: 10),
                      Text(
                        'IPTV AI Player, kendi M3U veya Xtream Codes '
                        'oynatma listeleriniz icin bir medya oynaticidir. '
                        'Icerik sunmaz, barindirmaz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _openLegal,
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Legal Notice / Yasal Bildirim'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _accepting ? null : _accept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _accepting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'By continuing you agree to the Legal Notice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
