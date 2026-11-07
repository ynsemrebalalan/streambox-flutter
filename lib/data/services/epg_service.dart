import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/repositories/epg_repository.dart';
import '../../data/repositories/settings_repository.dart';
import 'epg_parser.dart';

final epgServiceProvider = Provider<EpgService>(
  (ref) => EpgService(ref),
);

/// EPG sync sonucu.
class EpgSyncResult {
  final int channelCount;
  final int programmeCount;
  const EpgSyncResult(this.channelCount, this.programmeCount);
}

/// Otomatik tazeleme ölçütleri (Android EpgRepository.refreshIfStale).
const epgCoverageHorizonMs = 6 * 3600 * 1000;
const epgMinCooldownMs = 6 * 3600 * 1000;

/// Saf karar: Pro + URL tanımlı + son denemeden 6 sa geçmiş + veri 6 sa
/// sonrasını kapsamıyor.
bool shouldRefreshEpg({
  required bool isPro,
  required String url,
  required int lastRefreshMs,
  required int coverageEndMs,
  required int nowMs,
}) {
  if (!isPro || url.trim().isEmpty) return false;
  if (lastRefreshMs > 0 && nowMs - lastRefreshMs < epgMinCooldownMs) return false;
  return coverageEndMs <= nowMs + epgCoverageHorizonMs;
}

class EpgService {
  final Ref _ref;
  EpgService(this._ref);

  static String lastRefreshKey(String playlistId) =>
      'epg_last_refresh_$playlistId';

  /// Playlist'in EPG URL'i (v9: playlist başına). Boşsa eski global ayar
  /// (geçiş dönemi — Ayarlar ekranı henüz global yazıyor olabilir).
  Future<String> epgUrlFor(String playlistId) async {
    final p = await _ref.read(playlistRepoProvider).getById(playlistId);
    final own = p?.epgUrl.trim() ?? '';
    if (own.isNotEmpty) return own;
    return (await _ref.read(settingsRepoProvider).get(SettingsKeys.epgUrl))
            ?.trim() ??
        '';
  }

  /// Ayarlar dalgası için: playlist'in EPG URL'ini yaz (boş = kaldır).
  Future<void> setEpgUrl(String playlistId, String url) =>
      _ref.read(playlistRepoProvider).updateEpgUrl(playlistId, url);

  Future<int> lastRefreshMs(String playlistId) async => int.tryParse(
          await _ref.read(settingsRepoProvider).get(lastRefreshKey(playlistId)) ??
              '') ??
      0;

  /// EPG senkronu (akışlı, isolate). Hata olursa ESKİ veri korunur.
  Future<EpgSyncResult> syncEpg(String playlistId, {String? url}) async {
    final epgUrl = (url ?? await epgUrlFor(playlistId)).trim();
    if (epgUrl.isEmpty) {
      throw Exception('EPG URL ayarlanmamış. Ayarlar → EPG bölümünden giriniz.');
    }
    final repo = _ref.read(epgRepoProvider);
    final tvgIds =
        await _ref.read(channelRepoProvider).getLiveTvgIds(playlistId);
    final gen = DateTime.now().millisecondsSinceEpoch;
    var programmes = 0;
    final channels = await EpgParser.load(
      epgUrl,
      playlistId,
      // Yalnız playlist'te karşılığı olan kanallar (tvg-id yoksa hepsi).
      allowedTvgIds: tvgIds.isEmpty ? null : tvgIds,
      minStopMs: gen - EpgRepository.retentionMs,
      onProgrammes: (batch) async {
        await repo.upsertProgrammes(batch, gen);
        programmes += batch.length;
      },
    );
    if (channels.isNotEmpty) {
      await repo.replaceChannels(playlistId, channels);
    }
    final ids = <String>{
      for (final c in channels) c['tvgId'] as String,
    }.toList();
    await repo.deleteStaleProgrammes(ids, gen);
    await repo.deleteOld();
    await _ref
        .read(settingsRepoProvider)
        .set(lastRefreshKey(playlistId), '$gen');
    return EpgSyncResult(channels.length, programmes);
  }

  /// Otomatik tazeleme — gerekiyorsa. Başarısız deneme de damgalanır
  /// (sürekli hata veren URL her açılışta denenmesin). Dönüş: tazelendi mi.
  Future<bool> refreshIfStale(String playlistId, {required bool isPro}) async {
    final url = await epgUrlFor(playlistId);
    final now = DateTime.now().millisecondsSinceEpoch;
    final due = shouldRefreshEpg(
      isPro: isPro,
      url: url,
      lastRefreshMs: await lastRefreshMs(playlistId),
      coverageEndMs: await _ref.read(epgRepoProvider).coverageEndMs(playlistId),
      nowMs: now,
    );
    if (!due) return false;
    try {
      await syncEpg(playlistId, url: url);
      return true;
    } catch (_) {
      await _ref
          .read(settingsRepoProvider)
          .set(lastRefreshKey(playlistId), '$now');
      return false;
    }
  }
}
