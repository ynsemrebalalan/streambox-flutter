/// Playlist sync eşzamanlılık durumu (saf — test edilebilir).
///
///  - Sync sürerken düzenleme: sessizce yutulmaz, bitince BİR takip sync'i.
///  - Sync sürerken silme: yazımlar iptal (onBatch [isCancelled] kontrol
///    eder), bitince playlist'in kanalları yeniden silinir (yetim satır yok).
class SyncCoordinator {
  final _running = <String>{};
  final _resync = <String>{};
  final _cancelled = <String>{};

  bool isRunning(String id) => _running.contains(id);
  bool isCancelled(String id) => _cancelled.contains(id);

  /// false = zaten çalışıyor.
  bool begin(String id) {
    if (!_running.add(id)) return false;
    _cancelled.remove(id);
    _resync.remove(id);
    return true;
  }

  /// Çalışan sync varsa takip sync'i kuyruğa al (true = kuyruğa alındı).
  bool requestResync(String id) {
    if (!_running.contains(id)) return false;
    _resync.add(id);
    return true;
  }

  /// Silme: çalışan sync varsa iptal işaretle (true = bitince temizlik gerek).
  bool cancel(String id) {
    _resync.remove(id);
    if (!_running.contains(id)) return false;
    _cancelled.add(id);
    return true;
  }

  SyncEnd end(String id) {
    _running.remove(id);
    final cancelled = _cancelled.remove(id);
    final resync = _resync.remove(id) && !cancelled;
    return SyncEnd(cancelled: cancelled, resync: resync);
  }
}

class SyncEnd {
  /// Sync sırasında playlist silindi → kanalları tekrar sil.
  final bool cancelled;

  /// Sync sırasında düzenlendi → güncel kayıtla yeniden sync.
  final bool resync;
  const SyncEnd({required this.cancelled, required this.resync});
}
