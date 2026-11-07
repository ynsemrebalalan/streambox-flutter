/// Playlist sync'i kullanıcı işlemiyle (ör. sync sırasında silme) iptal
/// edildi. onBatch içinden fırlatılır; loader'lar bunu yutmamalı.
class SyncCancelledException implements Exception {
  const SyncCancelledException();
  @override
  String toString() => 'SyncCancelledException';
}
