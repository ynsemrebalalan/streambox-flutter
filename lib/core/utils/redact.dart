/// Hata raporlarından kimlik bilgisi temizleme.
///
/// Oynatıcı hata metni (mpv `_player.stream.error`) çoğu zaman tam akış
/// URL'sini içerir; Xtream'de URL yolunda kullanıcı adı + şifre, M3U'da
/// `get.php?username=&password=`, Stalker'da `mac=` / `token=` bulunur.
/// Firestore'a giden her serbest metin bundan geçirilir.
library;

const redactedMark = '<redacted>';

final _urlRe = RegExp(r'\w+://\S+');
final _xtreamPathRe =
    RegExp(r'/(live|movie|series)/[^/\s?#]+/[^/\s?#]+/', caseSensitive: false);
final _queryRe = RegExp(r'\b(username|password|token|mac)=[^&\s]+',
    caseSensitive: false);
final _hostRe = RegExp(r'^(\w+)://(?:[^@/\s]*@)?([^/\s?#]+)');

String _redactUrl(String url) {
  final m = _hostRe.firstMatch(url);
  if (m == null) return redactedMark;
  return '${m.group(1)}://${m.group(2)}/$redactedMark';
}

/// URL'ler → `scheme://host[:port]/<redacted>`; kalan Xtream yol parçaları
/// ve `username= password= token= mac=` değerleri → `<redacted>`.
String redactSensitive(String input) {
  if (input.isEmpty) return input;
  var s = input.replaceAllMapped(_urlRe, (m) => _redactUrl(m.group(0)!));
  s = s.replaceAllMapped(
      _xtreamPathRe, (m) => '/${m.group(1)}/$redactedMark/$redactedMark/');
  s = s.replaceAllMapped(_queryRe, (m) => '${m.group(1)}=$redactedMark');
  return s;
}
