/// Playlist sync "veri silme" kapıları (saf fonksiyonlar — test edilebilir).
///
/// Süresi dolmuş hesaplar çoğu zaman geçerli ama küçük/boş bir yanıt döner
/// (küçük M3U, Xtream'de `{}` / `[]`). Bu yanıt "başarı" sayılıp eski nesil
/// silinirse favoriler / izleme geçmişi (satırlarda tutulur) kaybolur.
library;

/// Kapının devreye girdiği asgari önceki satır sayısı.
const shrinkGateMinPrevious = 50;

/// Önceki ≥ 50 iken yeni sayı önceki'nin %10'unun altındaysa "şüpheli".
bool isDrasticShrink({required int previous, required int current}) =>
    previous >= shrinkGateMinPrevious && current * 10 < previous;

enum M3uShrinkVerdict {
  /// Eski nesil silinebilir.
  accept,

  /// Liste aşırı küçüldü (Content-Length olsa bile) — eski liste korunur.
  drasticShrink,

  /// Content-Length yokken yarıdan kısa — sessiz yarım indirme.
  incomplete,
}

M3uShrinkVerdict m3uShrinkVerdict({
  required int previous,
  required int current,
  required bool sawContentLength,
}) {
  if (isDrasticShrink(previous: previous, current: current)) {
    return M3uShrinkVerdict.drasticShrink;
  }
  if (!sawContentLength && previous > 0 && current < previous ~/ 2) {
    return M3uShrinkVerdict.incomplete;
  }
  return M3uShrinkVerdict.accept;
}

class XtreamKeepDecision {
  /// Eski satırları SİLİNMEYECEK türler (hata + şüpheli küçülme).
  final Set<String> keepTypes;

  /// Yalnız küçülme kapısına takılan türler (kullanıcıya uyarı).
  final Set<String> shrunkTypes;
  const XtreamKeepDecision(this.keepTypes, this.shrunkTypes);
}

/// [before]: sync öncesi tür başına satır sayısı; [loaded]: bu sync'te
/// başarıyla yüklenen türler ve sayıları (0 dahil); [failedTypes]: hata
/// veren türler (hepsi korunur — yalnız ilki değil).
XtreamKeepDecision xtreamKeepDecision({
  required Map<String, int> before,
  required Map<String, int> loaded,
  required Set<String> failedTypes,
}) {
  final shrunk = <String>{};
  for (final e in loaded.entries) {
    if (failedTypes.contains(e.key)) continue;
    final prev = before[e.key] ?? 0;
    if ((prev > 0 && e.value == 0) ||
        isDrasticShrink(previous: prev, current: e.value)) {
      shrunk.add(e.key);
    }
  }
  return XtreamKeepDecision({...failedTypes, ...shrunk}, shrunk);
}

/// Xtream liste aksiyonu JSON dizi döndürmeli. `{}` / `null` /
/// `{"user_info":{"auth":0}}` gibi gövdeler "0 öğe" değil format hatasıdır.
List<dynamic> requireJsonList(Object? body, String action) {
  if (body is List) return body;
  throw FormatException(
      'Xtream $action: expected JSON list, got ${body.runtimeType}');
}
