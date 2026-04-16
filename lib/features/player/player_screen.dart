import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/analytics/analytics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../home/home_provider.dart';
import 'widgets/subtitle_overlay.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String channelUrl;
  final String title;
  final int    initialPosition; // ms — VOD resume icin
  final String streamType;      // 'live' | 'movie' | 'series'

  const PlayerScreen({
    super.key,
    required this.channelId,
    required this.channelUrl,
    required this.title,
    this.initialPosition = 0,
    this.streamType      = 'live',
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player       _player;
  late final VideoController _controller;
  bool    _controlsVisible = true;
  Timer?  _hideTimer;

  // ── Stall watchdog (canli yayin donma tespiti) ─────────────────────────────
  Timer?   _watchdog;
  Duration _lastPosition = Duration.zero;
  DateTime _lastProgress = DateTime.now();
  bool     _isBuffering  = false;
  bool     _isReconnecting = false;
  int      _reconnectAttempts = 0;
  StreamSubscription<bool>?     _playingSub;
  StreamSubscription<bool>?     _bufferingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<String>?   _errorSub;
  StreamSubscription<bool>?     _completedSub;

  bool _aiSubtitleEnabled = false;

  // Takildi sayilan esik (saniye). IPTV kaynak donmasinda bu surede
  // pozisyon ilerlemezse otomatik yeniden baglan.
  static const _stallThreshold = Duration(seconds: 8);
  // Sadece buffering'de ise biraz daha sabirli ol (agda gecici tikanma).
  static const _bufferingStallThreshold = Duration(seconds: 12);
  static const _maxReconnectAttempts = 10;

  @override
  void initState() {
    super.initState();
    _player     = Player(
      configuration: const PlayerConfiguration(
        // Canli yayin icin buffer'i genisletip jitter'a dayaniklilik saglar.
        bufferSize: 32 * 1024 * 1024, // 32 MB
      ),
    );
    _controller = VideoController(_player);
    _applyLiveStreamOptions();
    _play();
    _attachListeners();
    _startWatchdog();
    _startHideTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Mark channel as watched
    Future.microtask(() => ref
        .read(homeProvider.notifier)
        .markWatched(widget.channelId));
  }

  /// libmpv/FFmpeg icin HLS ve genel ag kopmalarina karsi otomatik
  /// yeniden baglanma ayarlari. Provider-side donmalarda segment/manifest
  /// indirme basarisiz olunca FFmpeg kendi basina yeniden dener.
  Future<void> _applyLiveStreamOptions() async {
    final platform = _player.platform;
    if (platform == null) return;
    try {
      // dynamic cast: NativePlayer.setProperty(name, value)
      final dynamic native = platform;
      // FFmpeg lavf reconnect ayarlari (HLS, HTTP/TS, mp4 vs.)
      await native.setProperty(
        'stream-lavf-o',
        'reconnect=1,'
        'reconnect_streamed=1,'
        'reconnect_delay_max=5,'
        'reconnect_on_network_error=1,'
        'reconnect_on_http_error=4xx,5xx,'
        'reconnect_at_eof=1,'
        'rw_timeout=15000000', // 15 sn I/O timeout (mikrosaniye)
      );
      // Canli yayinda geride kalmayi engelle (live edge'e yakin kal).
      await native.setProperty('cache', 'yes');
      await native.setProperty('cache-secs', '10');
      await native.setProperty('demuxer-max-bytes', '50MiB');
      await native.setProperty('demuxer-max-back-bytes', '25MiB');
      // Network error'da otomatik yeniden dene.
      await native.setProperty('network-timeout', '15');
      // HLS canli yayinda buffer dolunca frame atla (geride kalmayalim).
      await native.setProperty('hr-seek', 'yes');
    } catch (_) {
      // Opsiyonlar uygulanamazsa sessizce devam et.
    }
  }

  void _attachListeners() {
    _playingSub = _player.stream.playing.listen((playing) {
      // Oynatiliyorsa progress zamanini guncelle.
      if (playing) {
        _lastProgress = DateTime.now();
      }
    });
    _bufferingSub = _player.stream.buffering.listen((buffering) {
      if (!mounted) return;
      setState(() => _isBuffering = buffering);
    });
    _positionSub = _player.stream.position.listen((pos) {
      // Pozisyon degistiginde watchdog sayacini resetle.
      if (pos != _lastPosition) {
        _lastPosition = pos;
        _lastProgress = DateTime.now();
        if (_reconnectAttempts != 0) {
          _reconnectAttempts = 0; // basarili oynatim, sayaci sifirla
        }
      }
    });
    _errorSub = _player.stream.error.listen((err) {
      debugPrint('[Player] error: $err');
      Analytics.playbackError(
          errorCode: err, streamType: widget.streamType);
      _scheduleReconnect(reason: 'error: $err');
    });
    _completedSub = _player.stream.completed.listen((completed) {
      // Canli yayinlarda completed genelde stream kopmasidir.
      if (completed) {
        _scheduleReconnect(reason: 'stream ended (live)');
      }
    });
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _isReconnecting) return;
      final since = DateTime.now().difference(_lastProgress);
      final threshold =
          _isBuffering ? _bufferingStallThreshold : _stallThreshold;
      if (since > threshold) {
        _scheduleReconnect(
            reason: 'stall ${since.inSeconds}s (buffering=$_isBuffering)');
      }
    });
  }

  Future<void> _scheduleReconnect({required String reason}) async {
    if (_isReconnecting || !mounted) return;
    _isReconnecting = true;
    _reconnectAttempts++;
    debugPrint('[Player] reconnect #$_reconnectAttempts → $reason');

    if (_reconnectAttempts > _maxReconnectAttempts) {
      _isReconnecting = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yayin kaynaginda surekli kesinti. Kanali degistirmeyi deneyin.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Exponential-ish backoff: 0, 1, 2, 3, 4, 5, 5, 5...
    final delay = Duration(seconds: (_reconnectAttempts - 1).clamp(0, 5));
    await Future.delayed(delay);
    if (!mounted) return;

    try {
      await _player.stop();
      await _player.open(Media(widget.channelUrl), play: true);
      _lastProgress = DateTime.now();
      _lastPosition = Duration.zero;
    } catch (e) {
      debugPrint('[Player] reconnect failed: $e');
    } finally {
      _isReconnecting = false;
    }
  }

  void _play() {
    _player.open(Media(widget.channelUrl));
    // VOD resume: canli yayinda resume olmaz, sadece film/dizi.
    if (widget.initialPosition > 0 && widget.streamType != 'live') {
      // Player acilinca stream hazir olunca seek et.
      _player.stream.playing.firstWhere((p) => p).then((_) {
        if (mounted) {
          _player.seek(Duration(milliseconds: widget.initialPosition));
        }
      }).ignore();
    }
  }

  void _manualReconnect() {
    _reconnectAttempts = 0;
    _lastProgress = DateTime.now();
    _scheduleReconnect(reason: 'manual');
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  @override
  void dispose() {
    // VOD resume: pozisyonu kaydet (canli yayinda anlamsiz).
    if (widget.streamType != 'live') {
      final pos = _player.state.position.inMilliseconds;
      final dur = _player.state.duration.inMilliseconds;
      if (pos > 0) {
        ref.read(homeProvider.notifier).markWatched(
          widget.channelId,
          position: pos,
          duration: dur,
        );
      }
    }
    _hideTimer?.cancel();
    _watchdog?.cancel();
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _positionSub?.cancel();
    _errorSub?.cancel();
    _completedSub?.cancel();
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    // Back button → exit (en yuksek oncelik, her zaman calisir)
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.goBack) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }

    // Play/Pause: Space, Enter, mediaPlayPause, Select, numpadEnter, gameButtonA
    if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.gameButtonA) {
      // Eger kontroller gorunmuyorsa once goster, ikinci basista play/pause
      if (!_controlsVisible) {
        _showControls();
        return KeyEventResult.handled;
      }
      _player.playOrPause();
      _showControls();
      return KeyEventResult.handled;
    }

    // Seek 10s forward/backward
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.mediaFastForward) {
      _seekRelative(const Duration(seconds: 10));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.mediaRewind) {
      _seekRelative(const Duration(seconds: -10));
      _showControls();
      return KeyEventResult.handled;
    }

    // Volume up/down (sistem ses tuslari)
    if (key == LogicalKeyboardKey.audioVolumeUp) {
      final vol = _player.state.volume;
      _player.setVolume((vol + 10).clamp(0, 100));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.audioVolumeDown) {
      final vol = _player.state.volume;
      _player.setVolume((vol - 10).clamp(0, 100));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.audioVolumeMute) {
      final vol = _player.state.volume;
      _player.setVolume(vol > 0 ? 0 : 100);
      _showControls();
      return KeyEventResult.handled;
    }

    // Up/Down → controls goster + ses ayarla
    if (key == LogicalKeyboardKey.arrowUp) {
      final vol = _player.state.volume;
      _player.setVolume((vol + 5).clamp(0, 100));
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      final vol = _player.state.volume;
      _player.setVolume((vol - 5).clamp(0, 100));
      _showControls();
      return KeyEventResult.handled;
    }

    // Menu tusu → kontrolleri toggle et
    if (key == LogicalKeyboardKey.contextMenu ||
        key == LogicalKeyboardKey.f1 ||
        key == LogicalKeyboardKey.info) {
      if (_controlsVisible) {
        setState(() => _controlsVisible = false);
        _hideTimer?.cancel();
      } else {
        _showControls();
      }
      return KeyEventResult.handled;
    }

    // Medya tuslari
    if (key == LogicalKeyboardKey.mediaStop) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }

    // Any other key → show controls
    _showControls();
    return KeyEventResult.ignored;
  }

  void _seekRelative(Duration delta) {
    final cur = _player.state.position;
    final dur = _player.state.duration;
    var target = cur + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (dur > Duration.zero && target > dur) target = dur;
    _player.seek(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: GestureDetector(
          onTap: _showControls,
          child: Stack(
            children: [
            // Video
            Center(
              child: Video(controller: _controller),
            ),

            // AI Subtitle overlay
            SubtitleOverlay(
              channelId: widget.channelId,
              streamUrl: widget.channelUrl,
              streamType: widget.streamType,
              positionStream: _player.stream.position,
              enabled: _aiSubtitleEnabled,
            ),

            // Buffering / reconnect indicator
            if (_isBuffering || _isReconnecting)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isReconnecting
                          ? 'Yeniden baglaniliyor${_reconnectAttempts > 1 ? " ($_reconnectAttempts)" : ""}...'
                          : 'Yukleniyor...',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Controls overlay — gizlendiginde focus tree'den cikar,
            // yoksa gorunmez butonlara D-pad ile atlanir.
            if (_controlsVisible)
              AnimatedOpacity(
                opacity:  1.0,
                duration: const Duration(milliseconds: 250),
                child: _ControlsOverlay(
                  player:           _player,
                  title:            widget.title,
                  onClose:          () => Navigator.pop(context),
                  onTap:            _showControls,
                  onReconnect:      _manualReconnect,
                  volume:           _player.state.volume,
                  subtitleEnabled:  _aiSubtitleEnabled,
                  onSubtitleToggle: () => setState(
                      () => _aiSubtitleEnabled = !_aiSubtitleEnabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Controls overlay ──────────────────────────────────────────────────────────

class _ControlsOverlay extends StatefulWidget {
  final Player      player;
  final String      title;
  final VoidCallback onClose;
  final VoidCallback onTap;
  final VoidCallback onReconnect;
  final double       volume;
  final bool         subtitleEnabled;
  final VoidCallback onSubtitleToggle;

  const _ControlsOverlay({
    required this.player,
    required this.title,
    required this.onClose,
    required this.onTap,
    required this.onReconnect,
    required this.volume,
    required this.subtitleEnabled,
    required this.onSubtitleToggle,
  });

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [
              Color(0xCC000000),
              Colors.transparent,
              Colors.transparent,
              Color(0xCC000000),
            ],
            stops: [0, 0.25, 0.75, 1],
          ),
        ),
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: _TvIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Geri',
                      onTap: widget.onClose,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   TextSize.titleSm,
                          fontWeight: FontWeight.w600),
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: _TvIconButton(
                      icon: Icons.refresh,
                      tooltip: 'Yeniden baglan',
                      onTap: widget.onReconnect,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Center play/pause (TV-friendly: buyuk, focusable)
            FocusTraversalOrder(
              order: const NumericFocusOrder(3),
              child: StreamBuilder<bool>(
                stream: widget.player.stream.playing,
                builder: (ctx, snap) {
                  final playing = snap.data ?? false;
                  return _PlayPauseButton(
                    playing: playing,
                    onTap: widget.player.playOrPause,
                  );
                },
              ),
            ),

            const Spacer(),

            // Bottom seek bar + time + volume indicator
            StreamBuilder<Duration>(
              stream: widget.player.stream.duration,
              builder: (ctx, durSnap) {
                final duration = durSnap.data ?? Duration.zero;
                final isLive   = duration == Duration.zero;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.lg, 0, Spacing.lg, Spacing.xl),
                  child: Column(
                    children: [
                      // Volume indicator (kumandayla ses ayarlandığında gorulur)
                      StreamBuilder<double>(
                        stream: widget.player.stream.volume,
                        builder: (ctx, volSnap) {
                          final vol = volSnap.data ?? 100.0;
                          return Row(
                            children: [
                              Icon(
                                vol <= 0
                                    ? Icons.volume_off
                                    : vol < 50
                                        ? Icons.volume_down
                                        : Icons.volume_up,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 80,
                                child: LinearProgressIndicator(
                                  value: vol / 100,
                                  backgroundColor: Colors.white12,
                                  color: AppColors.accent,
                                  minHeight: 3,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('${vol.round()}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11)),
                              const Spacer(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.sm),

                      if (!isLive)
                        StreamBuilder<Duration>(
                          stream: widget.player.stream.position,
                          builder: (ctx, posSnap) {
                            final pos = posSnap.data ?? Duration.zero;
                            // Progress bar (dokunmatik icin Slider yerine
                            // gorsel bar + kumanda ok tuslariyla seek)
                            final progress = duration.inMilliseconds > 0
                                ? (pos.inMilliseconds / duration.inMilliseconds)
                                    .clamp(0.0, 1.0)
                                : 0.0;
                            return Column(
                              children: [
                                // Seek bar — kumandayla sol/sag ok ile kontrol
                                // edilir, touch'ta dokunarak seek yapılır
                                GestureDetector(
                                  onTapDown: (details) {
                                    final box = context.findRenderObject()
                                        as RenderBox?;
                                    if (box == null) return;
                                    final localX = details.localPosition.dx;
                                    final width = box.size.width;
                                    final ratio = (localX / width).clamp(0.0, 1.0);
                                    final ms = (ratio * duration.inMilliseconds)
                                        .toInt();
                                    final cap =
                                        (duration.inMilliseconds - 3000)
                                            .clamp(0, duration.inMilliseconds);
                                    widget.player.seek(
                                        Duration(milliseconds: ms.clamp(0, cap)));
                                  },
                                  child: Container(
                                    height: 24, // buyuk dokunma alani
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: progress,
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppColors.accent,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_fmt(pos),
                                        style: const TextStyle(
                                            color:    Colors.white70,
                                            fontSize: TextSize.caption)),
                                    // Ortada kumanda ipucu
                                    const Text('◄ 10s ►',
                                        style: TextStyle(
                                            color: Colors.white30,
                                            fontSize: 10)),
                                    Text(_fmt(duration),
                                        style: const TextStyle(
                                            color:    Colors.white70,
                                            fontSize: TextSize.caption)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      if (isLive)
                        const Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.live, size: 8),
                            SizedBox(width: 6),
                            Text('CANLI',
                                style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   TextSize.caption,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ],
                        ),
                      const SizedBox(height: Spacing.sm),
                      // AI subtitle + speed + audio tracks + mute
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3.5),
                            child: _TvIconButton(
                              icon: widget.subtitleEnabled
                                  ? Icons.subtitles
                                  : Icons.subtitles_off_outlined,
                              tooltip: widget.subtitleEnabled
                                  ? 'AI Altyazi Kapat'
                                  : 'AI Altyazi Ac',
                              onTap: widget.onSubtitleToggle,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(4),
                            child: _SpeedButton(player: widget.player),
                          ),
                          const SizedBox(width: Spacing.sm),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(5),
                            child: _AudioTrackButton(player: widget.player),
                          ),
                          const SizedBox(width: Spacing.sm),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(6),
                            child: StreamBuilder<double>(
                              stream: widget.player.stream.volume,
                              builder: (ctx, snap) {
                                final vol = snap.data ?? 100.0;
                                return _TvIconButton(
                                  icon: vol > 0
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  tooltip: vol > 0 ? 'Sessize al' : 'Sesi ac',
                                  onTap: () => widget.player
                                      .setVolume(vol > 0 ? 0 : 100),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h  = d.inHours;
    final m  = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s  = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

// ── TV-friendly icon button with visible focus ring ─────────────────────────

class _TvIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TvIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_TvIconButton> createState() => _TvIconButtonState();
}

class _TvIconButtonState extends State<_TvIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _focused
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : Colors.transparent,
              border: Border.all(
                color: _focused ? AppColors.accent : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

// ── Play/Pause button (TV-friendly: autofocus + scale-on-focus) ───────────────

class _PlayPauseButton extends StatefulWidget {
  final bool playing;
  final VoidCallback onTap;
  const _PlayPauseButton({required this.playing, required this.onTap});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _focused
                ? AppColors.accent.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _focused ? AppColors.accent : Colors.transparent,
              width: 3,
            ),
          ),
          padding: EdgeInsets.all(_focused ? 24 : 20),
          child: Icon(
            widget.playing ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 44,
          ),
        ),
      ),
    );
  }
}

// ── Audio track button (TV-friendly dialog) ───────────────────────────────────

class _AudioTrackButton extends StatefulWidget {
  final Player player;
  const _AudioTrackButton({required this.player});

  @override
  State<_AudioTrackButton> createState() => _AudioTrackButtonState();
}

class _AudioTrackButtonState extends State<_AudioTrackButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tracks>(
      stream: widget.player.stream.tracks,
      builder: (ctx, tracksSnap) {
        final tracks = tracksSnap.data;
        final audioTracks = tracks?.audio ?? [];
        if (audioTracks.length <= 1) return const SizedBox.shrink();

        return StreamBuilder<Track>(
          stream: widget.player.stream.track,
          builder: (ctx, trackSnap) {
            final current = trackSnap.data;
            return _TvIconButton(
              icon: Icons.audiotrack,
              tooltip: 'Ses parcasi',
              onTap: () => _showAudioDialog(
                  context, widget.player, audioTracks, current?.audio),
            );
          },
        );
      },
    );
  }

  static Future<void> _showAudioDialog(
    BuildContext context,
    Player player,
    List<AudioTrack> tracks,
    AudioTrack? current,
  ) async {
    final selected = await showDialog<AudioTrack>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Ses parçası'),
        children: tracks.map((t) {
          final label = t.title?.isNotEmpty == true
              ? t.title!
              : t.language?.isNotEmpty == true
                  ? t.language!
                  : 'Parça ${tracks.indexOf(t) + 1}';
          final isSelected = current == t;
          return _TvDialogOption(
            autofocus: isSelected,
            selected: isSelected,
            label: label,
            onTap: () => Navigator.pop(ctx, t),
          );
        }).toList(),
      ),
    );
    if (selected != null) player.setAudioTrack(selected);
  }
}

// ── TV-friendly dialog option (D-pad Enter/Select/gameButtonA support) ──────

class _TvDialogOption extends StatefulWidget {
  final bool autofocus;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _TvDialogOption({
    required this.autofocus,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TvDialogOption> createState() => _TvDialogOptionState();
}

class _TvDialogOptionState extends State<_TvDialogOption> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _focused
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                  widget.selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.label,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: _focused
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Speed button (TV-friendly dialog) ─────────────────────────────────────────

class _SpeedButton extends StatefulWidget {
  final Player player;
  const _SpeedButton({required this.player});

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  double _speed = 1.0;
  bool _focused = false;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> _showSpeedDialog() async {
    final selected = await showDialog<double>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Oynatma hızı'),
        children: _speeds.map((s) {
          final isSel = s == _speed;
          return _TvDialogOption(
            autofocus: isSel,
            selected: isSel,
            label: '${s}x',
            onTap: () => Navigator.pop(ctx, s),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      setState(() => _speed = selected);
      widget.player.setRate(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          _showSpeedDialog();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _showSpeedDialog,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _focused
                ? AppColors.accent.withValues(alpha: 0.3)
                : Colors.transparent,
            border: Border.all(
              color: _focused ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text('${_speed}x',
                  style: const TextStyle(
                      color: Colors.white, fontSize: TextSize.label)),
            ],
          ),
        ),
      ),
    );
  }
}
