import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'player_buttons.dart' show playerAccent;

// ── Gesture overlay (ses / parlaklık) ───────────────────────────────────────

class GestureValueOverlay extends StatelessWidget {
  /// 'volume' (sağ) veya 'brightness' (sol)
  final String type;
  final double value; // 0..1

  const GestureValueOverlay({super.key, required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    final isVolume = type == 'volume';
    final icon = isVolume
        ? (value < 0.01
            ? Icons.volume_off
            : value < 0.5
                ? Icons.volume_down
                : Icons.volume_up)
        : (value < 0.5 ? Icons.brightness_low : Icons.brightness_high);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(
                    isVolume ? Colors.amber : Colors.lightBlueAccent),
              ),
            ),
            const SizedBox(height: 6),
            Text('${(value * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ),
    );
  }
}

// ── Aksiyon feedback pill ───────────────────────────────────────────────────

class ActionFeedbackOverlay extends StatelessWidget {
  final IconData? icon;
  final String text;

  /// Çift dokunma sarmasında pill dokunulan tarafa yaslanır.
  final Alignment alignment;

  /// Kontroller açıkken ortadaki pill oynat butonunun üstüne binmesin diye
  /// yukarı (y = -0.6) kaydırılır.
  final bool controlsVisible;

  const ActionFeedbackOverlay({
    super.key,
    required this.icon,
    required this.text,
    this.alignment = Alignment.center,
    this.controlsVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = controlsVisible && alignment == Alignment.center
        ? const Alignment(0, -0.6)
        : alignment;
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        child: AnimatedAlign(
          alignment: align,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xxxl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Yalnızca ses (radyo vb.): logo + kanal adı ──────────────────────────────

class AudioOnlyOverlay extends StatelessWidget {
  final String title;
  final String logoUrl;
  const AudioOnlyOverlay({super.key, required this.title, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.isEmpty
                  ? const Icon(Icons.radio, color: Colors.white70, size: 56)
                  : CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.radio, color: Colors.white70, size: 56),
                    ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bloklayıcı hata ekranı (yeniden bağlanma tükendiğinde) ──────────────────

class PlayerErrorOverlay extends StatelessWidget {
  final String channelName;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final VoidCallback onOpenExternal;
  final VoidCallback onReport;

  const PlayerErrorOverlay({
    super.key,
    required this.channelName,
    required this.message,
    required this.onRetry,
    required this.onBack,
    required this.onOpenExternal,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = playerAccent(context);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.82),
        alignment: Alignment.center,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (channelName.isNotEmpty) ...[
                  Text(channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                ],
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      autofocus: true,
                      style: FilledButton.styleFrom(
                          backgroundColor: accent.accent,
                          foregroundColor: accent.onAccent),
                      onPressed: onRetry,
                      child: Text(l.retry),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: onBack,
                      child: Text(l.playerErrorBackToList),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.tealAccent),
                  onPressed: onOpenExternal,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.playerOpenExternal),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  onPressed: onReport,
                  icon: const Icon(Icons.bug_report_outlined, size: 18),
                  label: Text(l.playerReportError),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "X konumundan devam edilsin mi?" — true = devam, false = baştan, null = kapatıldı.
Future<bool?> showResumeDialog(BuildContext context, Duration position) {
  final l = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Text(l.playerResumeQuestion(formatPlayerDuration(position))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.playerResumeFromBeginning),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.playerResumeContinue),
        ),
      ],
    ),
  );
}

String formatPlayerDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
