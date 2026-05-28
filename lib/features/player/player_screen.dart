import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../core/analytics/analytics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/channel_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../home/home_provider.dart';
import 'services/airplay_service.dart';
import 'services/pip_service.dart';
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
  /// 2026-05-25: dispose() sonrasinda _player'a erisim (race fix).
  /// mounted bayragi yetersiz — Future.delayed sirasinda widget'tan
  /// kopuldugunda native player pointer'ina seek crash yapabilir.
  bool     _disposed = false;
  StreamSubscription<bool>?     _playingSub;
  StreamSubscription<bool>?     _bufferingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<String>?   _errorSub;
  StreamSubscription<bool>?     _completedSub;

  bool _aiSubtitleEnabled = false;
  BoxFit _videoFit = BoxFit.contain; // 20.2: Original=contain | Fill=cover | Stretch=fill

  // ── Phase 4: PiP / AirPlay durumu ──────────────────────────────────────────
  bool _inPipMode = false;
  StreamSubscription<bool>? _pipModeSub;

  // ── Swipe gesture state (sol yarı = parlaklık, sağ yarı = ses) ──────────────
  // Android paritesi (StreamBox PlayerScreen.kt). Tuzaklar: memory
  // `feedback_brightness_gesture_init.md` — drag eşiği 40px, min brightness
  // 0.05, dispose'da restore zorunlu.
  double? _initialBrightness;       // dispose'da geri yüklenir
  double  _gestureStartBrightness = 0.0;
  double  _gestureStartVolume = 0.0;
  String  _gestureType  = '';        // '' | 'volume' | 'brightness'
  double  _gestureValue = 0.0;       // 0..1 — overlay'de gösterilir
  double  _gestureAccDy = 0.0;       // toplam dy
  Timer?  _gestureHideTimer;
  static const _gestureMinDy = 40.0; // titremeden ayırt etmek için

  // ── Aksiyon feedback overlay (her buton işleminde kısa "uyarı") ─────────────
  // Kullanıcı hangi butona basarsa bassın ekran ortasında kısa süreli bir pill
  // belirir (örn: "Duraklatıldı", "+10 sn", "Altyazı: TR"). TV/kumanda ile
  // kullanımda işlemin gerçekleştiğini görmek kritik.
  IconData? _actionIcon;
  String    _actionText = '';
  Timer?    _actionTimer;

  void _showActionFeedback(IconData icon, String text) {
    if (!mounted) return;
    setState(() {
      _actionIcon = icon;
      _actionText = text;
    });
    _actionTimer?.cancel();
    _actionTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() {
          _actionText = '';
          _actionIcon = null;
        });
      }
    });
  }

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
    // Bug #1 fix: iOS Portrait Lock acikken player landscape'e donmuyordu.
    // Player ekranina ozel olarak landscape orientation'lari aciyoruz.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Mark channel as watched
    Future.microtask(() => ref
        .read(homeProvider.notifier)
        .markWatched(widget.channelId));

    // ── Phase 4: PiP — auto-PiP setup. Pro user + auto pref ON ise
    //    Home tusuna basinca otomatik PiP'e gec.
    _setupAutoPip();
    _pipModeSub = PipService.instance.modeStream.listen((inPip) {
      if (mounted) setState(() => _inPipMode = inPip);
    });
    // İlk parlaklık değerini sakla — dispose'da bu değere geri dön.
    // Ekrana özel override yapmadığımız sürece sistem değeri.
    ScreenBrightness().application.then((b) {
      _initialBrightness = b;
    }).catchError((_) {});
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
      // Canli yayinlarda completed genelde stream kopmasidir → reconnect.
      // VOD/film/dizi'de completed normaldir (video bitti) → reconnect ETME.
      // 2026-05-25 (kullanici raporu: VOD'da ileri alinca basa donuyor).
      if (completed && widget.streamType == 'live') {
        _scheduleReconnect(reason: 'stream ended (live)');
      }
    });
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    // 2026-05-25: Sadece canli yayinlarda watchdog calistir. VOD/film/dizi'de
    // libmpv kendi reconnect/buffer mantigini yapiyor; ayrica buyuk bir seek
    // sirasinda position 8+ sn ayni kalabilir → yanlis pozitif "stall" →
    // _scheduleReconnect _player.open(...) cagiriyor ve kullanicinin ileri
    // aldigi yer kayboluyor (basa donuyor). Sleuth raporu, kullanici #1.
    if (widget.streamType != 'live') return;
    _watchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _isReconnecting) return;
      // 2026-05-11: Pause sırasında stall sayma. Kullanıcı bilerek pause
      // yaptıysa watchdog reconnect tetiklemesin (yanlış pozitif).
      if (!_player.state.playing) return;
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
    // 2026-05-11: setState ile UI'a yansıyor — reconnect banner görünür.
    setState(() => _isReconnecting = true);
    _reconnectAttempts++;
    debugPrint('[Player] reconnect #$_reconnectAttempts → $reason');

    if (_reconnectAttempts > _maxReconnectAttempts) {
      if (mounted) setState(() => _isReconnecting = false);
      if (mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.playerStreamRepeatedError),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Exponential-ish backoff: 0, 1, 2, 3, 4, 5, 5, 5...
    final delay = Duration(seconds: (_reconnectAttempts - 1).clamp(0, 5));
    await Future.delayed(delay);
    if (!mounted) return;

    // 2026-05-25: VOD'da reconnect öncesi mevcut pozisyonu yakala — gercek
    // bir error / nadir race durumunda bile kullanici izlediği yeri
    // kaybetmesin. Live'da pozisyon korumanın anlami yok (kanal akiş
    // basindan baslar). Sleuth raporu Fix #3.
    final preservePos = widget.streamType != 'live'
        ? _player.state.position
        : Duration.zero;

    try {
      await _player.stop();
      await _player.open(Media(widget.channelUrl), play: true);
      if (preservePos > const Duration(seconds: 2)) {
        // libmpv open ile play=true başladıktan sonra seek edilebilir
        // duruma kısa sürede gelir; 500ms guard pratikte yeterli.
        await Future.delayed(const Duration(milliseconds: 500));
        // _disposed bayragi: Future.delayed sirasinda widget kapatildiysa
        // _player'a seek ETMEYELIM (native crash riski).
        if (mounted && !_disposed) {
          await _player.seek(preservePos);
        }
      }
      _lastProgress = DateTime.now();
      _lastPosition = preservePos;
    } catch (e) {
      debugPrint('[Player] reconnect failed: $e');
    } finally {
      if (mounted) setState(() => _isReconnecting = false);
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
    // 4 sn çok kısaydı — kullanıcı kontrol panellerini bulmadan kayboluyordu.
    // 8 sn modern video oynatıcı standartı (YouTube/VLC/Netflix mobile).
    _hideTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  /// Bug #4 fix: tap koşulsuz `_showControls()` çağırıyordu; toggle değildi.
  /// D-pad menü tuşundaki (LogicalKeyboardKey.contextMenu) pattern ile aynı:
  /// görünürse gizle, gizliyse göster.
  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  @override
  void dispose() {
    // 2026-05-25 race fix: _scheduleReconnect Future.delayed sonrasi seek
    // cagrisi widget dispose olduktan sonra calismaya devam ederse native
    // player'a crash yapabilir. _disposed bayragi ile guvene al.
    _disposed = true;
    // Bug #9 fix: VOD resume markWatched dispose'da fire-and-forget cagriliyordu;
    // hizli cikiste DB write tamamlanmadan tear down oluyordu. Artik
    // _stopAndPop() icinde await ile cagriliyor — burada sadece guvenli fallback
    // (cikis sirasinda _stopAndPop devre disi kalirsa diye) tutmuyoruz.
    _hideTimer?.cancel();
    _gestureHideTimer?.cancel();
    _actionTimer?.cancel();
    // Parlaklık override'ını kaldır — kullanıcı player'da değiştirdiyse
    // restore et, yoksa sistem default'una geri dön.
    if (_initialBrightness != null) {
      ScreenBrightness()
          .setApplicationScreenBrightness(_initialBrightness!)
          .catchError((_) {});
    } else {
      ScreenBrightness().resetApplicationScreenBrightness().catchError((_) {});
    }
    _watchdog?.cancel();
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _positionSub?.cancel();
    _errorSub?.cancel();
    _completedSub?.cancel();
    _pipModeSub?.cancel();
    // PiP auto-mode kapat (player kapanirken Home tusu PiP'e gecmesin).
    PipService.instance.setPlayerActive(false);
    PipService.instance.setAutoPip(false);
    // Explicit stop önce — bazı backend'lerde (özellikle iOS AVPlayer +
    // Android MediaSession aktif olduğunda) sadece dispose() background'da
    // playback'i sustaramaz; stop() native pipeline'ı tertip eder. Future
    // fire-and-forget — dispose sync sözleşmesini bozmaz.
    _player.stop().catchError((_) {});
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Bug #1 fix: player kapanirken orientation'i portrait'e geri kilitle —
    // diger ekranlar (home, splash) landscape kalmasin.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
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
    // 2026-05-25: Buyuk seek sirasinda libmpv yeni segmenti indirirken
    // position 5-10+ sn ayni kalabilir → watchdog yanlis pozitif "stall"
    // tetiklemesin diye sayaclari hemen sifirla. Live'da watchdog disable
    // edildi ama defansif olarak burada da reset.
    _lastPosition = target;
    _lastProgress = DateTime.now();
  }

  // ── Swipe gesture handlers ───────────────────────────────────────────────────

  void _onVerticalDragStart(DragStartDetails d) async {
    final width = MediaQuery.of(context).size.width;
    final isRightSide = d.localPosition.dx > width / 2;
    _gestureType   = isRightSide ? 'volume' : 'brightness';
    _gestureAccDy  = 0;
    _gestureStartVolume = _player.state.volume / 100.0; // 0..1
    if (!isRightSide) {
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
    // Eşiğin altında: titreme/phantom touch — overlay gösterme
    if (_gestureAccDy.abs() < _gestureMinDy) return;

    final height = MediaQuery.of(context).size.height;
    // Yukarı = artır, aşağı = azalt → -dy ratio
    final ratio = -_gestureAccDy / height;

    if (_gestureType == 'volume') {
      final newVol = (_gestureStartVolume + ratio).clamp(0.0, 1.0);
      _player.setVolume(newVol * 100);
      setState(() => _gestureValue = newVol);
    } else {
      // Min 0.05 — kullanıcı ekranı tamamen siyaha indirmesin
      final newBright = (_gestureStartBrightness + ratio).clamp(0.05, 1.0);
      ScreenBrightness()
          .setApplicationScreenBrightness(newBright)
          .catchError((_) {});
      setState(() => _gestureValue = newBright);
    }
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    // Overlay 800ms görünür kalsın, sonra fade
    _gestureHideTimer?.cancel();
    _gestureHideTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _gestureType = '');
    });
  }

  /// Player'ı kapatmadan önce ses/video'yu kesin durdur, sonra route'tan çık.
  ///
  /// [dispose] async olamadığı için sadece `_player.dispose()` çağırmak ses
  /// pipeline'ını anında susturmuyor (native thread asenkron biter, kullanıcı
  /// Home'a dönünce 1-2 saniye daha ses duyabiliyor). Bu helper hem custom
  /// back button (`onClose`) hem sistem back tuşu (`PopScope`) tarafından
  /// çağrılır → pop **öncesi** await ile stop sequence garanti edilir.
  Future<void> _stopAndPop() async {
    // Bug #9 fix: VOD resume — markWatched() onceden dispose() icinde
    // fire-and-forget cagriliyordu; hizli cikis senaryolarinda DB write
    // tamamlanmadan widget agaci tear down oluyordu. Artik pop oncesi
    // await ile cagriyoruz, position guvenli sekilde kayit edilir.
    if (widget.streamType != 'live') {
      final pos = _player.state.position.inMilliseconds;
      final dur = _player.state.duration.inMilliseconds;
      if (pos > 0) {
        try {
          await ref.read(homeProvider.notifier).markWatched(
            widget.channelId,
            position: pos,
            duration: dur,
          );
        } catch (_) {}
      }
    }
    try { await _player.setVolume(0);     } catch (_) {}
    try { await _player.pause();          } catch (_) {}
    try { await _player.stop();           } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  /// Phase 4: PiP — Pro auto-mode ayarini DB'den oku, native'e ilet.
  /// Player aktiflik bayragi da set edilir → onUserLeaveHint dogru karar verir.
  Future<void> _setupAutoPip() async {
    try {
      await PipService.instance.ensureInitialized();
      await PipService.instance.setPlayerActive(true);
      final repo = SettingsRepository();
      final autoPref = await repo.get('pip_auto_enabled') == 'true';
      final isPro = ref.read(isProProvider);
      // Auto-PiP sadece Pro user'a + tercih ON ise aktif.
      await PipService.instance.setAutoPip(isPro && autoPref);
    } catch (e) {
      debugPrint('[Player] auto-PiP setup failed: $e');
    }
  }

  /// Phase 4: PiP — manuel buton. Pro check + native enter.
  Future<void> _enterPip() async {
    if (!PipService.instance.isSupported) {
      _showSnack(AppLocalizations.of(context).playerPipUnavailable);
      return;
    }
    final allowed = await requirePro(context, ref, PaywallTrigger.pip);
    if (!allowed || !mounted) return;
    final ok = await PipService.instance.enter();
    if (!ok && mounted) {
      _showSnack(AppLocalizations.of(context).playerPipUnavailable);
    }
  }

  /// Phase 4: AirPlay — manuel buton. Pro check + AirPlay sheet.
  Future<void> _showAirplay() async {
    final available = await AirplayService.instance.isAvailable();
    if (!mounted) return;
    if (!available) {
      _showSnack(AppLocalizations.of(context).playerAirplayUnavailable);
      return;
    }
    final allowed = await requirePro(context, ref, PaywallTrigger.airplay);
    if (!allowed || !mounted) return;
    await AirplayService.instance.showRoutePicker();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  /// Adim 22 Phase D: AI altyazi gating.
  /// Kapali → açıyorsa Pro check; aksi durumda dogrudan kapat.
  Future<void> _toggleAiSubtitle() async {
    if (_aiSubtitleEnabled) {
      // Aciksa → kapat (Pro gerektirmez).
      setState(() => _aiSubtitleEnabled = false);
      return;
    }
    final allowed =
        await requirePro(context, ref, PaywallTrigger.aiSubtitle);
    if (!allowed || !mounted) return;
    setState(() => _aiSubtitleEnabled = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      // canPop:false + manuel pop — sistem back tuşu (Android back / iOS edge
      // swipe) tetiklendiğinde önce stop bekleyelim, sonra pop. Default
      // davranış pop'u önce çalıştırıyor, _stopAndPop fırsatı bulamadan
      // dispose() tetikleniyordu.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _stopAndPop();
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: GestureDetector(
          onTap: _toggleControls,
          onVerticalDragStart:  _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd:    _onVerticalDragEnd,
          child: Stack(
            children: [
            // Video — media_kit_video default MaterialVideoControls'i KAPAT.
            // Bizim custom overlay (Stack icindeki _PlayPauseButton + seek bar
            // + ust bar) zaten butun kontrolleri sagliyor. Default controls'u
            // birakirsak iki play/pause butonu ust uste cikiyor.
            Center(
              child: Video(
                controller: _controller,
                controls: (_) => const SizedBox.shrink(),
                fit: _videoFit,
              ),
            ),

            // AI Subtitle overlay
            SubtitleOverlay(
              channelId: widget.channelId,
              streamUrl: widget.channelUrl,
              streamType: widget.streamType,
              positionStream: _player.stream.position,
              enabled: _aiSubtitleEnabled,
              onError: (msg) {
                if (!mounted) return;
                setState(() => _aiSubtitleEnabled = false);
                _showSnack(msg);
              },
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
                          ? (_reconnectAttempts > 1
                              ? l.playerReconnectingMulti(_reconnectAttempts)
                              : l.playerReconnecting)
                          : l.playerLoading,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Controls overlay — gizlendiginde focus tree'den cikar,
            // yoksa gorunmez butonlara D-pad ile atlanir.
            // PiP modundayken kontroller hep gizli (mini pencerede gorunmemeli).
            if (_controlsVisible && !_inPipMode)
              AnimatedOpacity(
                opacity:  1.0,
                duration: const Duration(milliseconds: 250),
                child: _ControlsOverlay(
                  player:           _player,
                  title:            widget.title,
                  onClose:          _stopAndPop,
                  onTap:            _toggleControls,
                  onReconnect:      _manualReconnect,
                  volume:           _player.state.volume,
                  subtitleEnabled:  _aiSubtitleEnabled,
                  onSubtitleToggle: _toggleAiSubtitle,
                  videoFit:         _videoFit,
                  onFitChange:      (f) {
                    setState(() => _videoFit = f);
                    _showActionFeedback(
                      Icons.aspect_ratio,
                      switch (f) {
                        BoxFit.cover => 'Görüntü: Doldur',
                        BoxFit.fill  => 'Görüntü: Esnet',
                        _            => 'Görüntü: Orijinal',
                      },
                    );
                  },
                  onPip:            _enterPip,
                  onAirplay:        _showAirplay,
                  onFeedback:       _showActionFeedback,
                  streamType:       widget.streamType,
                  channelId:        widget.channelId,
                ),
              ),
            // Swipe gesture feedback overlay — sol yarı parlaklık, sağ yarı ses
            if (_gestureType.isNotEmpty)
              _GestureOverlay(
                type:  _gestureType,
                value: _gestureValue,
              ),
            // Aksiyon feedback pill — buton işlemlerinde kısa süreli görünür.
            if (_actionText.isNotEmpty)
              _ActionFeedbackOverlay(icon: _actionIcon, text: _actionText),
            ],
          ),
        ),
      ),
      ),  // PopScope close
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
  final BoxFit              videoFit;
  final ValueChanged<BoxFit> onFitChange;
  final VoidCallback onPip;
  final VoidCallback onAirplay;
  /// Her buton işleminde ekran ortasında kısa süreli pill göstermek için.
  final void Function(IconData icon, String text) onFeedback;
  final String      streamType;       // 'live' | 'movie' | 'series'
  final String      channelId;        // Favori toggle için (2026-05-11)

  const _ControlsOverlay({
    required this.player,
    required this.title,
    required this.onClose,
    required this.onTap,
    required this.onReconnect,
    required this.volume,
    required this.subtitleEnabled,
    required this.onSubtitleToggle,
    required this.videoFit,
    required this.onFitChange,
    required this.onPip,
    required this.onAirplay,
    required this.onFeedback,
    required this.streamType,
    required this.channelId,
  });

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
        // Gradient tum alani kaplasin ama icerik (butonlar, seekbar, vs)
        // SafeArea icinde kalsin — iPhone notch/Dynamic Island/home
        // indicator + landscape'te yan kameralar.
        child: SafeArea(
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
                      tooltip: l.back,
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
                  // Phase 4 — AirPlay (iOS Pro)
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1.7),
                    child: _TvIconButton(
                      icon: Icons.airplay,
                      tooltip: l.playerAirplayTooltip,
                      onTap: widget.onAirplay,
                    ),
                  ),
                  // Phase 4 — PiP (Android Pro)
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1.8),
                    child: _TvIconButton(
                      icon: Icons.picture_in_picture_alt,
                      tooltip: l.playerPipTooltip,
                      onTap: widget.onPip,
                    ),
                  ),
                  // Favori toggle — 2026-05-11 kullanıcı isteği.
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1.9),
                    child: _FavoriteButton(channelId: widget.channelId),
                  ),                  // _ControlsOverlay scope — widget.channelId burada available
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: _TvIconButton(
                      icon: Icons.refresh,
                      tooltip: l.playerReconnectTooltip,
                      onTap: widget.onReconnect,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Center play/pause + 10s seek butonları (TV+touch friendly)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TvIconButton(
                  icon: Icons.replay_10,
                  tooltip: '-10s',
                  onTap: () {
                    widget.player.seek(
                      widget.player.state.position -
                          const Duration(seconds: 10),
                    );
                    widget.onFeedback(Icons.replay_10, '-10 sn');
                  },
                  size: 32,
                ),
                const SizedBox(width: Spacing.xl),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3),
                  child: StreamBuilder<bool>(
                    stream: widget.player.stream.playing,
                    builder: (ctx, snap) {
                      final playing = snap.data ?? false;
                      return _PlayPauseButton(
                        playing: playing,
                        // 2026-05-11: Explicit play/pause — playOrPause toggle
                        // bazen state race'inde ters atıyor. Mevcut state'e
                        // göre kesin komut.
                        onTap: () {
                          if (widget.player.state.playing) {
                            widget.player.pause();
                            widget.onFeedback(Icons.pause, 'Duraklatıldı');
                          } else {
                            widget.player.play();
                            widget.onFeedback(Icons.play_arrow, 'Oynatılıyor');
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: Spacing.xl),
                _TvIconButton(
                  icon: Icons.forward_10,
                  tooltip: '+10s',
                  onTap: () {
                    final pos = widget.player.state.position;
                    final dur = widget.player.state.duration;
                    var target = pos + const Duration(seconds: 10);
                    if (dur > Duration.zero && target > dur) target = dur;
                    widget.player.seek(target);
                    widget.onFeedback(Icons.forward_10, '+10 sn');
                  },
                  size: 32,
                ),
              ],
            ),

            const Spacer(),

            // Bottom seek bar + time. Sol alttaki sabit ses göstergesi
            // kaldırıldı (kullanıcı isteği) — gesture sırasında ekran ortasında
            // beliren overlay zaten görsel feedback sağlıyor.
            //
            // 2026-05-26: Tek StreamBuilder (position). Duration sync API ile
            // alinir — `widget.player.stream.duration` bazi IPTV VOD'larinda
            // hic emit etmiyordu, eski iç içe StreamBuilder yapisinda onChanged:
            // null donderiyordu (Slider disabled) ve dokunulamiyordu.
            // state.duration genelde dolu — degilse seek bar kapatip izlemeye
            // devam edilebilir.
            Builder(
              builder: (ctx) {
                final isLive = widget.streamType == 'live';
                if (isLive) {
                  // Canli yayinda seek bar yok, sadece kirmizi rozet.
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Spacing.lg, 0, Spacing.lg, Spacing.xl),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            color: AppColors.live, size: 8),
                        const SizedBox(width: 6),
                        Text(l.playerLiveLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: TextSize.caption,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.lg, 0, Spacing.lg, Spacing.xl),
                  child: Column(
                    children: [
                      StreamBuilder<Duration>(
                        // Position her saniye emit eder; Slider value & alt
                        // saat metni her tick'te yenilenir.
                        stream: widget.player.stream.position,
                        builder: (ctx, posSnap) {
                          final pos = posSnap.data ??
                              widget.player.state.position;
                          // Duration sync — IPTV VOD bazen stream'i emit
                          // etmiyor. _player.state.duration native player'dan
                          // gerceklesen son degeri donderir.
                          final duration = widget.player.state.duration;
                          final durMs = duration.inMilliseconds;
                          final hasDuration = durMs > 0;
                          // Slider value clamping: durMs<=0 ise gecici max=1,
                          // value=0 → thumb solda. hasDuration false ise
                          // onChanged null (UI gri ama tap kaybolmaz cunku
                          // GestureDetector parent'ina dusmesin diye Stack
                          // icinde fizikselsel olarak orada).
                          final maxMs = hasDuration ? durMs : 1;
                          final valMs =
                              pos.inMilliseconds.clamp(0, maxMs);
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(ctx).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor: AppColors.accent,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: AppColors.accent,
                                  overlayColor:
                                      AppColors.accent.withValues(alpha: 0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 7),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                  trackShape:
                                      const RoundedRectSliderTrackShape(),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: maxMs.toDouble(),
                                  value: valMs.toDouble(),
                                  onChanged: hasDuration
                                      ? (v) {
                                          // Drag sirasinda her tick'te seek.
                                          // VOD'da watchdog kapali oldugundan
                                          // serbestce seek edilebilir.
                                          final cap = (durMs - 3000)
                                              .clamp(0, durMs);
                                          final ms = v
                                              .toInt()
                                              .clamp(0, cap);
                                          widget.player.seek(
                                              Duration(milliseconds: ms));
                                        }
                                      : null,
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
                                    Text(l.playerSeekHint,
                                        style: const TextStyle(
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
                      const SizedBox(height: Spacing.sm),
                      // Subtitle + speed + audio + aspect-ratio + resolution + mute
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3.5),
                            child: _SubtitleButton(
                              aiEnabled: widget.subtitleEnabled,
                              player:    widget.player,
                              onAiToggle: widget.onSubtitleToggle,
                              onFeedback: widget.onFeedback,
                            ),
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(4),
                            child: _SpeedButton(
                              player: widget.player,
                              onFeedback: widget.onFeedback,
                            ),
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(5),
                            child: _AudioTrackButton(
                              player: widget.player,
                              onFeedback: widget.onFeedback,
                            ),
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(5.5),
                            child: _AspectRatioButton(
                              fit:      widget.videoFit,
                              onChange: widget.onFitChange,
                            ),
                          ),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(5.8),
                            child: _ResolutionButton(
                              player: widget.player,
                              onFeedback: widget.onFeedback,
                            ),
                          ),
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
                                  tooltip: vol > 0 ? l.playerMuteTooltip : l.playerUnmuteTooltip,
                                  onTap: () {
                                    final mute = vol > 0;
                                    widget.player.setVolume(mute ? 0 : 100);
                                    widget.onFeedback(
                                      mute ? Icons.volume_off : Icons.volume_up,
                                      mute ? 'Sessiz' : 'Ses açık',
                                    );
                                  },
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

// ── Favori toggle butonu (player üst bar) ───────────────────────────────────
//
// 2026-05-11: Channel ID ile DB'den isFavorite okuyup toggle eder. Player'da
// oynayan kanal listede ne durumda olursa olsun bağımsız çalışır.

class _FavoriteButton extends ConsumerStatefulWidget {
  final String channelId;
  const _FavoriteButton({required this.channelId});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton> {
  bool? _isFavorite;
  ChannelModel? _channel;

  @override
  void initState() {
    super.initState();
    _loadChannel();
  }

  Future<void> _loadChannel() async {
    try {
      final repo = ref.read(channelRepoProvider);
      final ch = await repo.getById(widget.channelId);
      if (mounted) {
        setState(() {
          _channel = ch;
          _isFavorite = ch?.isFavorite ?? false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFavorite = false);
    }
  }

  Future<void> _toggle() async {
    if (_channel == null || _isFavorite == null) return;
    final newFav = !_isFavorite!;
    setState(() => _isFavorite = newFav);
    try {
      await ref
          .read(channelRepoProvider)
          .toggleFavorite(_channel!.id, newFav);
      _channel = _channel!.copyWith(isFavorite: newFav);
      // Home liste cache'i de güncellenmeli
      ref.invalidate(homeProvider);
    } catch (_) {
      // Hata olursa state'i geri al
      if (mounted) setState(() => _isFavorite = !newFav);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fav = _isFavorite ?? false;
    return _TvIconButton(
      icon: fav ? Icons.star : Icons.star_border,
      tooltip: fav ? 'Favoriden Çıkar' : 'Favorilere Ekle',
      onTap: _toggle,
    );
  }
}

// ── TV-friendly icon button with visible focus ring ─────────────────────────

class _TvIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  const _TvIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 28,
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
            child: Icon(widget.icon, color: Colors.white, size: widget.size),
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
  // 2026-05-11: Optimistic state — basıldığında stream event beklemeden
  // ikon değişir, kullanıcı tepki alır. Stream event geldiğinde widget.playing
  // ile teyit edilir.
  bool? _optimisticPlaying;
  DateTime? _lastTapAt;

  bool get _displayPlaying => _optimisticPlaying ?? widget.playing;

  @override
  void didUpdateWidget(_PlayPauseButton old) {
    super.didUpdateWidget(old);
    // Stream gerçek değeri optimistic'le eşleşirse temizle (state teyit edildi)
    if (_optimisticPlaying != null && widget.playing == _optimisticPlaying) {
      _optimisticPlaying = null;
    }
  }

  void _handleTap() {
    // Debounce: 300ms içinde ikinci basışı yut (toggle çakışmasını önler)
    final now = DateTime.now();
    if (_lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastTapAt = now;
    // Optimistic toggle — UI hemen değişir
    setState(() => _optimisticPlaying = !_displayPlaying);
    widget.onTap();
  }

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
          _handleTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _handleTap,
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
            _displayPlaying ? Icons.pause : Icons.play_arrow,
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
  final void Function(IconData icon, String text) onFeedback;
  const _AudioTrackButton({required this.player, required this.onFeedback});

  @override
  State<_AudioTrackButton> createState() => _AudioTrackButtonState();
}

class _AudioTrackButtonState extends State<_AudioTrackButton> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
              tooltip: l.playerAudioTrackTooltip,
              onTap: () => _showAudioDialog(
                  context, widget.player, audioTracks, current?.audio,
                  widget.onFeedback),
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
    void Function(IconData icon, String text) onFeedback,
  ) async {
    final l = AppLocalizations.of(context);
    final selected = await showDialog<AudioTrack>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.playerAudioTrackDialog),
        children: tracks.map((t) {
          final label = t.title?.isNotEmpty == true
              ? t.title!
              : t.language?.isNotEmpty == true
                  ? t.language!
                  : l.playerAudioTrackFallback(tracks.indexOf(t) + 1);
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
    if (selected != null) {
      player.setAudioTrack(selected);
      final label = selected.title?.isNotEmpty == true
          ? selected.title!
          : (selected.language?.isNotEmpty == true
              ? selected.language!
              : '${tracks.indexOf(selected) + 1}');
      onFeedback(Icons.audiotrack, 'Ses: $label');
    }
  }
}

// ── TV-friendly dialog option (D-pad Enter/Select/gameButtonA support) ──────

class _TvDialogOption extends StatefulWidget {
  final bool autofocus;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _TvDialogOption({
    this.autofocus = false,
    this.selected  = false,
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
  final void Function(IconData icon, String text) onFeedback;
  const _SpeedButton({required this.player, required this.onFeedback});

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  double _speed = 1.0;
  bool _focused = false;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> _showSpeedDialog() async {
    final l = AppLocalizations.of(context);
    final selected = await showDialog<double>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.playerSpeedDialog),
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
      widget.onFeedback(Icons.speed, 'Hız ${selected}x');
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

// ── Subtitle picker (AI / Embedded tracks / Off) ────────────────────────────

class _SubtitleButton extends StatelessWidget {
  final bool aiEnabled;
  final Player player;
  final VoidCallback onAiToggle;
  final void Function(IconData icon, String text) onFeedback;

  const _SubtitleButton({
    required this.aiEnabled,
    required this.player,
    required this.onAiToggle,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _TvIconButton(
      icon: aiEnabled ? Icons.subtitles : Icons.subtitles_off_outlined,
      tooltip: l.playerSubtitleEnable,
      onTap: () async {
        final tracks = player.state.tracks.subtitle;
        // 'no' / 'auto' tracks otomatik gelir, gerçek embedded'ları ayır
        final embedded = tracks.where((t) => t.id != 'no' && t.id != 'auto').toList();
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) {
            final ll = AppLocalizations.of(ctx);
            return SimpleDialog(
              title: Text(ll.playerSubtitleDialogTitle),
              children: [
                _TvDialogOption(
                  label: aiEnabled
                      ? '${ll.playerSubtitleAi} ${ll.playerSubtitleAiActive}'
                      : ll.playerSubtitleAi,
                  onTap: () => Navigator.pop(ctx, 'ai'),
                ),
                for (var i = 0; i < embedded.length; i++)
                  _TvDialogOption(
                    label: ll.playerSubtitleEmbedded(i + 1) +
                        (embedded[i].language != null
                            ? ' (${embedded[i].language})'
                            : ''),
                    onTap: () => Navigator.pop(ctx, 'emb_${embedded[i].id}'),
                  ),
                _TvDialogOption(
                  label: ll.playerSubtitleOff,
                  onTap: () => Navigator.pop(ctx, 'off'),
                ),
              ],
            );
          },
        );
        if (result == null) return;
        if (result == 'ai') {
          // AI toggle — varsa kapat, yoksa aç. Feedback'i SubtitleOverlay
          // ("AI altyazı hazırlanıyor…") + onError zinciri saglar.
          onAiToggle();
          // Embedded varsa onu da kapat
          await player.setSubtitleTrack(SubtitleTrack.no());
        } else if (result == 'off') {
          if (aiEnabled) onAiToggle();
          onFeedback(Icons.subtitles_off, 'Altyazı kapalı');
          await player.setSubtitleTrack(SubtitleTrack.no());
        } else if (result.startsWith('emb_')) {
          if (aiEnabled) onAiToggle(); // AI varsa kapat
          final id = result.substring(4);
          final track = embedded.firstWhere((t) => t.id == id,
              orElse: () => SubtitleTrack.no());
          // Anlık feedback — setSubtitleTrack yüklemesi birkaç saniye sürebilir;
          // kullanıcı butona bastığında işlemin başladığını hemen görsün.
          final lang = track.language;
          onFeedback(
            Icons.subtitles,
            (lang != null && lang.isNotEmpty)
                ? 'Altyazı: $lang'
                : 'Altyazı yükleniyor…',
          );
          await player.setSubtitleTrack(track);
        }
      },
    );
  }
}

// ── Aspect ratio (Orijinal / Doldur / Esnet) ────────────────────────────────

class _AspectRatioButton extends StatelessWidget {
  final BoxFit fit;
  final ValueChanged<BoxFit> onChange;

  const _AspectRatioButton({required this.fit, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _TvIconButton(
      icon: Icons.aspect_ratio,
      tooltip: l.playerScreenSizeTooltip,
      onTap: () async {
        final result = await showDialog<BoxFit>(
          context: context,
          builder: (ctx) {
            final ll = AppLocalizations.of(ctx);
            return SimpleDialog(
              title: Text(ll.playerScreenSizeDialog),
              children: [
                _TvDialogOption(
                  label: '${ll.playerFitOriginal}${fit == BoxFit.contain ? " ✓" : ""}',
                  onTap: () => Navigator.pop(ctx, BoxFit.contain),
                ),
                _TvDialogOption(
                  label: '${ll.playerFitCover}${fit == BoxFit.cover ? " ✓" : ""}',
                  onTap: () => Navigator.pop(ctx, BoxFit.cover),
                ),
                _TvDialogOption(
                  label: '${ll.playerFitStretch}${fit == BoxFit.fill ? " ✓" : ""}',
                  onTap: () => Navigator.pop(ctx, BoxFit.fill),
                ),
              ],
            );
          },
        );
        if (result != null) onChange(result);
      },
    );
  }
}

// ── Resolution / Quality picker (HLS / Multi-bitrate) ───────────────────────

class _ResolutionButton extends StatelessWidget {
  final Player player;
  final void Function(IconData icon, String text) onFeedback;
  const _ResolutionButton({required this.player, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _TvIconButton(
      icon: Icons.high_quality,
      tooltip: l.playerResolutionTooltip,
      onTap: () async {
        final tracks = player.state.tracks.video;
        // Auto (id='auto') + gerçek varyantları göster
        final variants = tracks
            .where((t) => t.id != 'no' && (t.w ?? 0) > 0)
            .toList()
          ..sort((a, b) => (b.h ?? 0).compareTo(a.h ?? 0));

        final result = await showDialog<String>(
          context: context,
          builder: (ctx) {
            final ll = AppLocalizations.of(ctx);
            return SimpleDialog(
              title: Text(ll.playerResolutionDialog),
              children: [
                _TvDialogOption(
                  label: ll.playerResolutionAuto,
                  onTap: () => Navigator.pop(ctx, 'auto'),
                ),
                for (final t in variants)
                  _TvDialogOption(
                    label: '${t.h}p${t.fps != null ? " ${t.fps!.round()}fps" : ""}',
                    onTap: () => Navigator.pop(ctx, t.id),
                  ),
                if (variants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      ll.playerSingleQuality,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
              ],
            );
          },
        );
        if (result == null) return;
        if (result == 'auto') {
          await player.setVideoTrack(VideoTrack.auto());
          onFeedback(Icons.high_quality, 'Çözünürlük: Otomatik');
        } else {
          final track = variants.firstWhere((t) => t.id == result,
              orElse: () => VideoTrack.auto());
          await player.setVideoTrack(track);
          onFeedback(Icons.high_quality, 'Çözünürlük: ${track.h}p');
        }
      },
    );
  }
}

// ── Gesture overlay (volume / brightness vertical swipe feedback) ────────────

class _GestureOverlay extends StatelessWidget {
  /// 'volume' (sağ) veya 'brightness' (sol)
  final String type;
  /// 0..1
  final double value;

  const _GestureOverlay({required this.type, required this.value});

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
                  isVolume ? Colors.amber : Colors.lightBlueAccent,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aksiyon feedback pill (buton işlemi → kısa süreli merkezi bildirim) ──────
//
// Kullanıcı bir butona/tuşa bastığında ekran ortasında ~1 sn boyunca görünen
// ikon + metin. TV/kumanda ile kullanımda işlemin gerçekleştiğini doğrular.
class _ActionFeedbackOverlay extends StatelessWidget {
  final IconData? icon;
  final String text;

  const _ActionFeedbackOverlay({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          opacity: text.isEmpty ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
