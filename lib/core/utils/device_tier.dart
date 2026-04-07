import 'dart:io';
import 'package:flutter/foundation.dart';

/// Cihaz performans katmani. RAM ve islemci cekirdek sayisina gore belirlenir.
/// Playlist yukleme, DB yazma, parse stratejisi buna gore adapte edilir.
enum DeviceTier {
  /// 1-2 GB RAM, 2-4 core (X98, ucuz Cin TV box'lar)
  low,

  /// 2-3 GB RAM, 4 core (orta segment Android TV)
  mid,

  /// 4+ GB RAM, 4+ core (Google TV, Shield, telefon)
  high,
}

/// Cihaz performans profili. Session basinda bir kez hesaplanir,
/// tum servisler bunu kullanir.
class DeviceProfile {
  DeviceProfile._();

  static DeviceTier? _tier;
  static int _totalRamMB = 0;
  static int _cpuCores = 0;

  /// Session basinda cagirilir. Async degil, hizli.
  static void init() {
    _cpuCores = Platform.numberOfProcessors;
    _totalRamMB = _detectRamMB();
    _tier = _classify();
    if (kDebugMode) {
      debugPrint('[DeviceProfile] RAM: ${_totalRamMB}MB, '
          'cores: $_cpuCores, tier: $_tier');
    }
  }

  static DeviceTier get tier {
    _tier ??= () {
      init();
      return _tier!;
    }();
    return _tier!;
  }

  static int get totalRamMB => _totalRamMB;
  static int get cpuCores => _cpuCores;

  // ── Adaptive parametreler ──────────────────────────────────────────────────

  /// Xtream series fetch'te ayni anda atilacak istek sayisi.
  static int get seriesConcurrency => switch (tier) {
    DeviceTier.low  => 2,
    DeviceTier.mid  => 4,
    DeviceTier.high => 8,
  };

  /// DB batch insert'te kac kanal birden yazilacak.
  static int get dbBatchSize => switch (tier) {
    DeviceTier.low  => 500,
    DeviceTier.mid  => 2000,
    DeviceTier.high => 10000, // tek seferde hepsi
  };

  /// SQLite cache_size (KB, negatif = KB olarak).
  static int get sqliteCacheKB => switch (tier) {
    DeviceTier.low  => 2000,   // 2 MB
    DeviceTier.mid  => 8000,   // 8 MB
    DeviceTier.high => 16000,  // 16 MB
  };

  /// Xtream fetchAll paralel mi calissin?
  static bool get parallelFetch => tier != DeviceTier.low;

  /// M3U parse isolate'da mi calissin?
  /// Low cihazlarda isolate spawn overhead > kazanc (kucuk playlist'lerde).
  /// 5000+ kanal varsa low'da bile isolate kullanilir (_parseThreshold).
  static bool get useIsolateForParse => tier != DeviceTier.low;

  /// Isolate kullanilmasa bile bu esik asilirsa isolate'a dusulur.
  static int get isolateThreshold => 5000;

  /// HttpClient max connections per host.
  static int get maxConnectionsPerHost => switch (tier) {
    DeviceTier.low  => 3,
    DeviceTier.mid  => 6,
    DeviceTier.high => 8,
  };

  // ── Internal ───────────────────────────────────────────────────────────────

  static DeviceTier _classify() {
    // Oncelik: RAM
    if (_totalRamMB > 0) {
      if (_totalRamMB >= 3500) return DeviceTier.high;
      if (_totalRamMB >= 2000) return DeviceTier.mid;
      return DeviceTier.low;
    }
    // RAM tespit edilemezse core sayisina bak
    if (_cpuCores >= 6) return DeviceTier.high;
    if (_cpuCores >= 4) return DeviceTier.mid;
    return DeviceTier.low;
  }

  /// Android'de /proc/meminfo'dan toplam RAM okur.
  /// iOS/desktop'ta 0 doner (varsayilan high kullanilir).
  static int _detectRamMB() {
    if (!Platform.isAndroid) {
      // iOS/desktop genelde yeterli RAM'e sahip
      return 4096;
    }
    try {
      final meminfo = File('/proc/meminfo').readAsStringSync();
      final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(meminfo);
      if (match != null) {
        final kb = int.parse(match.group(1)!);
        return (kb / 1024).round();
      }
    } catch (_) {
      // /proc/meminfo okunamazsa varsayilan
    }
    return 0; // tespit edilemedi
  }
}
