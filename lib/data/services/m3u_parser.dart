import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/device_tier.dart';
import '../../core/utils/http_client.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';

class M3uParser {
  static const _uuid = Uuid();

  /// Fetches and parses an M3U playlist. Returns parsed channels.
  /// Cihaz tier'ina gore adaptive parse:
  /// - High/Mid: isolate'da parse (UI donmaz)
  /// - Low: ana thread'de parse (isolate spawn overhead'i atlanir)
  ///        AMA 5000+ kanal varsa low'da bile isolate kullanilir.
  static Future<List<ChannelModel>> fetchAndParse(PlaylistModel playlist) async {
    // ignore: avoid_print
    print('[M3uParser] Fetching: ${playlist.url}');
    final response = await AppHttp.get(
      Uri.parse(playlist.url),
      timeout: const Duration(seconds: 30),
      retries: 3,
    );
    // ignore: avoid_print
    print('[M3uParser] HTTP ${response.statusCode}, '
        '${response.bodyBytes.length}B');
    if (response.statusCode != 200) {
      throw HttpStatusException(response.statusCode, playlist.url);
    }
    final content = utf8.decode(response.bodyBytes);

    // Kaba satir sayisi tahmini: isolate karari icin
    final estimatedLines = '\n'.allMatches(content).length;
    final useIsolate = DeviceProfile.useIsolateForParse ||
        estimatedLines > DeviceProfile.isolateThreshold;

    if (kDebugMode) {
      debugPrint('[M3uParser] lines~$estimatedLines, '
          'isolate=$useIsolate, tier=${DeviceProfile.tier}');
    }

    final List<ChannelModel> result;
    if (useIsolate) {
      result = await compute(_parseInIsolate, _ParseArgs(playlist, content));
    } else {
      result = parse(playlist, content);
    }
    // ignore: avoid_print
    print('[M3uParser] Parsed ${result.length} channels');
    return result;
  }

  static List<ChannelModel> _parseInIsolate(_ParseArgs args) =>
      parse(args.playlist, args.content);

  static List<ChannelModel> parse(PlaylistModel playlist, String content) {
    final lines   = content.split('\n');
    final channels = <ChannelModel>[];
    final allowed  = playlist.allowedTypes.split(',');

    String? name, logo, category, tvgId, seriesName;
    List<String> categories = const [];
    int seasonNum = 0, epNum = 0, sortIdx = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF')) {
        name = _attr(line, 'tvg-name')    ?? _displayName(line);
        logo = _attr(line, 'tvg-logo')    ?? '';
        tvgId= _attr(line, 'tvg-id')      ?? '';
        // v6: çoklu kategori — `group-title="Aksiyon,Komedi"` virgülle
        // ayrılmışsa kanal birden fazla kategoriye ait sayılır. Tek değer
        // ise legacy davranış: liste tek elemanlı, display = aynısı.
        final rawGroup = _attr(line, 'group-title') ?? 'Genel';
        categories = _splitCategories(rawGroup);
        category = categories.isNotEmpty ? categories.first : 'Genel';
        // streamType nihai olarak URL geldikten sonra `_detectStreamType` ile
        // belirlenir (URL extension/path en güçlü sinyal). 2026-05-11.
        seriesName = '';
        seasonNum  = 0;
        epNum      = 0;
      } else if (!line.startsWith('#') && name != null) {
        final url = line.trim();
        if (url.isNotEmpty) {
          // URL bilgisiyle stream type'ı YENİDEN değerlendir — en sağlam
          // tespit URL extension'dan (.mp4 = movie, .m3u8 = live, vs.) ve
          // Xtream path segmentinden (/live/, /movie/, /series/) gelir.
          // 2026-05-11 kullanıcı raporu: "canlı içinde filmler vardı".
          final finalType = _detectStreamType(category ?? '', name, url);
          if (finalType == 'series') {
            final parsed = _parseSeries(name);
            seriesName = parsed.$1;
            seasonNum  = parsed.$2;
            epNum      = parsed.$3;
          }
          if (allowed.contains(finalType)) {
            channels.add(ChannelModel(
              id:            _uuid.v5(Namespace.url.value, '${playlist.id}:$url'),
              playlistId:    playlist.id,
              name:          name,
              streamUrl:     url,
              logoUrl:       logo ?? '',
              category:      category ?? 'Genel',
              categoryIds:   categories,
              streamType:    finalType,
              tvgId:         tvgId ?? '',
              sortOrder:     sortIdx++,
              seriesName:    seriesName ?? '',
              seasonNumber:  seasonNum,
              episodeNumber: epNum,
            ));
          }
        }
        name = null;
      }
    }
    return channels;
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

  // Stream type detection. Sira kritik:
  //   1) Series kategori sinyali (en guclu)
  //   2) Series isim pattern (Sxx Exx / Bolum / Episode)
  //   3) Movie kategori sinyali
  //   4) Movie isim pattern (yil parantezi)
  //   5) Default live
  //
  // Onceki implementasyon movie'yi seriyi onunde kontrol ediyordu —
  // "Dirilis Ertugrul (2014)" gibi yil parantezli diziler movie'ye
  // gidiyordu ve dizi sekmesinde gorunmuyordu. Ayrica series sadece
  // season>0 ile yakalanip "Yargi - Bolum 5" (season=0, episode=5)
  // live'a dusuyordu.
  /// Public wrapper — DB migration / runtime re-classify için kullanılır.
  /// Mevcut DB'de yanlış stream type'la kaydedilmiş kanallar için reclassify.
  static String detectStreamType(String category, String name,
      [String url = '']) => _detectStreamType(category, name, url);

  static String _detectStreamType(String category, String name,
      [String url = '']) {
    final cat = category.toLowerCase();
    final nm  = name.toLowerCase();
    final u   = url.toLowerCase();

    // Sıra kritik (2026-05-11 v3, Kotlin StreamBox referansı):
    // URL path > Name pattern > URL extension > Kategori > Year > Default.
    // URL path provider'ın endpoint'i; en güvenilir sinyal.

    // 1) URL path — provider explicit endpoint
    if (u.isNotEmpty) {
      if (u.contains('/series/')) return 'series';
      if (u.contains('/movie/')  || u.contains('/movies/') ||
          u.contains('/vod/')) {
        // Series isim pattern movie endpoint'inde de olabilir (Xtream bazı
        // provider'larda dizileri de /movie/ altına koyar)
        final p = _parseSeries(name);
        if (p.$2 > 0 || p.$3 > 0) return 'series';
        return 'movie';
      }
      if (u.contains('/live/')) return 'live';
    }

    // 2) Name pattern — S01E01/Bölüm/Sezon (tartışmasız series)
    final p = _parseSeries(name);
    if (p.$2 > 0 || p.$3 > 0) return 'series';

    // 3) URL extension — VOD dosyaları
    if (u.isNotEmpty) {
      if (u.endsWith('.mp4')  || u.endsWith('.mkv')  ||
          u.endsWith('.avi')  || u.endsWith('.mov')  ||
          u.endsWith('.webm') || u.endsWith('.flv')  ||
          u.endsWith('.wmv')  || u.endsWith('.divx') ||
          u.contains('.mp4?') || u.contains('.mkv?') ||
          u.contains('.avi?')) {
        // VOD ext + series kategori → series
        if (cat.contains('series') || cat.contains('dizi') ||
            cat.contains('anime')  || cat.contains('cartoon') ||
            cat.contains('çizgi')  || cat.contains('cizgi')) {
          return 'series';
        }
        return 'movie';
      }
      // Live stream extensions/protocols (HLS chunks, RTMP, vs.)
      if (u.contains('.m3u8') || u.contains('.ts')    ||
          u.startsWith('rtmp') || u.startsWith('rtsp') ||
          u.startsWith('udp')) {
        return 'live';
      }
    }

    // 4) Kategori fallback (URL belirsiz olduğunda)
    if (cat.contains('series') || cat.contains('dizi') ||
        cat.contains('show')   || cat.contains('tv shows')) {
      return 'series';
    }
    if (cat.contains('movie')    || cat.contains('film')    ||
        cat.contains('vod')      || cat.contains('cinema')  ||
        cat.contains('sinema')   ||
        cat.contains('aksiyon')  || cat.contains('action')  ||
        cat.contains('komedi')   || cat.contains('comedy')  ||
        cat.contains('drama')    ||
        cat.contains('belgesel') || cat.contains('document') ||
        cat.contains('macera')   || cat.contains('adventure') ||
        cat.contains('korku')    || cat.contains('horror')  ||
        cat.contains('romantik') || cat.contains('romance') ||
        cat.contains('bilim kurgu') || cat.contains('sci-fi') ||
        cat.contains('sci fi')   || cat.contains('fantastic') ||
        cat.contains('animasyon')|| cat.contains('animation') ||
        cat.contains('cartoon')  || cat.contains('çizgi')   ||
        cat.contains('cizgi')    ||
        cat.contains('yabanci')  || cat.contains('yabancı') ||
        cat.contains('yerli')    || cat.contains('turkish') ||
        cat.contains('foreign')  || cat.contains('gerilim') ||
        cat.contains('thriller') || cat.contains('savaş')   ||
        cat.contains('savas')    || cat.contains('war')     ||
        cat.contains('tarih')    || cat.contains('history') ||
        cat.contains('western')  || cat.contains('müzikal') ||
        cat.contains('muzikal')  || cat.contains('musical')) {
      return 'movie';
    }

    // 5) Year parens "Film Adi (2024)"
    if (RegExp(r'\(\d{4}\)\s*$').hasMatch(nm)) return 'movie';

    // 6) Default
    return 'live';
  }

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

/// Isolate'a gecirilen argument tasiyicisi.
class _ParseArgs {
  final PlaylistModel playlist;
  final String content;
  const _ParseArgs(this.playlist, this.content);
}
