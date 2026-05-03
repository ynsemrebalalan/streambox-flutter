import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Picture-in-Picture (PiP) Pro feature servisi.
///
/// Android: Activity-level PiP (API 26+). MainActivity.kt MethodChannel
/// uzerinden PiP'e girer; player_screen.dart bu service'i kullanir.
///
/// iOS: media_kit Texture-based render olduğu için sistem PiP
/// (AVPictureInPictureController + AVPlayerLayer) ile dogrudan calismaz.
/// iOS PiP burada *background audio* + AirPlay'e duser. Tam video PiP icin
/// gelecekte AVPlayer kopru gerekli; suanki implementasyon Pro'lugun
/// degerini Android'de tam, iOS'ta audio-only sunar.
class PipService {
  PipService._();
  static final PipService instance = PipService._();

  static const _channel = MethodChannel('iptvai/pip');

  final _modeController = StreamController<bool>.broadcast();

  /// PiP penceresine girildiginde (true) / cikildiginda (false) emit.
  Stream<bool> get modeStream => _modeController.stream;

  bool _initialized = false;
  bool _isAndroid = false;
  bool _isIOS = false;
  bool _supported = false;

  /// MethodChannel handler'i baglar — bir kez cagirilir.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    _isAndroid = defaultTargetPlatform == TargetPlatform.android;
    _isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    if (_isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'pipModeChanged') {
          final inPip = call.arguments == true;
          _modeController.add(inPip);
        }
        return null;
      });

      try {
        _supported = (await _channel.invokeMethod<bool>('isSupported')) ?? false;
      } catch (e) {
        debugPrint('[PiP] isSupported check failed: $e');
        _supported = false;
      }
    } else if (_isIOS) {
      // iOS PiP suanki implementasyonda *background audio* olarak duser
      // (Info.plist UIBackgroundModes audio + picture-in-picture).
      // Tam AVPlayerLayer PiP gelecek surume.
      _supported = false;
    }
  }

  /// PiP destekleniyor mu?
  bool get isSupported => _supported;

  /// Manuel PiP'e gir. true = basarili, false = destek yok / hata.
  Future<bool> enter() async {
    await ensureInitialized();
    if (!_supported) return false;
    if (!_isAndroid) return false;
    try {
      final ok = (await _channel.invokeMethod<bool>('enter')) ?? false;
      return ok;
    } catch (e) {
      debugPrint('[PiP] enter failed: $e');
      return false;
    }
  }

  /// Auto-PiP — kullanici Home tusuna basinca otomatik PiP'e gec.
  /// Pro user + player aktif iken setAutoPip(true) cagrilir.
  Future<void> setAutoPip(bool enabled) async {
    await ensureInitialized();
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('setAutoPip', enabled);
    } catch (e) {
      debugPrint('[PiP] setAutoPip failed: $e');
    }
  }

  /// Player aktiflik bayragi — PiP servisinin auto-mode kararini etkiler.
  Future<void> setPlayerActive(bool active) async {
    await ensureInitialized();
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('setPlayerActive', active);
    } catch (e) {
      debugPrint('[PiP] setPlayerActive failed: $e');
    }
  }
}
