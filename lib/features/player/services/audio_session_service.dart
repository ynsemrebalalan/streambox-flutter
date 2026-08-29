import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS ses oturumu (AVAudioSession) kontrolu.
///
/// **Neden var:** `AppDelegate` acilista `.playback` kategorisini kuruyor ama
/// oturumu AKTIF ETMIYOR. `.playback` "mix with others" degildir; oturumu
/// uygulama acilir acilmaz aktif etmek, kullanicinin o an dinledigi
/// Spotify/podcast'i biz hicbir sey oynatmasak bile aninda susturuyordu
/// (2026-08-29 tespiti).
///
/// Bu servis oturumu SADECE oynatma penceresinde aktif tutar; player
/// kapaninca `.notifyOthersOnDeactivation` ile birakir, diger uygulama
/// kaldigi yerden devam eder.
///
/// Android'de no-op (platform kanali yok).
class AudioSessionService {
  AudioSessionService._();
  static final AudioSessionService instance = AudioSessionService._();

  static const _channel = MethodChannel('iptvai/audio');

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Oynatmadan hemen once cagir.
  Future<void> activate() => _setActive(true);

  /// Player kapanirken cagir.
  Future<void> deactivate() => _setActive(false);

  Future<void> _setActive(bool active) async {
    if (!_isIOS) return;
    try {
      await _channel.invokeMethod<bool>('setActive', {'active': active});
    } catch (e) {
      // Oturum yonetimi basarisiz olsa bile oynatmayi engelleme: iOS,
      // AudioUnit baslarken oturumu ortulu olarak aktif eder.
      debugPrint('[Audio] setActive($active) failed: $e');
    }
  }
}
