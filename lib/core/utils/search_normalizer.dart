/// Arama normalizasyonu — Android paritesi (AppDatabase.kt searchKey).
///
/// SQLite LIKE / LOWER yalnız ASCII katlar; "İSTANBUL" ile "istanbul",
/// "Işık" ile "isik" eşleşmez. Katlama Dart'ta yapılır, sonuç
/// `channels.searchKey` kolonuna yazılır ve sorgu da aynı fonksiyondan geçer.
library;

const Map<String, String> _turkishFold = {
  'ı': 'i',
  'ş': 's',
  'ğ': 'g',
  'ç': 'c',
  'ö': 'o',
  'ü': 'u',
  'â': 'a',
  'î': 'i',
  'û': 'u',
};

/// Türkçe duyarlı küçük harfe katlama + trim.
/// İ/I/ı → i, ş→s, ğ→g, ç→c, ö→o, ü→u (+ â/î/û), genel lowercase.
String foldSearchText(String input) {
  if (input.isEmpty) return '';
  // İ/I lowercase'den ONCE: Dart 'İ'.toLowerCase() → "i̇" (i + U+0307) verir.
  final lower = input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('̇', '');
  final sb = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    sb.write(_turkishFold[ch] ?? ch);
  }
  return sb.toString().trim();
}

/// Kanal satırının arama anahtarı: fold(name + ' ' + seriesName).
String buildSearchKey(String name, String seriesName) =>
    foldSearchText(seriesName.isEmpty ? name : '$name $seriesName');

/// Kullanıcı sorgusundan `searchKey LIKE ? ESCAPE '\'` parametresi üretir.
/// Boş (trim sonrası) sorgu → null.
String? searchLikePattern(String query) {
  final folded = foldSearchText(query);
  if (folded.isEmpty) return null;
  final escaped = folded
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
  return '%$escaped%';
}
