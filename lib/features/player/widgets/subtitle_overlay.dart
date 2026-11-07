import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/analytics/analytics.dart';
import '../../../data/models/subtitle_cue.dart';
import '../../../data/services/whisper_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../logic/ai_error.dart';
import '../logic/audio_segment.dart';
import '../logic/subtitle_style.dart';
import '../logic/supported_ai_languages.dart';

/// AI altyazı overlay'i (yalnızca VOD).
///
/// * Açıldığı ANKİ konumdan başlar (eskiden hep 0. saniyeden üretiyordu).
/// * Segment sonuna 20 sn kala sonrakini ön-tamponlar; sarmada yeni segmenti üretir.
/// * İlk segment hazırlanırken 3 sn geri sayım + "hazırlanıyor" (Android parite).
/// * İlk başarıdan sonra 5 sn kaynak/hedef dil banner'ı (ayardan kapatılabilir).
/// * Hata kodları [onError] ile üst katmana iletilir (paywall / snackbar kararı orada).
class SubtitleOverlay extends StatefulWidget {
  final String channelId;
  final String streamUrl;
  final Stream<Duration> positionStream;
  final int Function() currentPositionMs;
  final int Function() durationMs;
  final bool enabled;
  final String targetLang;
  final String providerLabel;
  final String? userAgent;
  final bool bannerEnabled;
  final SubtitleStyleSettings style;
  final double bottomPadding;

  /// [initial] true: ilk segment (kullanıcı az önce açtı) hatası.
  final void Function(AiError error, {required bool initial})? onError;

  const SubtitleOverlay({
    super.key,
    required this.channelId,
    required this.streamUrl,
    required this.positionStream,
    required this.currentPositionMs,
    required this.durationMs,
    required this.targetLang,
    this.providerLabel = 'groq',
    this.enabled = false,
    this.userAgent,
    this.bannerEnabled = true,
    this.style = const SubtitleStyleSettings(),
    this.bottomPadding = 80,
    this.onError,
  });

  @override
  State<SubtitleOverlay> createState() => _SubtitleOverlayState();
}

class _SubtitleOverlayState extends State<SubtitleOverlay> {
  static const _prefetchLeadMs = 20000;
  static const _failRetryAfter = Duration(seconds: 30);

  final _whisper = WhisperService();
  final _cuesBySegment = <int, List<SubtitleCue>>{};
  // Multiset (liste): _stop sonrası eski üretim iptal edilirken yenisi
  // başlayabilir; her _fetch yalnız KENDİ kaydını siler.
  final _inFlight = <int>[];
  final _failedAt = <int, DateTime>{};
  StreamSubscription<Duration>? _posSub;
  Timer? _countdownTimer;
  Timer? _bannerTimer;
  String _currentText = '';
  int _countdown = 0;
  bool _initialLoading = false;
  bool _bannerVisible = false;
  int _session = 0; // açma/kapama yarışlarında eski sonuçları at

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _start();
  }

  @override
  void didUpdateWidget(SubtitleOverlay old) {
    super.didUpdateWidget(old);
    final restart = old.targetLang != widget.targetLang ||
        old.streamUrl != widget.streamUrl;
    if (widget.enabled && (!old.enabled || restart)) {
      _stop();
      _start();
    } else if (!widget.enabled && old.enabled) {
      _stop();
    }
  }

  void _start() {
    _session++;
    _posSub = widget.positionStream.listen(_onPosition);
    final startSec = widget.currentPositionMs() ~/ 1000;
    setState(() {
      _initialLoading = true;
      _countdown = 3;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown = (_countdown - 1).clamp(0, 3));
      if (_countdown == 0) t.cancel();
    });
    _fetch(alignSegmentSec(startSec), initial: true);
  }

  void _stop() {
    _session++;
    _posSub?.cancel();
    _posSub = null;
    _countdownTimer?.cancel();
    _bannerTimer?.cancel();
    _cuesBySegment.clear();
    // _inFlight TEMİZLENMEZ: süren üretim bitene kadar ikinci bir mpv
    // çıkarımı başlamasın; süren iş iptal edilir (ağ + mpv) ve hızla biter.
    _whisper.cancelInFlight();
    _failedAt.clear();
    if (mounted) {
      setState(() {
        _currentText = '';
        _initialLoading = false;
        _countdown = 0;
        _bannerVisible = false;
      });
    }
  }

  void _onPosition(Duration position) {
    final posMs = position.inMilliseconds;
    final seg = alignSegmentSec(posMs ~/ 1000);

    // Overlap'te en yeni cue kazanır (Android lastOrNull).
    // HLS klibi segment sınırından biraz önce başlayabilir → önceki segmente de bak.
    String text = '';
    for (final k in [seg - kWhisperSegmentSec, seg]) {
      for (final c in _cuesBySegment[k] ?? const <SubtitleCue>[]) {
        if (c.isActive(posMs)) text = c.text;
      }
    }
    if (text != _currentText && mounted) setState(() => _currentText = text);

    _ensureSegment(seg);
    final segEndMs = (seg + kWhisperSegmentSec) * 1000;
    final dur = widget.durationMs();
    if (segEndMs - posMs <= _prefetchLeadMs && (dur <= 0 || segEndMs < dur)) {
      _ensureSegment(seg + kWhisperSegmentSec);
    }
  }

  void _ensureSegment(int seg) {
    // Aynı anda tek üretim (her biri ayrı bir mpv çıkarımı + ağ isteği).
    if (_cuesBySegment.containsKey(seg) || _inFlight.isNotEmpty) return;
    final failed = _failedAt[seg];
    if (failed != null && DateTime.now().difference(failed) < _failRetryAfter) return;
    _fetch(seg);
  }

  Future<void> _fetch(int segSec, {bool initial = false}) async {
    final session = _session;
    _inFlight.add(segSec);
    final sw = Stopwatch()..start();
    try {
      final r = await _whisper.transcribe(
        streamUrl: widget.streamUrl,
        channelId: widget.channelId,
        startSec: segSec,
        targetLang: widget.targetLang,
        userAgent: widget.userAgent,
        mediaDurationMs: widget.durationMs(),
      );
      if (!mounted || session != _session) return;
      _cuesBySegment[segSec] = r.cues;
      _trimSegments(segSec);
      if (r.provider != 'cache') {
        Analytics.aiSubtitleGenerated(
          provider: r.provider,
          cueCount: r.cues.length,
          durationMs: sw.elapsedMilliseconds,
        );
      }
      if (initial) {
        if (r.cues.isEmpty) {
          widget.onError?.call(const AiError(AiErrorCode.noSpeech), initial: true);
        } else {
          _showBanner();
        }
      }
    } on AiError catch (e) {
      if (!mounted || session != _session) return;
      _failedAt[segSec] = DateTime.now();
      Analytics.aiSubtitleError(errorType: e.analyticsCode, provider: widget.providerLabel);
      debugPrint('[SubtitleOverlay] $e');
      // Sonraki segmentlerde akışı bozma; deneme bitti (PRO_REQUIRED) ise her zaman bildir.
      if (initial || e.code == AiErrorCode.proRequired) {
        widget.onError?.call(e, initial: initial);
      }
    } catch (e) {
      if (!mounted || session != _session) return;
      _failedAt[segSec] = DateTime.now();
      Analytics.aiSubtitleError(errorType: 'exception', provider: widget.providerLabel);
      if (initial) {
        widget.onError?.call(AiError(AiErrorCode.generic, detail: '$e'), initial: true);
      }
    } finally {
      _inFlight.remove(segSec);
      if (initial && mounted && session == _session) {
        _countdownTimer?.cancel();
        setState(() {
          _initialLoading = false;
          _countdown = 0;
        });
      }
    }
  }

  /// Bellekte en fazla mevcut segmentin ±2 komşusu tutulur.
  void _trimSegments(int around) {
    _cuesBySegment.removeWhere(
        (k, _) => (k - around).abs() > 2 * kWhisperSegmentSec);
  }

  void _showBanner() {
    if (!widget.bannerEnabled) return;
    setState(() => _bannerVisible = true);
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _bannerVisible = false);
    });
  }

  @override
  void dispose() {
    _whisper.cancelInFlight();
    _posSub?.cancel();
    _countdownTimer?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }

  static final _rtl = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final style = widget.style;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            if (_bannerVisible)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: _Pill(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Text(
                      l.playerBannerWhisper(
                          SupportedAiLanguages.displayName(widget.targetLang)),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            if (_initialLoading && _countdown > 0)
              Center(child: _Countdown(seconds: _countdown, label: l.playerAiPreparing))
            else if (_initialLoading && _currentText.isEmpty)
              Positioned(
                bottom: widget.bottomPadding,
                left: 24,
                right: 24,
                child: Center(child: _LoadingPill(label: l.playerAiPreparing, style: style)),
              ),
            if (_currentText.isNotEmpty)
              Positioned(
                bottom: widget.bottomPadding,
                left: 32,
                right: 32,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: style.backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _currentText,
                      textAlign: TextAlign.center,
                      textDirection: _rtl.hasMatch(_currentText)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: style.fontSize,
                        fontWeight: FontWeight.w500,
                        height: 1.375,
                        shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 3)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;
  const _Pill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: child,
      );
}

class _Countdown extends StatelessWidget {
  final int seconds;
  final String label;
  const _Countdown({required this.seconds, required this.label});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(color: Colors.tealAccent),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(l.playerSecondsShort(seconds),
              style: const TextStyle(color: Colors.tealAccent, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  final String label;
  final SubtitleStyleSettings style;
  const _LoadingPill({required this.label, required this.style});

  @override
  Widget build(BuildContext context) => _Pill(
        color: Colors.black.withValues(alpha: 0.67),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('$label…',
                style: TextStyle(color: style.textColor, fontSize: style.fontSize - 2)),
          ],
        ),
      );
}
