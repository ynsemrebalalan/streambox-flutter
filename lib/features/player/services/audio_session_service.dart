import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/ref_counter.dart';

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

  /// Ust uste binen player orneklerini (kanal degisimi pushReplacement)
  /// sayar: oturum yalniz 0->1'de aktif, 1->0'da birakilir.
  final RefCounter _refs = RefCounter();

  /// Oynatmadan hemen once cagir (her player bir kez).
  Future<void> activate() async {
    if (_refs.acquire()) await _setActive(true);
  }

  /// Player kapanirken cagir (her activate icin bir kez).
  Future<void> deactivate() async {
    if (_refs.release()) await _setActive(false);
  }

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
