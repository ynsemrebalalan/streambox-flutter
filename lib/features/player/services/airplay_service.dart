import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// AirPlay (iOS) / Cast (Android — placeholder) Pro feature servisi.
///
/// iOS: AVRoutePickerView native sheet — AppDelegate.swift "showRoutePicker".
/// Background mode "audio" + AVAudioSession .allowAirPlay yetiyor.
///
/// Android: AirPlay Apple proprietary; Android'de Google Cast karsiligi.
/// Google Cast ileride eklenebilir; suanki implementasyonda Android'de
/// isAvailable=false donduruyoruz.
class AirplayService {
  AirplayService._();
  static final AirplayService instance = AirplayService._();

  static const _channel = MethodChannel('iptvai/airplay');

  bool _checked = false;
  bool _available = false;

  Future<bool> isAvailable() async {
    if (_checked) return _available;
    _checked = true;
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      _available = false;
      return false;
    }
    try {
      _available = (await _channel.invokeMethod<bool>('isAvailable')) ?? false;
    } catch (e) {
      debugPrint('[AirPlay] isAvailable failed: $e');
      _available = false;
    }
    return _available;
  }

  /// Sistem AirPlay sheet'ini ac. iOS only.
  Future<void> showRoutePicker() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod<bool>('showRoutePicker');
    } catch (e) {
      debugPrint('[AirPlay] showRoutePicker failed: $e');
    }
  }
}
