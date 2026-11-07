import '../../core/utils/search_normalizer.dart';
import '../../data/models/channel_model.dart';

/// Bölüm bitti sayılır mı — Android HomeViewModel "Nerede Kaldım":
/// izlendi işaretli veya son 60 sn içinde.
bool isEpisodeNearEnd(ChannelModel ep) =>
    ep.isWatched ||
    (ep.duration > 0 && ep.lastPosition >= ep.duration - 60000);

/// "Nerede Kaldım" satırı: dizi başına en son izlenen bölüm; bitmişse
/// sonraki bölüme ilerletilir (yoksa aynı bölüm kalır). id dedup, sıra korunur.
Future<List<ChannelModel>> resolveContinueWatching(
  List<ChannelModel> watchedEpisodes,
  Future<ChannelModel?> Function(ChannelModel ep) nextEpisode,
) async {
  final seenSeries = <String>{};
  final seenIds = <String>{};
  final out = <ChannelModel>[];
  for (final ep in watchedEpisodes) {
    final key = ep.seriesName.isNotEmpty ? ep.seriesName : ep.id;
    if (!seenSeries.add(key)) continue;
    var shown = ep;
    if (ep.seriesName.isNotEmpty && isEpisodeNearEnd(ep)) {
      shown = await nextEpisode(ep) ?? ep;
    }
    if (seenIds.add(shown.id)) out.add(shown);
  }
  return out;
}

/// A-Z sıralama — Türkçe katlanmış ad (İ/ı/ş… ve büyük/küçük harf
/// duyarsız), eşitlikte orijinal ad. Anahtarlar bir kez hesaplanır.
List<ChannelModel> sortChannelsByName(List<ChannelModel> list,
    {bool descending = false}) {
  final keyed = [
    for (final c in list) (foldSearchText(c.name), c),
  ];
  keyed.sort((a, b) {
    var cmp = a.$1.compareTo(b.$1);
    if (cmp == 0) cmp = a.$2.name.compareTo(b.$2.name);
    return descending ? -cmp : cmp;
  });
  return [for (final k in keyed) k.$2];
}

/// Arama kapsamı: aktif sekmenin türü (Android) — Tümü/Favoriler → hepsi.
String? searchStreamTypeForTab(String tab) => switch (tab) {
      'live' => 'live',
      'movie' => 'movie',
      'series' => 'series',
      _ => null,
    };
