import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics wrapper.
///
/// Analytics ile ayni felsefe: GMS/Firebase yoksa (TV box, Huawei vb.)
/// sessizce no-op'a duser, ASLA throw etmez.
///
/// **Kritik tasarim notu — buffer neden var:**
/// `main()` icinde `FlutterError.onError` ve `PlatformDispatcher.onError`
/// EN BASTA kuruluyor, ama Firebase `runApp` sonrasi arka planda init
/// ediliyor (bkz `_bootstrapInBackground`, iOS 26 siyah ekran fix'i).
/// Yani init penceresinde (~ilk saniyeler) gelen hatalar icin
/// `FirebaseCrashlytics.instance` HENUZ hazir degil — dogrudan cagirmak
/// `[core/no-app]` firlatir ve hatayi tamamen kaybederiz.
/// Uygulamanin en kritik crash'leri tam da bu acilis penceresinde oldugu
/// icin bu hatalari [_buffer]'a alip [init] sonrasi flush ediyoruz.
abstract final class CrashReporting {
  static FirebaseCrashlytics? _fc;

  /// Firebase hazir olana kadar biriken hatalar. Sinirli — init hic
  /// gelmezse (Firebase yok) bellek sismesin.
  static final List<_PendingRecord> _buffer = <_PendingRecord>[];
  static const int _maxBuffered = 30;

  /// Firebase init'i tamamlandiktan SONRA cagrilir (`_initFirebaseAndAnalytics`).
  /// Buffer'daki hatalari flush eder.
  static Future<void> init() async {
    try {
      final fc = FirebaseCrashlytics.instance;
      // Debug build'lerde rapor gonderme — dashboard'u gelistirme
      // gurultusuyle kirletmesin.
      await fc.setCrashlyticsCollectionEnabled(!kDebugMode);
      _fc = fc;
      _flush();
    } catch (e) {
      debugPrint('[Crashlytics] init failed: $e');
      _fc = null;
      _buffer.clear();
    }
  }

  // ── Kayit ────────────────────────────────────────────────────────────────

  /// Flutter framework hatasi (`FlutterError.onError`).
  static void recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) {
    final fc = _fc;
    if (fc == null) {
      _bufferRecord(
        _PendingRecord(
          error: details.exceptionAsString(),
          stack: details.stack,
          reason: details.context?.toDescription(),
          fatal: fatal,
        ),
      );
      return;
    }
    try {
      if (fatal) {
        fc.recordFlutterFatalError(details);
      } else {
        fc.recordFlutterError(details);
      }
    } catch (e) {
      debugPrint('[Crashlytics] recordFlutterError failed: $e');
    }
  }

  /// Yakalanmis/yakalanmamis Dart hatasi.
  static void recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) {
    final fc = _fc;
    if (fc == null) {
      _bufferRecord(
        _PendingRecord(
          error: error,
          stack: stack,
          reason: reason,
          fatal: fatal,
        ),
      );
      return;
    }
    try {
      fc.recordError(error, stack, reason: reason, fatal: fatal);
    } catch (e) {
      debugPrint('[Crashlytics] recordError failed: $e');
    }
  }

  /// Crash oncesi breadcrumb. Crash raporuna eklenir.
  static void log(String message) {
    try {
      _fc?.log(message);
    } catch (_) {}
  }

  /// Crash'i kullaniciya baglar — "kac kullanici etkilendi" dogru cikar.
  /// `null`/bos ise temizler (logout).
  static void setUserId(String? uid) {
    try {
      _fc?.setUserIdentifier(uid ?? '');
    } catch (_) {}
  }

  // ── Ic isleyis ───────────────────────────────────────────────────────────

  static void _bufferRecord(_PendingRecord record) {
    // Init hic gelmeyebilir (Firebase'siz cihaz) — sinirsiz buyumesin.
    // En eskiyi at, en yeniyi tut: acilis crash'inde son hata daha degerli.
    if (_buffer.length >= _maxBuffered) _buffer.removeAt(0);
    _buffer.add(record);
  }

  static void _flush() {
    if (_buffer.isEmpty) return;
    final pending = List<_PendingRecord>.from(_buffer);
    _buffer.clear();
    for (final r in pending) {
      try {
        _fc?.recordError(
          r.error,
          r.stack,
          // Hatanin init penceresinde olustugunu triage'da ayirt edebilelim.
          reason: r.reason == null
              ? '[pre-init]'
              : '[pre-init] ${r.reason}',
          fatal: r.fatal,
        );
      } catch (e) {
        debugPrint('[Crashlytics] flush failed: $e');
      }
    }
  }
}

class _PendingRecord {
  const _PendingRecord({
    required this.error,
    required this.stack,
    required this.reason,
    required this.fatal,
  });

  final Object error;
  final StackTrace? stack;
  final String? reason;
  final bool fatal;
}
