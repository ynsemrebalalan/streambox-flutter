import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../models/channel_model.dart';

/// Stalker Middleware / MAG portal protokolunun saf (ag'siz) parcalari:
/// adres normalizasyonu, MAC dogrulama, MAG basliklari, JSON ayristirma ve
/// sayfalama. Android `StalkerApiClient.kt` / `StalkerLoader.kt` paritesi.

/// Tek bir API ucu. [base] Referer (`$base/c/`) ve export icin; [api]
/// `portal.php` veya `stalker_portal/server/load.php`.
class StalkerEndpoint {
  final String base;
  final String api;
  const StalkerEndpoint(this.base, this.api);

  String get referer => '$base/c/';

  @override
  bool operator ==(Object other) =>
      other is StalkerEndpoint && other.base == base && other.api == api;
  @override
  int get hashCode => Object.hash(base, api);
  @override
  String toString() => 'StalkerEndpoint($api)';
}

class StalkerUrls {
  StalkerUrls._();

  static const _portalPhp = '/portal.php';
  static const _loadPhp = '/server/load.php';
  static const _stalkerPortal = '/stalker_portal';

  /// Kaydedilecek bicim: bosluk / query / fragment / sondaki slash'lar
  /// kirpilir, sema yoksa `http://` eklenir.
  static String clean(String input) {
    var u = input.trim();
    if (u.isEmpty) return u;
    if (!u.contains('://')) u = 'http://$u';
    for (final sep in const ['#', '?']) {
      final i = u.indexOf(sep);
      if (i >= 0) u = u.substring(0, i);
    }
    return _trimSlashes(u);
  }

  static String _trimSlashes(String s) {
    var u = s;
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  static bool _ends(String u, String suffix) =>
      u.toLowerCase().endsWith(suffix);

  static String _cut(String u, String suffix) =>
      u.substring(0, u.length - suffix.length);

  /// Kullanicinin yazdigi portal adresinden denenecek API uclari (sirali).
  /// Desteklenen bicimler: kok (`http://h:8080`), MAG web arayuzu (`/c/`,
  /// `/c/index.html`), `/stalker_portal/`, dogrudan `portal.php` ve
  /// `server/load.php`.
  static List<StalkerEndpoint> endpoints(String input) {
    var u = clean(input);
    if (u.isEmpty) return const [];
    if (_ends(u, _portalPhp)) {
      return [StalkerEndpoint(_cut(u, _portalPhp), u)];
    }
    if (_ends(u, _loadPhp)) {
      return [StalkerEndpoint(_cut(u, _loadPhp), u)];
    }
    for (final page in const ['/index.html', '/index.php']) {
      if (_ends(u, page)) u = _trimSlashes(_cut(u, page));
    }
    if (_ends(u, '/c')) u = _trimSlashes(_cut(u, '/c'));
    if (_ends(u, _stalkerPortal)) {
      final root = _cut(u, _stalkerPortal);
      return [
        StalkerEndpoint(u, '$u$_loadPhp'),
        StalkerEndpoint(root, '$root$_portalPhp'),
      ];
    }
    return [
      StalkerEndpoint(u, '$u$_portalPhp'),
      StalkerEndpoint('$u$_stalkerPortal', '$u$_stalkerPortal$_loadPhp'),
    ];
  }

  /// Portal M3U disa aktarim adaylari (Android `withM3uExportStream` sirasi).
  static List<String> exportCandidates(StalkerEndpoint e, String mac) {
    final root =
        _ends(e.base, _stalkerPortal) ? _cut(e.base, _stalkerPortal) : e.base;
    return [
      '${e.api}?action=export_itv_list&type=export_m3u&mac=$mac&output=hls',
      '${e.api}?action=export_itv_list&type=m3u_plus&mac=$mac',
      '$root/get.php?username=$mac&password=$mac&type=m3u_plus&output=hls',
    ];
  }
}

/// MAC adresi yardimcilari (`XX:XX:XX:XX:XX:XX`, buyuk harf).
class StalkerMac {
  StalkerMac._();

  static final _valid = RegExp(r'^([0-9A-F]{2}:){5}[0-9A-F]{2}$');
  static final _bareHex = RegExp(r'^[0-9A-F]{12}$');

  /// Gecerliyse standart bicim, degilse null. `-` ayiraci ve ayiracsiz
  /// 12 hex karakter de kabul edilir.
  static String? normalize(String input) {
    var m = input.trim().toUpperCase().replaceAll('-', ':');
    if (_bareHex.hasMatch(m)) m = _colonize(m);
    return _valid.hasMatch(m) ? m : null;
  }

  static bool isValid(String input) => normalize(input) != null;

  /// Yazarken filtre (Android onValueChange): yalniz hex + `:`, buyuk harf;
  /// ayiracsiz 12 hex yapistirildiysa kolonlu bicime cevrilir.
  static String format(String input) {
    final m = input.toUpperCase().replaceAll(RegExp('[^0-9A-F:]'), '');
    return _bareHex.hasMatch(m) ? _colonize(m) : m;
  }

  static String _colonize(String hex12) =>
      [for (var i = 0; i < 12; i += 2) hex12.substring(i, i + 2)].join(':');

  /// Rastgele MAG MAC'i (`00:1A:79:` oneki) — Android "Uret" dugmesi.
  static String random([Random? rng]) {
    final r = rng ?? Random.secure();
    String b() => r.nextInt(256).toRadixString(16).padLeft(2, '0');
    return '00:1A:79:${b()}:${b()}:${b()}'.toUpperCase();
  }
}

/// MAG kutu taklidi basliklari — pek cok portal bunlari zorunlu tutar.
class StalkerHeaders {
  StalkerHeaders._();

  static const userAgent =
      'Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 '
      '(KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3';
  static const timezone = 'Europe/Istanbul';

  static Map<String, String> build({
    required StalkerEndpoint endpoint,
    required String mac,
    String token = '',
    String lang = 'en',
  }) => {
    'Cookie': 'mac=$mac; stb_lang=$lang; timezone=$timezone',
    'User-Agent': userAgent,
    'X-User-Agent': 'Model: MAG200; Link: Ethernet',
    'Accept': '*/*',
    'Referer': endpoint.referer,
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

/// Kanal sayfasi.
class StalkerPage {
  final List<Map<String, dynamic>> items;
  final int totalItems;
  final int maxPageItems;
  const StalkerPage(this.items, this.totalItems, this.maxPageItems);
}

/// Portal JSON yanitlari (`{"js": ...}`) — tolerant ayristirma.
class StalkerJson {
  StalkerJson._();

  /// Govdeyi coz; JSON degilse null. BOM / ondeki cop karakterler atlanir.
  static Object? decode(List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: true);
    final start = text.indexOf(RegExp(r'[{\[]'));
    if (start < 0) return null;
    try {
      return jsonDecode(text.substring(start));
    } on FormatException {
      return null;
    }
  }

  static Object? js(Object? decoded) => decoded is Map ? decoded['js'] : null;

  static String _str(Object? v) => v?.toString() ?? '';

  static int _int(Object? v, int fallback) =>
      v is int ? v : int.tryParse(_str(v).trim()) ?? fallback;

  /// Handshake token'i; yoksa / bossa null.
  static String? token(Object? decoded) {
    final j = js(decoded);
    if (j is! Map) return null;
    final t = _str(j['token']).trim();
    return t.isEmpty ? null : t;
  }

  static StalkerPage page(Object? decoded) {
    final j = js(decoded);
    List<Map<String, dynamic>> items(Object? raw) =>
        raw is List
            ? [
              for (final e in raw)
                if (e is Map) e.cast<String, dynamic>(),
            ]
            : const [];
    if (j is List) return StalkerPage(items(j), 0, 14);
    if (j is! Map) return const StalkerPage([], 0, 14);
    return StalkerPage(
      items(j['data']),
      _int(j['total_items'], 0),
      _int(j['max_page_items'], 14),
    );
  }

  /// `get_genres` → id → baslik (`*` = "Tumu" atlanir).
  static Map<String, String> genres(Object? decoded) {
    final j = js(decoded);
    final out = <String, String>{};
    if (j is! List) return out;
    for (final g in j) {
      if (g is! Map) continue;
      final id = _str(g['id']).trim();
      final title = _str(g['title']).trim();
      if (id.isEmpty || id == '*' || title.isEmpty) continue;
      out[id] = title;
    }
    return out;
  }

  /// `create_link` → oynatilabilir URL (onek temizlenmis) veya null.
  static String? linkCmd(Object? decoded) {
    final j = js(decoded);
    if (j is! Map) return null;
    final cmd = cleanStalkerCmd(_str(j['cmd']));
    return cmd.isEmpty ? null : cmd;
  }
}

final _cmdPrefix = RegExp(r'^([a-z0-9_]+)\s+(\S.*)$', caseSensitive: false);

/// `"ffmpeg http://..."` / `"ffrt http://..."` → `"http://..."`.
String cleanStalkerCmd(String raw) {
  final s = raw.trim();
  final m = _cmdPrefix.firstMatch(s);
  return m == null ? s : m.group(2)!.trim();
}

/// Oynatmadan once `create_link` gerekir mi? (Android resolveUrl kurali:
/// onekli komut veya `localhost` isaretcisi; M3U export'tan gelen dogrudan
/// URL'ler aynen oynatilir.)
bool stalkerNeedsResolve(String url) {
  final s = url.trim();
  if (s.isEmpty) return false;
  return _cmdPrefix.hasMatch(s) || s.contains('localhost');
}

/// Kanal JSON → `channels` satiri (`ChannelModel.toMap()` + `__cats`).
class StalkerMapper {
  StalkerMapper._();
  static const _uuid = Uuid();
  static const categoriesKey = '__cats';
  static const fallbackCategory = 'Canli';

  static String _str(Object? v) => v?.toString().trim() ?? '';

  static Map<String, Object?>? channel(
    Map<String, dynamic> item, {
    required String playlistId,
    required Map<String, String> genres,
    required int sortOrder,
  }) {
    final id = _str(item['id']);
    var cmd = _str(item['cmd']);
    if (id.isEmpty && cmd.isEmpty) return null;
    if (cmd.isEmpty) cmd = 'ffrt http://localhost/ch/$id';
    final genreId =
        _str(item['tv_genre_id']).isNotEmpty
            ? _str(item['tv_genre_id'])
            : _str(item['genre_id']);
    final genreName = genres[genreId] ?? _str(item['genre']);
    final category = genreName.isEmpty ? fallbackCategory : genreName;
    final logo = _str(item['logo']);
    final ch = ChannelModel(
      id: _uuid.v5(
        Namespace.url.value,
        '$playlistId:stalker:${id.isNotEmpty ? id : cmd}',
      ),
      playlistId: playlistId,
      name: _str(item['name']),
      streamUrl: cmd,
      logoUrl: logo.startsWith('http') ? logo : '',
      category: category,
      categoryIds: [category],
      streamType: 'live',
      sortOrder: sortOrder,
      tvgId: _str(item['xmltv_id']),
    );
    return {
      ...ch.toMap(),
      categoriesKey: [category],
    };
  }
}

/// Sayfalama karari (Android getAllChannels + tekrar/sonsuz dongu korumasi).
class StalkerPaging {
  StalkerPaging._();

  /// Bozuk `total_items` ile sonsuz istek atilmasin.
  static const maxPageCap = 2000;

  static int maxPages(int totalItems, int perPage) {
    if (perPage <= 0) return 1;
    return (totalItems + perPage - 1) ~/ perPage;
  }

  static bool hasMore({
    required int page,
    required int totalItems,
    required int perPage,
    required int fetched,
    required int lastPageSize,
  }) {
    if (lastPageSize <= 0 || page >= maxPageCap) return false;
    if (totalItems > 0 && fetched >= totalItems) return false;
    return page < maxPages(totalItems, perPage);
  }
}
