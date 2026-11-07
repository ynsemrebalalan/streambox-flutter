import '../../../data/models/channel_model.dart';

/// Ses/altyazı dili tercihleri (Android PlayerViewModel.applySavedTrackPrefs).
///
/// Bölüm anahtarı playlist + streamUrl'den (kanal id'si yeniden yüklemede
/// değişebilir); dizi anahtarı aynı dizinin tüm bölümlerinde ortaktır, böylece
/// bir bölümde seçilen dil sonraki bölüme taşınır.
///
/// Dart'ın `String.hashCode`'u süreçler arası kararlı DEĞİL → FNV-1a 32 bit.
String stableHash(String s) {
  var h = 0x811c9dc5;
  for (final unit in s.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h.toRadixString(16).padLeft(8, '0');
}

String? episodeTrackKey(ChannelModel ch) {
  if (ch.streamType == 'live' || ch.streamUrl.isEmpty) return null;
  return '${ch.playlistId}_${stableHash(ch.streamUrl)}';
}

String? seriesTrackKey(ChannelModel ch) {
  if (ch.streamType != 'series' || ch.seriesName.isEmpty) return null;
  return '${ch.playlistId}_series_${stableHash(ch.seriesName)}';
}

abstract final class TrackPrefKeys {
  static String audio(String key) => 'trackpref_audio_$key';
  static String subLang(String key) => 'trackpref_sublang_$key';
  static String subOn(String key) => 'trackpref_subon_$key';
}

class TrackPrefs {
  final String? audioLang;
  final String? subtitleLang;

  /// null = hiç karar kaydedilmemiş (varsayılan davranış uygulanır).
  final bool? subtitleEnabled;
  const TrackPrefs({this.audioLang, this.subtitleLang, this.subtitleEnabled});
}

TrackPrefs resolveTrackPrefs(
  Map<String, String> store, {
  required String episodeKey,
  required String? seriesKey,
}) {
  String? nonEmpty(String? v) => (v == null || v.isEmpty) ? null : v;

  final audio = nonEmpty(store[TrackPrefKeys.audio(episodeKey)]) ??
      (seriesKey == null ? null : nonEmpty(store[TrackPrefKeys.audio(seriesKey)]));

  // Bölümde bilinçli bir altyazı kararı varsa o kazanır; yoksa dizi düzeyi.
  final useEpisode =
      store.containsKey(TrackPrefKeys.subOn(episodeKey)) || seriesKey == null;
  final subKey = useEpisode ? episodeKey : seriesKey;
  final onRaw = store[TrackPrefKeys.subOn(subKey)];
  return TrackPrefs(
    audioLang: audio,
    subtitleLang: nonEmpty(store[TrackPrefKeys.subLang(subKey)]),
    subtitleEnabled: onRaw == null ? null : onRaw == 'true',
  );
}

/// Dil koduna göre ilk eşleşen parça (büyük/küçük harf duyarsız).
T? pickByLanguage<T>(List<T> tracks, String? Function(T) languageOf, String? lang) {
  if (lang == null || lang.isEmpty) return null;
  final target = lang.toLowerCase();
  for (final t in tracks) {
    if (languageOf(t)?.toLowerCase() == target) return t;
  }
  return null;
}
