/// AI altyazı için ses segmenti seçimi (saf, test edilebilir).
library;

const int kWhisperSegmentSec = 60;

int alignSegmentSec(int startSec) =>
    (startSec ~/ kWhisperSegmentSec) * kWhisperSegmentSec;

/// Cache anahtarı — hedef dil dahil (Android beta67 fix: dil değişince eski
/// dildeki çeviri cache'ten gelmesin). `_v2`: eski kayıtlar okunmaz.
String whisperCacheId(String channelId, int segmentSec, String targetLang) {
  final lang = targetLang.trim().toLowerCase();
  final l = lang.length >= 2 ? lang.substring(0, 2) : 'xx';
  return '${channelId}_${segmentSec}_${l}_v2';
}

class HlsSegment {
  final String url;
  final double startSec;
  final double durationSec;
  const HlsSegment(this.url, this.startSec, this.durationSec);
}

String _resolve(Uri base, String ref) =>
    ref.startsWith('http') ? ref : base.resolve(ref).toString();

/// Master playlist ise en düşük bant genişlikli varyantın URL'si (ses için
/// görüntü kalitesi önemsiz, daha az byte), media playlist ise null.
String? pickHlsVariant(String playlist, Uri base) {
  final lines = playlist.split('\n').map((l) => l.trim()).toList();
  String? best;
  int? bestBw;
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('#EXT-X-STREAM-INF')) continue;
    final bw = int.tryParse(
            RegExp(r'BANDWIDTH=(\d+)').firstMatch(lines[i])?.group(1) ?? '') ??
        1 << 30;
    final uri = lines.skip(i + 1).firstWhere(
        (l) => l.isNotEmpty && !l.startsWith('#'),
        orElse: () => '');
    if (uri.isEmpty) continue;
    if (bestBw == null || bw < bestBw) {
      bestBw = bw;
      best = _resolve(base, uri);
    }
  }
  return best;
}

/// `[startSec, startSec + windowSec)` aralığıyla kesişen segmentler.
List<HlsSegment> selectHlsSegments(
  String playlist,
  Uri base, {
  required int startSec,
  int windowSec = kWhisperSegmentSec,
}) {
  final out = <HlsSegment>[];
  double acc = 0;
  double? pending;
  final end = startSec + windowSec;
  for (final raw in playlist.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('#EXTINF:')) {
      pending = double.tryParse(line.substring(8).split(',').first.trim());
    } else if (line.isNotEmpty && !line.startsWith('#') && pending != null) {
      final t0 = acc;
      final t1 = acc + pending;
      if (t1 > startSec && t0 < end) {
        out.add(HlsSegment(_resolve(base, line), t0, pending));
      }
      acc = t1;
      pending = null;
      if (acc >= end) break;
    }
  }
  return out;
}

class ByteRange {
  final int start;
  final int end; // dahil
  const ByteRange(this.start, this.end);
  String get header => 'bytes=$start-$end';
}

/// Progressive dosyada (ör. .ts) ortalama bit hızından [startSec] civarındaki
/// 60 sn'lik bayt aralığı. Yalnızca kendiliğinden senkronlanan kapsayıcılarda
/// (MPEG-TS) çözülebilir; MP4/MKV ortası `moov`/başlık olmadan çözülemez —
/// bu yüzden onlarda önce mpv tabanlı çıkarım denenir.
ByteRange? progressiveByteRange({
  required int contentLength,
  required double durationSec,
  required int startSec,
  required int maxBytes,
  int windowSec = kWhisperSegmentSec,
}) {
  if (contentLength <= 0 || durationSec <= 0) return null;
  final bytesPerSec = contentLength / durationSec;
  final start = (bytesPerSec * startSec).floor().clamp(0, contentLength - 1);
  var length = (bytesPerSec * windowSec).floor();
  if (length > maxBytes) length = maxBytes;
  var end = start + length - 1;
  if (end > contentLength - 1) end = contentLength - 1;
  return ByteRange(start, end);
}
