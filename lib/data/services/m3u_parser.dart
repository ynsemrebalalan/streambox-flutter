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

  static (String, int, int) _parseSeries(String name) {
    // S01E01 pattern
    final r = RegExp(r'[Ss](\d{1,2})[Ee](\d{1,3})');
    final m = r.firstMatch(name);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '0') ?? 0;
      final e = int.tryParse(m.group(2) ?? '0') ?? 0;
      final clean = name.replaceAll(r, '').trim();
      return (clean, s, e);
    }
    return (name, 0, 0);
  }
}

/// Isolate'a gecirilen argument tasiyicisi.
class _ParseArgs {
  final PlaylistModel playlist;
  final String content;
  const _ParseArgs(this.playlist, this.content);
}
