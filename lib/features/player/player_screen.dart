import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../core/analytics/analytics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/channel_model.dart';
import '../../data/services/stalker/stalker_protocol.dart';
import '../../data/services/stalker/stalker_stream_resolver.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../home/home_provider.dart';
import '../parental/parental_guard.dart';
import '../settings/services/review_service.dart';
import 'logic/ai_error.dart';
import 'logic/ai_error_messages.dart';
import 'logic/next_episode.dart';
import 'logic/playback_error.dart';
import 'logic/playback_policy.dart';
import 'logic/supported_ai_languages.dart';
import 'logic/track_prefs.dart';
import 'services/ai_subtitle_gate.dart';
import 'services/airplay_service.dart';
import 'services/audio_session_service.dart';
import 'services/external_player.dart';
import 'services/pip_service.dart';
import 'services/player_system_ui.dart';
import 'services/player_prefs.dart';
import 'widgets/channel_panel.dart';
import 'widgets/error_report_dialog.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_overlays.dart';
import 'widgets/player_track_buttons.dart';
import 'widgets/subtitle_overlay.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String channelUrl;
  final String title;
  final int initialPosition; // ms — VOD resume
  final String streamType; // 'live' | 'movie' | 'series'

  const PlayerScreen({
    super.key,
    required this.channelId,
    required this.channelUrl,
    required this.title,
    this.initialPosition = 0,
    this.streamType = 'live',
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  // ── Stall watchdog / reconnect ────────────────────────────────────────────
  Timer? _watchdog;
  Duration _lastPosition = Duration.zero;
  DateTime _lastProgress = DateTime.now();
  bool _isBuffering = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  bool _disposed = false; // Future.delayed sonrası native player'a erişimi engeller
  final _subs = <StreamSubscription<dynamic>>[];
  String _lastError = '';
  String? _blockingError; // yeniden bağlanma tükendi → bloklayıcı hata ekranı

  static const _stallThreshold = Duration(seconds: 8);
  static const _bufferingStallThreshold = Duration(seconds: 12);
  static const _maxReconnectAttempts = 10;

  // ── Kanal / ayarlar ───────────────────────────────────────────────────────
  ChannelModel? _channel;
  /// Oynatılan gerçek URL — Stalker komutu (`ffrt http://localhost/..`)
  /// açılıştan önce `create_link` ile çözülür; diğer kaynaklarda aynısı.
  late String _playUrl = widget.channelUrl;
  PlayerPrefs _prefs = const PlayerPrefs();
  final _trackStore = TrackPrefStore();
  bool _trackPrefsApplied = false;
  bool _hasVideo = true;
  List<ChannelModel>? _categoryChannels;

  // ── VOD ilerleme ──────────────────────────────────────────────────────────
  Timer? _progressTimer;
  int _progressTicks = 0;
  bool _watchedMarked = false;
  bool _playbackCounted = false;
  bool _autoNextFired = false;
  final _endDetector = EndOfMediaDetector();

  // ── UI durumu ─────────────────────────────────────────────────────────────
  bool _aiSubtitleEnabled = false;
  BoxFit _videoFit = BoxFit.contain;
  bool _orientationLocked = false;
  double _volumeBeforeMute = 100;
  bool _inPipMode = false;
  bool _pipSupported = false;
  bool _airplaySupported = false;

  // Swipe: sol yarı parlaklık, sağ yarı ses (eşik 40 px, min parlaklık 0.05).
  double? _initialBrightness;
  double _gestureStartBrightness = 0.0;
  double _gestureStartVolume = 0.0;
  String _gestureType = '';
  double _gestureValue = 0.0;
  double _gestureAccDy = 0.0;
  Timer? _gestureHideTimer;
  static const _gestureMinDy = 40.0;
  Offset? _doubleTapPos;

  IconData? _actionIcon;
  String _actionText = '';
  Alignment _actionAlign = Alignment.center;
  Timer? _actionTimer;

  bool get _isLive => widget.streamType == 'live';

  void _showActionFeedback(IconData icon, String text, {Alignment align = Alignment.center}) {
    if (!mounted) return;
    setState(() {
      _actionIcon = icon;
      _actionText = text;
      _actionAlign = align;
    });
    _actionTimer?.cancel();
    _actionTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _actionText = '');
    });
  }

  @override
  void initState() {
    super.initState();
    _player = Player(configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024));
    _controller = VideoController(_player);
    // iOS: ses oturumu SADECE oynatma penceresinde aktif.
    // Ref-counted: kanal degisiminde (pushReplacement) eski ekranin
    // dispose'u yeninin actigi oturum/PiP/immersive'i geri kapatmasin.
    AudioSessionService.instance.activate();
    unawaited(PipService.instance.acquirePlayer());
    PlayerSystemUi.acquire();
    _applyOrientation();
    _setupAutoPip();
    _resolveCastButtons();
    _subs.add(PipService.instance.modeStream.listen((inPip) {
      if (mounted) setState(() => _inPipMode = inPip);
    }));
    ScreenBrightness().application.then((b) => _initialBrightness = b).catchError((_) => 0.0);
    _startHideTimer();
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await PlayerPrefs.load();
    } catch (_) {}
    try {
      _channel = await ref.read(channelRepoProvider).getById(widget.channelId);
    } catch (_) {}
    if (_disposed) return;
    if (mounted) setState(() {});
    // Çözülemezse dinleyiciler yine kurulur: hata ekranındaki Tekrar Dene
    // (reconnect) normal oynatma akışına döner.
    final resolved = await _resolvePlayUrl();
    await _applyStreamOptions();
    if (_disposed) return;
    _attachListeners();
    _startWatchdog();
    if (!_isLive) {
      _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _onProgressTick());
    }
    // VOD'da kayıtlı konumu sıfırlamadan "izlendi" damgası (son izlenenler).
    unawaited(ref.read(homeProvider.notifier).markWatched(
          widget.channelId,
          position: _isLive ? 0 : widget.initialPosition,
          duration: _channel?.duration ?? 0,
        ).catchError((_) {}));
    if (resolved) await _play();
  }

  /// Stalker linkini çözer (Stalker dışı: anında true). Başarısızsa
  /// bloklayıcı hata ekranı (Tekrar Dene → reconnect yeniden çözer).
  Future<bool> _resolvePlayUrl() async {
    if (!stalkerNeedsResolve(widget.channelUrl)) return true;
    String? url;
    try {
      url = await StalkerStreamResolver.resolveForPlaylist(
        ref.read(playlistRepoProvider),
        _channel?.playlistId,
        widget.channelUrl,
        lang: Localizations.localeOf(context).languageCode,
      );
    } catch (e) {
      debugPrint('[Player] stalker resolve failed: $e');
    }
    if (_disposed) return false;
    if (url == null || url.isEmpty) {
      _lastError = 'stalker create_link failed';
      if (mounted) setState(() => _blockingError = _lastError);
      return false;
    }
    _playUrl = url;
    return true;
  }

  /// FFmpeg reconnect + ön bellek + User-Agent (Android: `StreamBox/<ver>`).
  Future<void> _applyStreamOptions() async {
    final platform = _player.platform;
    if (platform is! NativePlayer) return;
    final opts = <String, String>{
      'stream-lavf-o': 'reconnect=1,reconnect_streamed=1,reconnect_delay_max=5,'
          'reconnect_on_network_error=1,reconnect_on_http_error=4xx,5xx,'
          'reconnect_at_eof=1,rw_timeout=15000000',
      'user-agent': _prefs.userAgent,
      'cache': 'yes',
      'cache-secs': '${cacheSecsForBufferMs(_prefs.bufferMs)}',
      'demuxer-readahead-secs': '${cacheSecsForBufferMs(_prefs.bufferMs)}',
      'demuxer-max-bytes': '50MiB',
      'demuxer-max-back-bytes': '25MiB',
      'network-timeout': '15',
      'hr-seek': 'yes',
    };
    for (final e in opts.entries) {
      try {
        await platform.setProperty(e.key, e.value);
      } catch (_) {}
    }
  }

  void _attachListeners() {
    _subs
      ..add(_player.stream.playing.listen((p) {
        if (p) _lastProgress = DateTime.now();
      }))
      ..add(_player.stream.buffering.listen((b) {
        if (mounted) setState(() => _isBuffering = b);
      }))
      ..add(_player.stream.position.listen((pos) {
        if (pos != _lastPosition) {
          _lastPosition = pos;
          _lastProgress = DateTime.now();
          _reconnectAttempts = 0;
          // Gercek oynatma (>=3 sn ilerleme): ilk oynatma analytics +
          // degerlendirme sayaci (Android ReviewHelper).
          if (!_playbackCounted && pos.inSeconds >= 3) {
            _playbackCounted = true;
            unawaited(PlaybackMilestones.onPlaybackStarted(streamType: widget.streamType));
          }
        }
      }))
      ..add(_player.stream.error.listen((err) {
        debugPrint('[Player] error: $err');
        _lastError = err;
        Analytics.playbackError(errorCode: err, streamType: widget.streamType);
        _scheduleReconnect(reason: 'error: $err');
      }))
      ..add(_player.stream.completed.listen((completed) {
        if (!completed) return;
        // Canlıda completed = kopma → reconnect; VOD'da bitti → sonraki bölüm.
        if (_isLive) {
          _scheduleReconnect(reason: 'stream ended (live)');
        } else {
          _onMediaEnded('completed');
        }
      }))
      ..add(_player.stream.tracks.listen(_onTracks));
  }

  // ── Parçalar: yalnız-ses tespiti + kayıtlı dil tercihleri ──────────────────

  Future<void> _onTracks(Tracks tracks) async {
    final video = realTracks(tracks.video, (t) => t.id);
    final audio = realTracks(tracks.audio, (t) => t.id);
    final hasVideo = video.isNotEmpty || audio.isEmpty;
    if (hasVideo != _hasVideo && mounted) setState(() => _hasVideo = hasVideo);

    if (_trackPrefsApplied || audio.isEmpty) return;
    _trackPrefsApplied = true;
    final subs = realTracks(tracks.subtitle, (t) => t.id);
    final ch = _channel;
    final prefs = ch == null ? null : await _trackStore.load(ch);
    if (_disposed) return;
    try {
      final a = pickByLanguage<AudioTrack>(audio, (t) => t.language, prefs?.audioLang);
      if (a != null) await _player.setAudioTrack(a);

      if (subs.isEmpty) return;
      final decided = prefs?.subtitleEnabled;
      if (decided == true) {
        final s = pickByLanguage<SubtitleTrack>(subs, (t) => t.language, prefs?.subtitleLang);
        if (s != null) await _player.setSubtitleTrack(s);
      } else if (decided == null && _prefs.subtitleDefaultOn && !_aiSubtitleEnabled) {
        // "Altyazı varsayılan açık": cihaz dilindeki parça, yoksa ilki.
        if (!mounted) return;
        final device = Localizations.localeOf(context).languageCode;
        final s = subs.firstWhere(
          (t) => (t.language ?? '').toLowerCase().startsWith(device),
          orElse: () => subs.first,
        );
        await _player.setSubtitleTrack(s);
      }
    } catch (e) {
      debugPrint('[Player] track prefs apply failed: $e');
    }
  }

  void _onAudioSelected(AudioTrack t) {
    final ch = _channel;
    if (ch != null) unawaited(_trackStore.saveAudio(ch, t.language));
  }

  void _onEmbeddedSubtitleSelected(SubtitleTrack? t) {
    final ch = _channel;
    if (ch != null) {
      unawaited(_trackStore.saveSubtitle(ch, enabled: t != null, lang: t?.language));
    }
  }

  // ── Watchdog / reconnect ──────────────────────────────────────────────────

  void _startWatchdog() {
    _watchdog?.cancel();
    // Yalnız canlıda: VOD'da büyük seek sırasında yanlış pozitif "stall" olur.
    if (!_isLive) return;
    _watchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _isReconnecting || _blockingError != null) return;
      if (!_player.state.playing) return;
      final since = DateTime.now().difference(_lastProgress);
      if (since > (_isBuffering ? _bufferingStallThreshold : _stallThreshold)) {
        _scheduleReconnect(reason: 'stall ${since.inSeconds}s (buffering=$_isBuffering)');
      }
    });
  }

  Future<void> _scheduleReconnect({required String reason}) async {
    if (_isReconnecting || !mounted || _blockingError != null) return;
    setState(() => _isReconnecting = true);
    _reconnectAttempts++;
    debugPrint('[Player] reconnect #$_reconnectAttempts → $reason');

    if (_reconnectAttempts > _maxReconnectAttempts) {
      if (_lastError.isEmpty) _lastError = reason;
      try {
        await _player.pause();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isReconnecting = false;
          _blockingError = _lastError;
        });
      }
      return;
    }

    await Future<void>.delayed(Duration(seconds: (_reconnectAttempts - 1).clamp(0, 5)));
    if (!mounted || _disposed) return;
    // VOD'da reconnect öncesi konumu koru.
    final preservePos = _isLive ? Duration.zero : _player.state.position;
    try {
      await _player.stop();
      // Stalker play_token'ları kısa ömürlü — her yeniden bağlanmada taze link.
      if (!await _resolvePlayUrl()) return;
      await _player.open(Media(_playUrl), play: true);
      if (preservePos > const Duration(seconds: 2)) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted && !_disposed) await _player.seek(preservePos);
      }
      _lastProgress = DateTime.now();
      _lastPosition = preservePos;
    } catch (e) {
      debugPrint('[Player] reconnect failed: $e');
    } finally {
      if (mounted) setState(() => _isReconnecting = false);
    }
  }

  void _manualReconnect() {
    _reconnectAttempts = 0;
    _lastProgress = DateTime.now();
    setState(() => _blockingError = null);
    _scheduleReconnect(reason: 'manual');
  }

  // ── Oynatma başlangıcı + resume ───────────────────────────────────────────

  Future<void> _play() async {
    final saved = widget.initialPosition;
    final offer = shouldOfferResume(
        savedMs: saved, streamType: widget.streamType, durationMs: _channel?.duration ?? 0);
    await _player.open(Media(_playUrl), play: !offer);
    if (!offer || !mounted) return;
    final resume = await showResumeDialog(context, Duration(milliseconds: saved));
    if (!mounted || _disposed) return;
    await _player.play();
    if (resume == true) {
      // Akış hazır olunca seek (play=true sonrası libmpv seek edilebilir hale gelir).
      _player.stream.playing.firstWhere((p) => p).then((_) {
        if (mounted && !_disposed) _player.seek(Duration(milliseconds: saved));
      }).ignore();
    }
  }

  // ── VOD ilerleme kaydı + bitiş tespiti ────────────────────────────────────

  void _onProgressTick() {
    if (_disposed || !mounted) return;
    final pos = _player.state.position.inMilliseconds;
    final dur = _player.state.duration.inMilliseconds;
    if (_endDetector.tick(
        positionMs: pos, durationMs: dur, playWhenReady: _player.state.playing)) {
      _onMediaEnded('position-stall');
    }
    _progressTicks++;
    // ~5 sn'de bir yerel kayıt → uygulama öldürülse/çökse de ilerleme korunur.
    if (_progressTicks % 10 == 0 && pos > 0) unawaited(_saveProgressLocal(pos, dur));
    if (!_watchedMarked && reachedWatchedThreshold(positionMs: pos, durationMs: dur)) {
      _watchedMarked = true;
      unawaited(ref.read(channelRepoProvider).markWatched(widget.channelId).catchError((_) {}));
    }
  }

  /// Yalnız yerel DB (bulut push'u her 5 sn'de yapılmasın diye
  /// ChannelRepository.updateWatched yerine). Bulut + Home satırları çıkışta
  /// homeProvider.markWatched ile güncellenir.
  Future<void> _saveProgressLocal(int pos, int dur) async {
    try {
      await ref.read(channelRepoProvider).updatePositionLocal(widget.channelId, pos, dur);
    } catch (e) {
      debugPrint('[Player] progress save failed: $e');
    }
  }

  Future<void> _persistProgress() async {
    if (_isLive) return;
    final pos = _player.state.position.inMilliseconds;
    final dur = _player.state.duration.inMilliseconds;
    if (pos <= 0) return;
    try {
      await ref.read(homeProvider.notifier).markWatched(widget.channelId, position: pos, duration: dur);
    } catch (_) {}
  }

  /// Bölüm bitti → sonraki bölüm (sezon atlama dahil), yoksa çık.
  Future<void> _onMediaEnded(String reason) async {
    if (_autoNextFired || _isLive || _disposed) return;
    _autoNextFired = true;
    final ch = _channel;
    ChannelModel? next;
    if (ch != null && ch.streamType == 'series' && ch.seriesName.isNotEmpty) {
      try {
        final eps = await ref.read(channelRepoProvider).getSeriesEpisodes(ch.playlistId, ch.seriesName);
        next = selectNextEpisode(ch, eps);
      } catch (e) {
        debugPrint('[Player] next episode lookup failed: $e');
      }
    }
    debugPrint('[Player] auto-next ($reason) → ${next?.name ?? "yok"}');
    if (!mounted || _disposed) return;
    if (next == null) {
      await _stopAndPop();
      return;
    }
    _showActionFeedback(Icons.skip_next, AppLocalizations.of(context).playerNextEpisode(next.name));
    final switched = await _switchTo(next);
    if (!switched && mounted) await _stopAndPop();
  }

  /// Oynatıcıdan çıkmadan başka içeriğe geç (route değiştirilir → temiz durum).
  /// Ebeveyn kilidi hedef kategori için de uygulanır.
  Future<bool> _switchTo(ChannelModel target) async {
    if (!await ensureCategoryUnlocked(context, ref, target.category)) return false;
    if (!mounted) return false;
    final router = GoRouter.of(context);
    await _persistProgress();
    try {
      await _player.stop();
    } catch (_) {}
    if (!mounted) return false;
    router.pushReplacement(AppRoutes.player, extra: {
      'channelId': target.id,
      'channelUrl': target.streamUrl,
      'title': target.name,
      'initialPosition': target.lastPosition,
      'streamType': target.streamType,
    });
    return true;
  }

  // ── Canlı: kanal paneli + önceki/sonraki ──────────────────────────────────

  Future<List<ChannelModel>> _loadCategoryChannels() async {
    final cached = _categoryChannels;
    if (cached != null) return cached;
    final ch = _channel;
    if (ch == null) return const [];
    final repo = ref.read(channelRepoProvider);
    var list = await repo.getByCategory(ch.playlistId, ch.streamType, ch.category);
    if (list.isEmpty) list = await repo.getByType(ch.playlistId, ch.streamType);
    return _categoryChannels = list;
  }

  Future<void> _openChannelPanel() async {
    final list = await _loadCategoryChannels();
    if (!mounted || list.isEmpty) return;
    final picked = await showChannelPanel(context, channels: list, currentId: widget.channelId);
    if (picked != null && mounted) await _switchTo(picked);
  }

  Future<void> _stepChannel(int delta) async {
    final list = await _loadCategoryChannels();
    if (list.length <= 1 || !mounted) return;
    final i = list.indexWhere((c) => c.id == widget.channelId);
    final next = list[((i < 0 ? 0 : i) + delta) % list.length];
    _showActionFeedback(delta > 0 ? Icons.skip_next : Icons.skip_previous, next.name);
    await _switchTo(next);
  }

  // ── Kontroller ────────────────────────────────────────────────────────────

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _seekRelative(int deltaMs, {Alignment align = Alignment.center}) {
    if (_isLive) return;
    final target = seekTargetMs(
      currentMs: _player.state.position.inMilliseconds,
      deltaMs: deltaMs,
      durationMs: _player.state.duration.inMilliseconds,
    );
    _player.seek(Duration(milliseconds: target));
    // Büyük seek'te konum bir süre sabit kalabilir — sayaçları sıfırla.
    _lastPosition = Duration(milliseconds: target);
    _lastProgress = DateTime.now();
    final l = AppLocalizations.of(context);
    _showActionFeedback(deltaMs < 0 ? Icons.replay_10 : Icons.forward_10,
        deltaMs < 0 ? l.playerSeekBackward : l.playerSeekForward,
        align: align);
  }

  void _onDoubleTap() {
    final pos = _doubleTapPos;
    if (pos == null || _isLive) return;
    final left = pos.dx < MediaQuery.of(context).size.width / 2;
    _seekRelative(left ? -10000 : 10000,
        align: left ? Alignment.centerLeft : Alignment.centerRight);
  }

  void _toggleMute() {
    final l = AppLocalizations.of(context);
    final vol = _player.state.volume;
    if (vol > 0) {
      _volumeBeforeMute = vol;
      _player.setVolume(0);
      _showActionFeedback(Icons.volume_off, l.playerMuted);
    } else {
      _player.setVolume(_volumeBeforeMute > 0 ? _volumeBeforeMute : 100);
      _showActionFeedback(Icons.volume_up, l.playerUnmuted);
    }
  }

  void _applyOrientation() {
    if (!_orientationLocked) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      return;
    }
    final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    SystemChrome.setPreferredOrientations(landscape
        ? const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : const [DeviceOrientation.portraitUp]);
  }

  void _toggleOrientationLock() {
    final l = AppLocalizations.of(context);
    setState(() => _orientationLocked = !_orientationLocked);
    _applyOrientation();
    _showActionFeedback(
      _orientationLocked ? Icons.screen_lock_rotation : Icons.screen_rotation,
      _orientationLocked ? l.playerOrientationLock : l.playerOrientationUnlocked,
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.browserBack ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.mediaStop) {
      Navigator.maybePop(context);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.gameButtonA) {
      if (!_controlsVisible) {
        _showControls();
        return KeyEventResult.handled;
      }
      _player.playOrPause();
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.mediaFastForward) {
      _seekRelative(10000);
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.mediaRewind) {
      _seekRelative(-10000);
      _showControls();
      return KeyEventResult.handled;
    }
    if (_isLive && (key == LogicalKeyboardKey.channelUp || key == LogicalKeyboardKey.channelDown)) {
      _stepChannel(key == LogicalKeyboardKey.channelUp ? 1 : -1);
      return KeyEventResult.handled;
    }
    final volStep = switch (key) {
      LogicalKeyboardKey.audioVolumeUp => 10,
      LogicalKeyboardKey.audioVolumeDown => -10,
      LogicalKeyboardKey.arrowUp => 5,
      LogicalKeyboardKey.arrowDown => -5,
      _ => 0,
    };
    if (volStep != 0) {
      _player.setVolume((_player.state.volume + volStep).clamp(0, 100).toDouble());
      _showControls();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.audioVolumeMute) {
      _toggleMute();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.contextMenu ||
        key == LogicalKeyboardKey.f1 ||
        key == LogicalKeyboardKey.info) {
      _toggleControls();
      return KeyEventResult.handled;
    }
    _showControls();
    return KeyEventResult.ignored;
  }

  // ── Swipe (parlaklık / ses) ───────────────────────────────────────────────

  Future<void> _onVerticalDragStart(DragStartDetails d) async {
    final isRight = d.localPosition.dx > MediaQuery.of(context).size.width / 2;
    _gestureType = isRight ? 'volume' : 'brightness';
    _gestureAccDy = 0;
    _gestureStartVolume = _player.state.volume / 100.0;
    if (!isRight) {
      try {
        _gestureStartBrightness = await ScreenBrightness().application;
      } catch (_) {
        _gestureStartBrightness = 0.5;
      }
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_gestureType.isEmpty) return;
    _gestureAccDy += d.delta.dy;
    if (_gestureAccDy.abs() < _gestureMinDy) return;
    final ratio = -_gestureAccDy / MediaQuery.of(context).size.height;
    if (_gestureType == 'volume') {
      final v = (_gestureStartVolume + ratio).clamp(0.0, 1.0);
      _player.setVolume(v * 100);
      setState(() => _gestureValue = v);
    } else {
      final b = (_gestureStartBrightness + ratio).clamp(0.05, 1.0);
      ScreenBrightness().setApplicationScreenBrightness(b).catchError((_) {});
      setState(() => _gestureValue = b);
    }
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    _gestureHideTimer?.cancel();
    _gestureHideTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _gestureType = '');
    });
  }

  // ── Çıkış ─────────────────────────────────────────────────────────────────

  /// Pop ÖNCESİ ilerlemeyi kaydet ve sesi kesin durdur (dispose async değil).
  Future<void> _stopAndPop() async {
    await _persistProgress();
    try { await _player.setVolume(0); } catch (_) {}
    try { await _player.pause(); } catch (_) {}
    try { await _player.stop(); } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  // ── PiP / AirPlay ─────────────────────────────────────────────────────────

  Future<void> _resolveCastButtons() async {
    await PipService.instance.ensureInitialized();
    final airplay = await AirplayService.instance.isAvailable();
    if (!mounted) return;
    setState(() {
      _pipSupported = PipService.instance.isSupported;
      _airplaySupported = airplay;
    });
  }

  Future<void> _setupAutoPip() async {
    try {
      await PipService.instance.ensureInitialized();
      final autoPref = await ref.read(settingsRepoProvider).get('pip_auto_enabled') == 'true';
      if (_disposed) return;
      await PipService.instance.setAutoPipForActivePlayer(ref.read(isProProvider) && autoPref);
    } catch (e) {
      debugPrint('[Player] auto-PiP setup failed: $e');
    }
  }

  Future<void> _enterPip() async {
    final l = AppLocalizations.of(context);
    if (!PipService.instance.isSupported) {
      _showSnack(l.playerPipUnavailable);
      return;
    }
    final allowed = await requirePro(context, ref, PaywallTrigger.pip);
    if (!allowed || !mounted) return;
    if (!await PipService.instance.enter() && mounted) _showSnack(l.playerPipUnavailable);
  }

  Future<void> _showAirplay() async {
    final l = AppLocalizations.of(context);
    if (!_airplaySupported) {
      _showSnack(l.playerAirplayUnavailable);
      return;
    }
    _showSnack(l.playerAirplayAudioOnlyHint, duration: const Duration(seconds: 5));
    await AirplayService.instance.showRoutePicker();
  }

  void _showSnack(String msg, {Duration duration = const Duration(seconds: 3)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: duration));
  }

  // ── AI altyazı (yalnız VOD) ───────────────────────────────────────────────

  bool _aiGateBusy = false;

  Future<void> _toggleAiSubtitle() async {
    if (_isLive) return;
    if (_aiSubtitleEnabled) {
      setState(() => _aiSubtitleEnabled = false);
      return;
    }
    if (_aiGateBusy) return;
    _aiGateBusy = true;
    try {
      final ok = await runAiSubtitleGate(context, ref);
      if (ok && mounted) setState(() => _aiSubtitleEnabled = true);
    } finally {
      _aiGateBusy = false;
    }
  }

  Future<void> _onAiError(AiError e, {required bool initial}) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    if (e.code == AiErrorCode.proRequired) {
      setState(() => _aiSubtitleEnabled = false);
      final purchased = await showAiTrialEndedPaywall(context, ref);
      if (purchased && mounted) setState(() => _aiSubtitleEnabled = true);
      return;
    }
    if (initial && e.code != AiErrorCode.noSpeech) {
      setState(() => _aiSubtitleEnabled = false);
    }
    _showSnack(aiErrorMessage(l, e.code), duration: const Duration(seconds: 4));
  }

  // ── Bloklayıcı hata ──────────────────────────────────────────────────────

  String _blockingMessage(AppLocalizations l, String raw) =>
      switch (classifyPlaybackError(raw)) {
        PlaybackErrorKind.unsupportedFormat => l.playerErrorUnsupportedFormat,
        PlaybackErrorKind.corruptStream => l.playerErrorCorruptStream,
        PlaybackErrorKind.unavailable => l.playerErrorStreamUnavailable,
      };

  Future<void> _openExternal() async {
    final l = AppLocalizations.of(context);
    final r = await openInExternalPlayer(_playUrl);
    if (r != ExternalPlayerResult.opened) _showSnack(l.playerExternalNotFound);
  }

  @override
  void dispose() {
    _disposed = true;
    if (_playbackCounted) unawaited(PlaybackMilestones.maybeRequestReview());
    _hideTimer?.cancel();
    _gestureHideTimer?.cancel();
    _actionTimer?.cancel();
    _watchdog?.cancel();
    _progressTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    if (_initialBrightness != null) {
      ScreenBrightness().setApplicationScreenBrightness(_initialBrightness!).catchError((_) {});
    } else {
      ScreenBrightness().resetApplicationScreenBrightness().catchError((_) {});
    }
    // Ref-counted: yalnız SON player kapanınca PiP/oturum/sistem UI geri
    // yüklenir (kanal değişiminde yeni ekran zaten aktif).
    unawaited(PipService.instance.releasePlayer());
    _player.stop().catchError((_) {});
    _player.dispose();
    AudioSessionService.instance.deactivate();
    PlayerSystemUi.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = _prefs.subtitleStyle;
    final ch = _channel;
    final title = ch?.name.isNotEmpty == true && widget.title.isEmpty ? ch!.name : widget.title;
    final targetLang = resolveAiTargetLang(
        pref: _prefs.aiTargetPref, deviceLang: Localizations.localeOf(context).languageCode);
    final controlsShown = _controlsVisible && !_inPipMode && _blockingError == null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _stopAndPop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          autofocus: true,
          onKeyEvent: _onKeyEvent,
          child: GestureDetector(
            onTap: _toggleControls,
            onDoubleTapDown: _isLive ? null : (d) => _doubleTapPos = d.localPosition,
            onDoubleTap: _isLive ? null : _onDoubleTap,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Stack(
              children: [
                Center(
                  child: Video(
                    controller: _controller,
                    controls: (_) => const SizedBox.shrink(),
                    fit: _videoFit,
                    // Gömülü altyazı Flutter SubtitleView ile çizilir (libass kapalı)
                    // → kullanıcı stil ayarı burada uygulanır.
                    subtitleViewConfiguration: SubtitleViewConfiguration(
                      style: TextStyle(
                        height: 1.4,
                        fontSize: style.fontSize,
                        color: style.textColor,
                        backgroundColor: style.backgroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textScaler: TextScaler.noScaling,
                      padding: EdgeInsets.fromLTRB(16, 0, 16, controlsShown ? 120 : 24),
                    ),
                  ),
                ),
                if (!_hasVideo)
                  AudioOnlyOverlay(title: title, logoUrl: ch?.logoUrl ?? ''),
                if (!_isLive)
                  SubtitleOverlay(
                    channelId: widget.channelId,
                    streamUrl: _playUrl,
                    positionStream: _player.stream.position,
                    currentPositionMs: () => _player.state.position.inMilliseconds,
                    durationMs: () => _player.state.duration.inMilliseconds,
                    enabled: _aiSubtitleEnabled,
                    targetLang: targetLang,
                    providerLabel: _prefs.aiProvider,
                    userAgent: _prefs.userAgent,
                    bannerEnabled: _prefs.aiBannerEnabled,
                    style: style,
                    bottomPadding: controlsShown ? 140 : 48,
                    onError: _onAiError,
                  ),
                if ((_isBuffering || _isReconnecting) && _blockingError == null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        const SizedBox(height: 12),
                        Text(
                          _isReconnecting
                              ? (_reconnectAttempts > 1
                                  ? l.playerReconnectingMulti(_reconnectAttempts)
                                  : l.playerReconnecting)
                              : l.playerLoading,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                // Her zaman agacta: AnimatedOpacity ile solar (8 sn auto-hide
                // davranisi ayni). PiP'te tamamen kaldirilir.
                if (!_inPipMode)
                  PlayerControlsOverlay(
                    visible: controlsShown,
                    player: _player,
                    title: title,
                    streamType: widget.streamType,
                    channelId: widget.channelId,
                    channel: ch,
                    onClose: _stopAndPop,
                    onReconnect: _manualReconnect,
                    aiEnabled: _aiSubtitleEnabled,
                    onAiToggle: _toggleAiSubtitle,
                    onEmbeddedSubtitleSelected: _onEmbeddedSubtitleSelected,
                    onAudioSelected: _onAudioSelected,
                    videoFit: _videoFit,
                    onFitChange: (f) {
                      setState(() => _videoFit = f);
                      _showActionFeedback(Icons.aspect_ratio, l.playerFeedbackFit(fitLabel(l, f)));
                    },
                    onPip: _enterPip,
                    onAirplay: _showAirplay,
                    showPip: _pipSupported,
                    showAirplay: _airplaySupported,
                    onFeedback: (i, t) => _showActionFeedback(i, t),
                    onSeekRelative: _seekRelative,
                    onToggleMute: _toggleMute,
                    orientationLocked: _orientationLocked,
                    onToggleOrientation: _toggleOrientationLock,
                    onChannelPanel: _isLive && ch != null ? _openChannelPanel : null,
                    onPrevChannel: _isLive && ch != null ? () => _stepChannel(-1) : null,
                    onNextChannel: _isLive && ch != null ? () => _stepChannel(1) : null,
                  ),
                if (_gestureType.isNotEmpty)
                  GestureValueOverlay(type: _gestureType, value: _gestureValue),
                if (_actionText.isNotEmpty)
                  ActionFeedbackOverlay(
                    icon: _actionIcon,
                    text: _actionText,
                    alignment: _actionAlign,
                    controlsVisible: controlsShown,
                  ),
                if (_blockingError != null)
                  PlayerErrorOverlay(
                    channelName: title,
                    message: _blockingMessage(l, _blockingError!),
                    onRetry: _manualReconnect,
                    onBack: _stopAndPop,
                    onOpenExternal: _openExternal,
                    onReport: () => showErrorReportDialog(
                      context,
                      channelName: title,
                      errorMessage: _blockingError!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
