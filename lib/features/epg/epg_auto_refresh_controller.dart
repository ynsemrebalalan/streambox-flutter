import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/epg_service.dart';
import '../billing/providers/purchases_providers.dart';

/// Pro: EPG otomatik tazeleme — Android paritesi (2026-10): ayar YOK.
/// Ölçüt verinin kendisi: rehber 6 saat sonrasını kapsamıyorsa ve son
/// denemeden 6 saat geçtiyse tazelenir ([shouldRefreshEpg]). Açılışta ve
/// uygulama ön plana dönünce tüm playlist'ler için kontrol edilir.
///
/// State: geriye uyumluluk için tutulan eski aralık değeri (saat); artık
/// karar için KULLANILMAZ. -1 = otomatik.
class EpgAutoRefreshController extends Notifier<int> {
  bool _running = false;

  @override
  int build() => -1;

  /// Geriye uyumlu no-op (eski ayar okunmaz; otomatik mod).
  Future<void> loadFromDb() async {
    state = -1;
  }

  /// Geriye uyumlu no-op — Android'de ayar kaldırıldı.
  Future<void> setInterval(int hours) async {}

  /// Açılış / ön plana dönüş. Pro değilse no-op.
  Future<void> maybeRefresh() async {
    if (_running || !ref.read(isProProvider)) return;
    _running = true;
    try {
      final service = ref.read(epgServiceProvider);
      final playlists = await ref.read(playlistRepoProvider).getAll();
      for (final p in playlists) {
        try {
          await service.refreshIfStale(p.id, isPro: true);
        } catch (e) {
          debugPrint('[EpgAutoRefresh] ${p.id} failed: $e');
        }
      }
    } finally {
      _running = false;
    }
  }
}

final epgAutoRefreshProvider =
    NotifierProvider<EpgAutoRefreshController, int>(
  EpgAutoRefreshController.new,
);
