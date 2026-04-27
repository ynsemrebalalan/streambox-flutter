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
    final response = await AppHttp.get(
      Uri.parse(playlist.url),
      timeout: const Duration(seconds: 30),
      retries: 3,
    );
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

    if (useIsolate) {
      return compute(_parseInIsolate, _ParseArgs(playlist, content));
    } else {
      return parse(playlist, content);
    }
  }

  static List<ChannelModel> _parseInIsolate(_ParseArgs args) =>
      parse(args.playlist, args.content);

  static List<ChannelModel> parse(PlaylistModel playlist, String content) {
    final lines   = content.split('\n');
    final channels = <ChannelModel>[];
    final allowed  = playlist.allowedTypes.split(',');

    String? name, logo, category, tvgId, streamType, seriesName;
    int seasonNum = 0, epNum = 0, sortIdx = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF')) {
        name = _attr(line, 'tvg-name')    ?? _displayName(line);
        logo = _attr(line, 'tvg-logo')    ?? '';
        tvgId= _attr(line, 'tvg-id')      ?? '';
        category = _attr(line, 'group-title') ?? 'Genel';
        streamType = _detectStreamType(category, name);
        seriesName = '';
        seasonNum  = 0;
        epNum      = 0;

        if (streamType == 'series') {
          final parsed = _parseSeries(name);
          seriesName = parsed.$1;
          seasonNum  = parsed.$2;
          epNum      = parsed.$3;
        }
      } else if (!line.startsWith('#') && name != null) {
        final url = line.trim();
        if (url.isNotEmpty && allowed.contains(streamType ?? 'live')) {
          channels.add(ChannelModel(
            id:            _uuid.v5(Namespace.url.value, '${playlist.id}:$url'),
            playlistId:    playlist.id,
            name:          name,
            streamUrl:     url,
            logoUrl:       logo ?? '',
            category:      category ?? 'Genel',
            streamType:    streamType ?? 'live',
            tvgId:         tvgId ?? '',
            sortOrder:     sortIdx++,
            seriesName:    seriesName ?? '',
            seasonNumber:  seasonNum,
            episodeNumber: epNum,
          ));
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

  static String _detectStreamType(String category, String name) {
    final cat  = category.toLowerCase();
    final nm   = name.toLowerCase();
    if (cat.contains('movie') || cat.contains('film') ||
        cat.contains('vod')   || nm.contains(' (') && nm.contains(RegExp(r'\d{4}'))) {
      return 'movie';
    }
    if (cat.contains('series') || cat.contains('dizi') ||
        cat.contains('show')   || _parseSeries(name).$2 > 0) {
      return 'series';
    }
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
