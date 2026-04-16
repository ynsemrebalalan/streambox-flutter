import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/subtitle_cue.dart';
import '../../../data/services/whisper_service.dart';

/// AI altyazi overlay widget'i.
/// Player pozisyonuna gore aktif cue'yu gosterir,
/// arka planda sonraki segment'i prefetch eder.
class SubtitleOverlay extends StatefulWidget {
  final String channelId;
  final String streamUrl;
  final String streamType;
  final Stream<Duration> positionStream;
  final bool enabled;
  // Styling
  final Color textColor;
  final Color bgColor;
  final double fontSize;

  const SubtitleOverlay({
    super.key,
    required this.channelId,
    required this.streamUrl,
    required this.streamType,
    required this.positionStream,
    this.enabled = false,
    this.textColor = Colors.white,
    this.bgColor = const Color(0xAA000000),
    this.fontSize = 16,
  });

  @override
  State<SubtitleOverlay> createState() => _SubtitleOverlayState();
}

class _SubtitleOverlayState extends State<SubtitleOverlay> {
  final _whisper = WhisperService();
  final _cues = <SubtitleCue>[];
  String _currentText = '';
  Timer? _prefetchTimer;
  StreamSubscription<Duration>? _posSub;
  int _lastFetchedSegment = -1;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _start();
  }

  @override
  void didUpdateWidget(SubtitleOverlay old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !old.enabled) {
      _start();
    } else if (!widget.enabled && old.enabled) {
      _stop();
    }
  }

  void _start() {
    // Pozisyon dinle, aktif cue'yu bul
    _posSub = widget.positionStream.listen(_onPosition);
    // Prefetch timer: her 25 saniyede sonraki segment'i hazirla
    _prefetchTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _prefetchNext(),
    );
    // Ilk segment'i yukle
    _fetchSegment(0);
  }

  void _stop() {
    _posSub?.cancel();
    _prefetchTimer?.cancel();
    _cues.clear();
    if (mounted) setState(() => _currentText = '');
  }

  void _onPosition(Duration position) {
    final posMs = position.inMilliseconds;

    // Aktif cue'yu bul
    String text = '';
    for (final cue in _cues) {
      if (cue.isActive(posMs)) {
        text = cue.text;
        break;
      }
    }

    if (text != _currentText && mounted) {
      setState(() => _currentText = text);
    }

    // Yeni segment gerekiyorsa fetch et
    final currentSeg = posMs ~/ 60000;
    if (currentSeg != _lastFetchedSegment) {
      _fetchSegment(posMs ~/ 1000);
    }
  }

  Future<void> _fetchSegment(int startSec) async {
    if (_loading) return;
    _loading = true;
    try {
      final cues = await _whisper.transcribe(
        streamUrl: widget.streamUrl,
        channelId: widget.channelId,
        startSec: startSec,
      );
      _lastFetchedSegment = startSec ~/ 60;
      _cues.addAll(cues);
      // Eski cue'lari temizle (500'den fazla biriktirme)
      if (_cues.length > 500) {
        _cues.removeRange(0, _cues.length - 500);
      }
    } catch (e) {
      debugPrint('[SubtitleOverlay] fetch failed: $e');
    } finally {
      _loading = false;
    }
  }

  void _prefetchNext() {
    if (_lastFetchedSegment >= 0) {
      _fetchSegment((_lastFetchedSegment + 1) * 60);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _prefetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _currentText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _currentText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.textColor,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w500,
              height: 1.3,
              shadows: const [
                Shadow(offset: Offset(1, 1), blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
