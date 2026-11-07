import '../../../data/models/channel_model.dart';

/// Bölüm bittiğinde sıradaki bölümü seçer (Android PlayerViewModel.onMediaEnded
/// zinciri). İlk dolu sonuç kazanır:
///   1) aynı sezon, `sortOrder` ile (sağlayıcı sırası = izleme sırası)
///   2) aynı sezon, bölüm NUMARASI ile (sortOrder bayatladıysa)
///   3) sonraki sezonun ilk bölümü — yalnızca gerçek bir sezon numarası varsa
///      (seasonNumber=0 için "sonraki sezon" tanımsızdır).
ChannelModel? selectNextEpisode(ChannelModel current, List<ChannelModel> episodes) {
  if (current.streamType != 'series' || current.seriesName.isEmpty) return null;
  final others = episodes.where((e) => e.id != current.id).toList();
  final sameSeason =
      others.where((e) => e.seasonNumber == current.seasonNumber).toList();

  final bySort = sameSeason.where((e) => e.sortOrder > current.sortOrder).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  if (bySort.isNotEmpty) return bySort.first;

  if (current.episodeNumber > 0) {
    final byNumber = sameSeason
        .where((e) => e.episodeNumber > current.episodeNumber)
        .toList()
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    if (byNumber.isNotEmpty) return byNumber.first;
  }

  if (current.seasonNumber <= 0) return null;
  final later = others.where((e) => e.seasonNumber > current.seasonNumber).toList();
  if (later.isEmpty) return null;
  later.sort((a, b) {
    final s = a.seasonNumber.compareTo(b.seasonNumber);
    if (s != 0) return s;
    final ep = a.episodeNumber.compareTo(b.episodeNumber);
    if (ep != 0) return ep;
    return a.sortOrder.compareTo(b.sortOrder);
  });
  return later.first;
}
