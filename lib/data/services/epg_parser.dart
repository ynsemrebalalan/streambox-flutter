import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/epg_model.dart';

class EpgParser {
  /// Fetch and parse XMLTV from [url].
  /// Supports plain .xml and gzip-compressed .xml.gz.
  static Future<({List<EpgChannelModel> channels, List<EpgProgrammeModel> programmes})>
      fetchAndParse(String url, String playlistId) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $url');
    }

    final bytes = response.bodyBytes;
    final xmlStr = _decode(bytes, url);
    return parse(xmlStr, playlistId);
  }

  static String _decode(List<int> bytes, String url) {
    if (url.endsWith('.gz') || _isGzip(bytes)) {
      return utf8.decode(gzip.decode(bytes));
    }
    return utf8.decode(bytes);
  }

  static bool _isGzip(List<int> bytes) =>
      bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;

  static ({List<EpgChannelModel> channels, List<EpgProgrammeModel> programmes})
      parse(String xmlStr, String playlistId) {
    final doc      = XmlDocument.parse(xmlStr);
    final channels = <EpgChannelModel>[];
    final programmes= <EpgProgrammeModel>[];

    for (final ch in doc.findAllElements('channel')) {
      final id   = ch.getAttribute('id') ?? '';
      if (id.isEmpty) continue;
      final name = ch.findElements('display-name').firstOrNull?.innerText ?? id;
      final icon = ch.findElements('icon').firstOrNull?.getAttribute('src') ?? '';
      channels.add(EpgChannelModel(
        tvgId:       id,
        playlistId:  playlistId,
        displayName: name,
        icon:        icon,
      ));
    }

    for (final p in doc.findAllElements('programme')) {
      final channelId = p.getAttribute('channel') ?? '';
      final start     = _parseTime(p.getAttribute('start') ?? '');
      final stop      = _parseTime(p.getAttribute('stop') ?? '');
      if (channelId.isEmpty || start == 0 || stop == 0) continue;

      final title  = p.findElements('title').firstOrNull?.innerText ?? '';
      final desc   = p.findElements('desc').firstOrNull?.innerText ?? '';
      final cat    = p.findElements('category').firstOrNull?.innerText ?? '';
      final icon   = p.findElements('icon').firstOrNull?.getAttribute('src') ?? '';
      final id     = '${channelId}_$start';

      programmes.add(EpgProgrammeModel(
        id:          id,
        channelId:   channelId,
        title:       title,
        description: desc,
        startTime:   start,
        stopTime:    stop,
        category:    cat,
        icon:        icon,
      ));
    }

    return (channels: channels, programmes: programmes);
  }

  /// Parse XMLTV datetime: "20240101120000 +0300" → Unix millis UTC
  static int _parseTime(String s) {
    if (s.isEmpty) return 0;
    try {
      // format: YYYYMMDDHHmmss +HHMM
      final parts    = s.trim().split(' ');
      final datePart = parts[0];
      if (datePart.length < 14) return 0;

      final year   = int.parse(datePart.substring(0, 4));
      final month  = int.parse(datePart.substring(4, 6));
      final day    = int.parse(datePart.substring(6, 8));
      final hour   = int.parse(datePart.substring(8, 10));
      final minute = int.parse(datePart.substring(10, 12));
      final second = int.parse(datePart.substring(12, 14));

      int offsetMs = 0;
      if (parts.length > 1) {
        final tz  = parts[1];
        final sign= tz.startsWith('-') ? -1 : 1;
        final h   = int.tryParse(tz.substring(1, 3)) ?? 0;
        final m   = int.tryParse(tz.substring(3, 5)) ?? 0;
        offsetMs  = sign * (h * 60 + m) * 60 * 1000;
      }

      final dt = DateTime.utc(year, month, day, hour, minute, second);
      return dt.millisecondsSinceEpoch - offsetMs;
    } catch (_) {
      return 0;
    }
  }
}
