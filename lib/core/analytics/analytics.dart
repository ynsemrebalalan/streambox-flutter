import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics wrapper.
/// GMS/Firebase yoksa sessizce fail eder (TV box, Huawei vb.).
abstract final class Analytics {
  static FirebaseAnalytics? _fa;

  static Future<void> init() async {
    try {
      _fa = FirebaseAnalytics.instance;
      await _setDeviceCategory();
    } catch (e) {
      debugPrint('[Analytics] init failed: $e');
      _fa = null;
    }
  }

  // ── Events ─────────────────────────────────────────────────────────────────

  static void playlistAdded({
    required String type,
    required int channelCount,
  }) {
    _log('playlist_added', {
      'playlist_type': type,
      'channel_count': channelCount,
      'count_bucket': _bucket(channelCount),
    });
  }

  static void firstPlayback({required String streamType}) {
    _log('first_playback', {'stream_type': streamType});
  }

  static void aiSubtitleGenerated({
    required String provider,
    required int cueCount,
    int durationMs = 0,
  }) {
    _log('ai_subtitle_generated', {
      'provider': provider,
      'cue_count': cueCount,
      'duration_ms': durationMs,
    });
  }

  static void aiSubtitleError({
    required String errorType,
    required String provider,
  }) {
    _log('ai_subtitle_error', {
      'error_type': _truncate(errorType, 40),
      'provider': provider,
    });
  }

  static void playbackError({
    required String errorCode,
    required String streamType,
  }) {
    _log('playback_error', {
      'error_code': _truncate(errorCode, 40),
      'stream_type': streamType,
    });
  }

  // ── User Properties ────────────────────────────────────────────────────────

  static void setAiProvider(String provider) {
    _setUserProperty('ai_provider', provider);
  }

  static Future<void> _setDeviceCategory() async {
    try {
      String category = 'phone';
      if (Platform.isIOS) {
        final info = await DeviceInfoPlugin().iosInfo;
        // iPad model adı "iPad" ile başlar
        if (info.model.toLowerCase().contains('ipad')) {
          category = 'tablet';
        }
      } else if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        // Android TV veya Fire TV
        if (info.systemFeatures.contains('android.software.leanback')) {
          category = 'android_tv';
        } else if (!info.systemFeatures
            .contains('android.hardware.touchscreen')) {
          category = 'tv_box';
        }
        // Tablet: smallest screen width >= 600dp (heuristic via physical RAM)
      }
      _setUserProperty('device_category', category);
    } catch (_) {}
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static void _log(String name, Map<String, Object> params) {
    try {
      _fa?.logEvent(name: name, parameters: params);
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] $name failed: $e');
    }
  }

  static void _setUserProperty(String name, String value) {
    try {
      _fa?.setUserProperty(
        name: name,
        value: value.length > 36 ? value.substring(0, 36) : value,
      );
    } catch (_) {}
  }

  static String _truncate(String s, int max) =>
      s.length > max ? s.substring(0, max) : s;

  static String _bucket(int count) {
    if (count < 100) return 'lt_100';
    if (count < 1000) return '100_1k';
    if (count < 10000) return '1k_10k';
    if (count < 50000) return '10k_50k';
    if (count < 100000) return '50k_100k';
    return '100k_plus';
  }
}
