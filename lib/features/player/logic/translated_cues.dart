import '../../../data/models/subtitle_cue.dart';

/// Çeviri yanıtı → cue listesi. [aligned] = parça sayısı kaynakla aynı
/// (zamanlamalar korunur). Uyuşmazlıkta tek birleşik cue döner ve sonuç
/// CACHE'LENMEMELİ (sonraki denemede doğru hizalanmış çeviri gelebilir).
class TranslatedCues {
  final List<SubtitleCue> cues;
  final bool aligned;
  const TranslatedCues(this.cues, {required this.aligned});
}

/// null = boş/başarısız çeviri.
TranslatedCues? splitTranslatedCues(List<SubtitleCue> source, String? text) {
  if (text == null || text.trim().isEmpty || source.isEmpty) return null;
  final parts = text
      .split('<<CUE>>')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.length == source.length) {
    return TranslatedCues([
      for (var i = 0; i < source.length; i++)
        SubtitleCue(
            startMs: source[i].startMs, endMs: source[i].endMs, text: parts[i]),
    ], aligned: true);
  }
  return TranslatedCues([
    SubtitleCue(
        startMs: source.first.startMs,
        endMs: source.last.endMs,
        text: text.trim()),
  ], aligned: false);
}
