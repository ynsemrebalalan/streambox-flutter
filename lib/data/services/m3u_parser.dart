import 'package:uuid/uuid.dart';
import '../../core/utils/search_normalizer.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';

class M3uParser {
  /// Tüm içeriği tek seferde parse eder (küçük listeler / testler).
  /// Büyük listeler [M3uLineParser] ile akışlı işlenir (bkz. M3uStreamLoader).
  static List<ChannelModel> parse(PlaylistModel playlist, String content) {
    final parser = M3uLineParser(
      playlistId:   playlist.id,
      allowedTypes: playlist.allowedTypes.split(',').toSet(),
    );
    final channels = <ChannelModel>[];
    for (final line in content.split('\n')) {
      final ch = parser.addLine(line);
      if (ch != null) channels.add(ch);
    }
    return channels;
  }

  /// `#EXTM3U url-tvg="..."` / `x-tvg-url="..."` başlığından EPG adresi.
  /// Virgülle birden fazla adres verilmişse ilki alınır. Yoksa null.
  static String? headerEpgUrl(String line) {
    final raw = _attr(line, 'url-tvg') ?? _attr(line, 'x-tvg-url');
    if (raw == null) return null;
    for (final part in raw.split(',')) {
      final v = part.trim();
      if (v.isNotEmpty) return v;
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  static String? _attr(String line, String attr) {
    final pattern = RegExp('$attr="([^"]*)"');
    return pattern.firstMatch(line)?.group(1);
  }

  static String _displayName(String line) {
    final idx = line.lastIndexOf(',');
    return idx >= 0 ? line.substring(idx + 1).trim() : '';
  }

  /// `group-title` attribute'unu virgülle bölerek çoklu kategoriye dönüştürür.
  /// Trim + boş eleman + duplicate filtresi. Boş input → [].
  /// Bilinen risk: bazı provider'lar tek bir kategori adında virgül kullanabilir
  /// ("Action, Drama" gibi); bu durumda 2 kategori olarak split olur. Bu nadir
  /// sapma riskine karşılık çoklu kategori desteği daha değerli (IPTV Extreme,
  /// TiviMate aynı davranışı sergiliyor).
  static List<String> _splitCategories(String raw) {
    if (raw.isEmpty) return const [];
    if (!raw.contains(',')) {
      final t = raw.trim();
      return t.isEmpty ? const [] : [t];
    }
    final out = <String>{};
    for (final part in raw.split(',')) {
      final v = part.trim();
      if (v.isNotEmpty) out.add(v);
    }
    return out.toList();
  }

  // Stream type detection — Android M3uParser.kt detectStreamType paritesi.
  // Hiyerarsi (en gucluden zayifa):
  //   1) URL path   — /series/ /movie/ /live/ (provider explicit)
  //   2) Per-item ad — guclu isaret (S01E05, 1x05, Sezon/Season N) her
  //      grupta dizi; zayif isaret (Bolum/Episode N) film grubunda degil
  //   3) VOD uzantisi + group film/dizi keyword
  //   4) Uzantisiz akis — CANLI; group keyword'u kanit degil
  //      (tek istisna: adda "(2024)" yil kalibi → movie)
  //
  // Bug fix (2026-11-03): tip tespiti `_parseSeries` cagiriyordu; onun
  // "son care" sondaki-sayi adimi "TRT 1", "Kanal 7 HD", "Rocky 2" gibi
  // adlari dizi yapiyordu. Tespit artik `_hasSeriesHint` kullanir; sondaki
  // sayi kurali yalniz tip zaten series iken ad/bolum ayirmak icindir.
  // Uzantisiz akista kategori keyword fallback'i de kaldirildi (Android
  // 2026-08-13: "▱ SINEMA"/"▱ BELGESEL" canli kategorileri movie sayiliyordu).
  /// Public wrapper — DB migration / runtime re-classify için kullanılır.
  /// Mevcut DB'de yanlış stream type'la kaydedilmiş kanallar için reclassify.
  static String detectStreamType(String category, String name,
      [String url = '']) => _detectStreamType(category, name, url);

  static String _detectStreamType(String category, String name,
      [String url = '']) {
    final u = url.toLowerCase();

    // 1) URL path — provider explicit endpoint
    if (u.contains('/series/')) return 'series';
    if (u.contains('/movie/') || u.contains('/movies/') ||
        u.contains('/vod/')) {
      return 'movie';
    }
    if (u.contains('/live/')) return 'live';

    // 2) Per-item ad pattern — en guclu icerik kaniti
    if (_hasSeriesHint(name, category)) return 'series';

    if (u.isNotEmpty) {
      // 3) VOD uzantisi — group'a bak ("Anime Film" → movie, "Anime" → series)
      if (_hasVodExtension(u)) {
        final g = _fold(category);
        if (_containsAny(g, _movieKeywords)) return 'movie';
        if (_containsAny(g, _seriesKeywords)) return 'series';
        return 'movie';
      }
      // Canli akis uzantilari/protokolleri (HLS, RTMP, vs.)
      if (u.contains('.m3u8') || u.contains('.ts')    ||
          u.startsWith('rtmp') || u.startsWith('rtsp') ||
          u.startsWith('udp')) {
        return 'live';
      }
    }

    // 4) Uzantisiz akis: CANLI. Yalnizca "Ad (2024)" yil kalibi VOD kaniti.
    // "(576p)" / "(720p)" cozunurluk sonekleri eslesmez: 4 hane + hepsi rakam.
    if (_reYearParens.hasMatch(name)) return 'movie';

    return 'live';
  }

  /// Tip tespiti icin dizi isareti. `_parseSeries`'ten farkli olarak
  /// sondaki-sayi ("TRT 1", "Rocky 2") kurali YOK.
  ///  - Guclu: S01E05, 1x05, "Sezon N" / "N. Sezon" / "Season N" — her grupta.
  ///  - Zayif: "Bolum N" / "N. Bolum" / "Episode N" — film grubunda sayilmaz
  ///    ("Dune: Bolum 2" = Part Two, "O: Bolum 2" = It: Chapter Two).
  static bool _hasSeriesHint(String name, String group) {
    if (_reSxEx.hasMatch(name) || _reDxD.hasMatch(name)) return true;
    if (_reSeasonHint.hasMatch(name)) return true;
    final weak = _reBolumOnly.hasMatch(name) || _reNumBolum.hasMatch(name);
    return weak && !_isMovieOnlyGroup(group);
  }

  /// Grup adi acikca film grubu mu? ("DUBLAJ FİLMLER", "VİZYON SİNEMA").
  /// Grup adinda dizi kelimesi de geciyorsa ("DİZİ FİLMLERİ") film sayilmaz.
  static bool _isMovieOnlyGroup(String group) {
    final g = _fold(group);
    return _containsAny(g, _movieOnlyGroupKeywords) &&
        !_containsAny(g, _seriesKeywords);
  }

  static bool _hasVodExtension(String lowerUrl) {
    var path = lowerUrl;
    final q = path.indexOf('?');
    if (q >= 0) path = path.substring(0, q);
    final dot = path.lastIndexOf('.');
    if (dot <= 0) return false;
    return _vodExtensions.contains(path.substring(dot + 1));
  }

  /// Keyword eslesmesi icin Turkce katlama ("FİLMLER" → "filmler").
  /// Dart toLowerCase 'İ' → "i̇" (birlesik nokta) verir; contains('film') kacar.
  static String _fold(String s) => foldSearchText(s);

  static bool _containsAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  // Android M3uParser.kt sabitleri (katlanmis halde).
  static const _vodExtensions = {
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'divx', 'webm',
  };
  static const _movieOnlyGroupKeywords = [
    'movie', 'film', 'filim', 'sinema', 'cinema', 'vod', 'vizyon',
  ];
  static const _seriesKeywords = [
    'series', 'serie', 'dizi', 'sezon', 'season',
    'show', 'tv show', 'episode', 'bolum',
    'sitcom', 'anime', 'cartoon', 'cizgi',
  ];
  static const _movieKeywords = [
    'movie', 'film', 'filim', 'vod', 'cinema', 'sinema',
    'belgesel', 'documentary',
  ];

  static final _reYearParens = RegExp(r'\((\d{4})\)');
  // "Sezon 2" / "2. Sezon" / "Season 3" — sayi zorunlu ("Season TV" eslesmez).
  static final _reSeasonHint = RegExp(
      r'(?:\b(?:sezon|season)\s*\d{1,2})|(?:(?<![\d])\d{1,2}\s*\.?\s*sezon)',
      caseSensitive: false);

  // Android M3uParser.kt:103-203 pattern'lariyla eslesir.
  // Sira onemli: once en spesifik (SxxExx), sonra 1x05, sonra dil tabanli.
  //
  // Regex'ler ayri const olarak tutulur (isolate'da her parse'da yeniden
  // compile edilmesin diye static).
  static final _reSxEx      = RegExp(r'[Ss](\d{1,2})\s*[\.\-]?\s*[Ee](\d{1,3})');
  static final _reDxD       = RegExp(r'(?<![\d])(\d{1,2})x(\d{1,3})(?![\d])');
  static final _reSezon     = RegExp(
      r'sezon\s*(\d{1,2}).*?b[oö]l[uü]m\s*(\d{1,3})',
      caseSensitive: false);
  // Turkce tersten: "1. Sezon 5. Bolum" / "1.Sezon 5.Bölüm"
  static final _reSezonRev  = RegExp(
      r'(\d{1,2})\s*\.?\s*sezon.*?(\d{1,3})\s*\.?\s*b[oö]l[uü]m',
      caseSensitive: false);
  static final _reSeason    = RegExp(
      r'[Ss]eason\s*(\d{1,2}).*?[Ee]pisode\s*(\d{1,3})',
      caseSensitive: false);
  static final _reBolumOnly = RegExp(
      r'(?:^|\s)(?:b[oö]l[uü]m|episode|ep|bolum)\.?\s*(\d{1,3})\b',
      caseSensitive: false);
  // Rakam onde: "5. Bolum" / "5.Bölüm" / "12 Episode" / "05.Ep"
  static final _reNumBolum  = RegExp(
      r'(?<![\d])(\d{1,3})\s*\.?\s*(?:b[oö]l[uü]m|bolum|episode|ep)\b',
      caseSensitive: false);
  // Son care: isim sonundaki son sayi (yil 1900-2099 haric, max 999).
  // Provider bazen sadece "Dizi Adi - 05" / "Dizi Adi 12" gibi verir.
  static final _reTrailing  = RegExp(r'(\d+)(?:[^\d]*)$');

  /// Public wrapper — DB migration / in-memory re-parse icin kullanilabilir.
  /// (cleanedSeriesName, season, episode) doner. Eslesme yoksa (name, 0, 0).
  static (String, int, int) parseSeriesInfo(String name) => _parseSeries(name);

  static (String, int, int) _parseSeries(String name) {
    // 1) S01E05 / s01 e05 / S01.E05 / S01-E05
    var m = _reSxEx.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final e = int.tryParse(m.group(2) ?? '') ?? 0;
      if (s > 0 || e > 0) {
        return (_cleanName(name, m.start), s, e);
      }
    }

    // 2) 1x05 compact format (basinda/sonunda rakam olmayacak sekilde)
    m = _reDxD.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final e = int.tryParse(m.group(2) ?? '') ?? 0;
      if (s > 0 || e > 0) {
        return (_cleanName(name, m.start), s, e);
      }
    }

    // 3) Turkce: "Sezon 1 Bolum 5" / "Sezon 1 Bölüm 5"
    m = _reSezon.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final e = int.tryParse(m.group(2) ?? '') ?? 0;
      if (s > 0 || e > 0) {
        return (_cleanName(name, m.start), s, e);
      }
    }

    // 3b) Turkce tersten: "1. Sezon 5. Bolum"
    m = _reSezonRev.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final e = int.tryParse(m.group(2) ?? '') ?? 0;
      if (s > 0 || e > 0) {
        return (_cleanName(name, m.start), s, e);
      }
    }

    // 4) Ingilizce: "Season 1 Episode 5"
    m = _reSeason.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final e = int.tryParse(m.group(2) ?? '') ?? 0;
      if (s > 0 || e > 0) {
        return (_cleanName(name, m.start), s, e);
      }
    }

    // 5) "Bolum 5", "Episode 5", "Ep 5" — season belirsiz, 0 don.
    // Caller mevcut seasonNumber'i korur; 3. sezondaki bolum yanlislikla
    // 1. sezona tasinmaz.
    m = _reBolumOnly.firstMatch(name);
    if (m != null) {
      final e = int.tryParse(m.group(1) ?? '') ?? 0;
      if (e > 0) {
        return (_cleanName(name, m.start), 0, e);
      }
    }

    // 5b) "5. Bolum", "5.Bölüm", "12 Episode" (rakam onde) — season belirsiz.
    m = _reNumBolum.firstMatch(name);
    if (m != null) {
      final e = int.tryParse(m.group(1) ?? '') ?? 0;
      if (e > 0) {
        return (_cleanName(name, m.start), 0, e);
      }
    }

    // 6) Son care: isim sonundaki son sayi. Yil (1900-2099) / 999+ atla.
    // Season belirsiz → 0.
    m = _reTrailing.firstMatch(name);
    if (m != null) {
      final n = int.tryParse(m.group(1) ?? '') ?? 0;
      final isYear = n >= 1900 && n <= 2099;
      if (n > 0 && n <= 999 && !isYear) {
        return (_cleanName(name, m.start), 0, n);
      }
    }

    return (name, 0, 0);
  }

  /// Match baslangicindan once kalan kismi dizi adi olarak al,
  /// sonundaki ayirici karakterleri temizle.
  static String _cleanName(String name, int matchStart) {
    if (matchStart <= 0) return name.trim();
    var s = name.substring(0, matchStart).trim();
    while (s.isNotEmpty && (s.endsWith('-') ||
           s.endsWith('_') || s.endsWith('.') || s.endsWith(':') ||
           s.endsWith('|'))) {
      s = s.substring(0, s.length - 1).trim();
    }
    return s;
  }
}

/// Akışlı M3U satır parser'ı — satır satır beslenir, tamamlanan kanalı
/// döndürür. Bellek sabit: tüm liste hiç tutulmaz (100K+ kanal).
/// Isolate içinde de çalışır (Flutter bağımlılığı yok).
class M3uLineParser {
  static const _uuid = Uuid();

  final String playlistId;
  final Set<String> allowedTypes;
  int _sortIdx;

  /// `#EXTM3U` başlığından okunan EPG adresi (url-tvg / x-tvg-url).
  String? epgUrl;

  String? _name, _logo, _category, _tvgId;
  List<String> _categories = const [];

  M3uLineParser({
    required this.playlistId,
    required this.allowedTypes,
    int startSortOrder = 0,
  }) : _sortIdx = startSortOrder;

  ChannelModel? addLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty) return null;

    if (line.startsWith('#EXTM3U')) {
      epgUrl ??= M3uParser.headerEpgUrl(line);
      return null;
    }
    if (line.startsWith('#EXTINF')) {
      // Görünen ad (virgül sonrası) öncelikli; boşsa DOLU tvg-name.
      // tvg-name="" eskiden adı '' yapıyordu.
      final display = M3uParser._displayName(line);
      final tvgName = M3uParser._attr(line, 'tvg-name')?.trim() ?? '';
      _name  = display.isNotEmpty ? display : tvgName;
      _logo  = M3uParser._attr(line, 'tvg-logo') ?? '';
      _tvgId = M3uParser._attr(line, 'tvg-id') ?? '';
      // v6: çoklu kategori — `group-title="Aksiyon,Komedi"` virgülle
      // ayrılmışsa kanal birden fazla kategoriye ait sayılır.
      final rawGroup = M3uParser._attr(line, 'group-title') ?? 'Genel';
      _categories = M3uParser._splitCategories(rawGroup);
      _category = _categories.isNotEmpty ? _categories.first : 'Genel';
      return null;
    }
    if (line.startsWith('#')) return null;
    final name = _name;
    if (name == null) return null;
    _name = null;

    // URL bilgisiyle stream type'ı belirle — en sağlam tespit URL
    // extension/path'ten gelir. 2026-05-11 "canlı içinde filmler vardı".
    final url = line;
    final category = _category ?? 'Genel';
    final type = M3uParser._detectStreamType(category, name, url);
    if (!allowedTypes.contains(type)) return null;
    var seriesName = '';
    var season = 0, episode = 0;
    if (type == 'series') {
      final parsed = M3uParser._parseSeries(name);
      seriesName = parsed.$1;
      season     = parsed.$2;
      episode    = parsed.$3;
    }
    return ChannelModel(
      id:            _uuid.v5(Namespace.url.value, '$playlistId:$url'),
      playlistId:    playlistId,
      name:          name,
      streamUrl:     url,
      logoUrl:       _logo ?? '',
      category:      category,
      categoryIds:   _categories,
      streamType:    type,
      tvgId:         _tvgId ?? '',
      sortOrder:     _sortIdx++,
      seriesName:    seriesName,
      seasonNumber:  season,
      episodeNumber: episode,
    );
  }
}

/// M3U URL'inden son kullanma tarihi (Android EditPlaylistScreen
/// parseM3uExpiry paritesi): `exp` / `expiryDate` / `expires` query
/// parametresi, saniye veya ms. Bulunamazsa null.
int? parseM3uExpiry(String url) {
  if (url.trim().isEmpty) return null;
  final Uri uri;
  try {
    uri = Uri.parse(url.trim());
  } catch (_) {
    return null;
  }
  final q = uri.queryParameters;
  final raw = q['exp'] ?? q['expiryDate'] ?? q['expires'];
  if (raw == null) return null;
  final v = int.tryParse(raw.trim());
  if (v == null || v <= 0) return null;
  return v > 1000000000000 ? v : v * 1000;
}
