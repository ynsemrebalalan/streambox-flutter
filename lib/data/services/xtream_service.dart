import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';

/// Xtream Codes API client.
/// Fetches live streams, VOD, and series from an Xtream-compatible IPTV panel.
class XtreamService {
  static const _uuid = Uuid();

  static String _base(PlaylistModel p) {
    final url = p.url.endsWith('/') ? p.url : '${p.url}/';
    return '${url}player_api.php?username=${Uri.encodeComponent(p.username)}'
        '&password=${Uri.encodeComponent(p.password)}';
  }

  static Future<List<ChannelModel>> fetchLive(PlaylistModel p) async {
    final cats    = await _fetchJson('${_base(p)}&action=get_live_categories');
    final catMap  = _buildCatMap(cats);
    final streams = await _fetchJson('${_base(p)}&action=get_live_streams');
    return _mapStreams(streams, catMap, p, 'live');
  }

  static Future<List<ChannelModel>> fetchVod(PlaylistModel p) async {
    final cats    = await _fetchJson('${_base(p)}&action=get_vod_categories');
    final catMap  = _buildCatMap(cats);
    final streams = await _fetchJson('${_base(p)}&action=get_vod_streams');
    return _mapStreams(streams, catMap, p, 'movie');
  }

  static Future<List<ChannelModel>> fetchSeries(PlaylistModel p) async {
    final cats    = await _fetchJson('${_base(p)}&action=get_series_categories');
    final catMap  = _buildCatMap(cats);
    final series  = await _fetchJson('${_base(p)}&action=get_series');
    final channels= <ChannelModel>[];
    int sort = 0;

    for (final s in series) {
      final seriesId  = s['series_id']?.toString() ?? '';
      final name      = s['name']?.toString() ?? '';
      final cat       = catMap[s['category_id']?.toString() ?? ''] ?? 'Genel';
      final logo      = s['cover']?.toString() ?? '';

      // Fetch episodes for each series
      try {
        final info = await _fetchMap(
            '${_base(p)}&action=get_series_info&series_id=$seriesId');
        final episodes = info['episodes'] as Map<String, dynamic>? ?? {};

        for (final seasonEntry in episodes.entries) {
          final seasonNum = int.tryParse(seasonEntry.key) ?? 0;
          final eps = (seasonEntry.value as List).cast<Map<String, dynamic>>();

          for (final ep in eps) {
            final epId   = ep['id']?.toString() ?? '';
            final epNum  = int.tryParse(ep['episode_num']?.toString() ?? '0') ?? 0;
            final epName = ep['title']?.toString() ?? 'Bölüm $epNum';
            final ext    = ep['container_extension']?.toString() ?? 'mkv';
            final url    = '${p.url}/series/${p.username}/${p.password}/$epId.$ext';

            channels.add(ChannelModel(
              id:            _uuid.v5(Namespace.url.value, '${p.id}:series:$epId'),
              playlistId:    p.id,
              name:          '$name S${seasonNum.toString().padLeft(2, '0')}E${epNum.toString().padLeft(2, '0')} - $epName',
              streamUrl:     url,
              logoUrl:       logo,
              category:      cat,
              streamType:    'series',
              seriesName:    name,
              seasonNumber:  seasonNum,
              episodeNumber: epNum,
              sortOrder:     sort++,
            ));
          }
        }
      } catch (_) {
        // Skip series that fail to load
      }
    }
    return channels;
  }

  static Future<List<ChannelModel>> fetchAll(PlaylistModel p) async {
    final allowed = p.allowedTypes.split(',');
    final results = <ChannelModel>[];
    if (allowed.contains('live'))   results.addAll(await fetchLive(p));
    if (allowed.contains('movie'))  results.addAll(await fetchVod(p));
    if (allowed.contains('series')) results.addAll(await fetchSeries(p));
    return results;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> _fetchJson(String url) async {
    final resp = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: $url');
    }
    final body = jsonDecode(resp.body);
    if (body is List) return body;
    return [];
  }

  static Future<Map<String, dynamic>> _fetchMap(String url) async {
    final resp = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: $url');
    }
    final body = jsonDecode(resp.body);
    if (body is Map<String, dynamic>) return body;
    return {};
  }

  static Map<String, String> _buildCatMap(List<dynamic> cats) {
    return {
      for (final c in cats)
        (c['category_id']?.toString() ?? ''): (c['category_name']?.toString() ?? 'Genel'),
    };
  }

  static List<ChannelModel> _mapStreams(
    List<dynamic>          streams,
    Map<String, String>    catMap,
    PlaylistModel          p,
    String                 type,
  ) {
    int sort = 0;
    return streams.map((s) {
      final id   = s['stream_id']?.toString() ?? '';
      final ext  = s['container_extension']?.toString() ?? 'ts';
      final url  = type == 'live'
          ? '${p.url}/live/${p.username}/${p.password}/$id.ts'
          : '${p.url}/movie/${p.username}/${p.password}/$id.$ext';
      final cat  = catMap[s['category_id']?.toString() ?? ''] ?? 'Genel';
      return ChannelModel(
        id:         _uuid.v5(Namespace.url.value, '${p.id}:$type:$id'),
        playlistId: p.id,
        name:       s['name']?.toString() ?? '',
        streamUrl:  url,
        logoUrl:    s['stream_icon']?.toString() ?? '',
        category:   cat,
        streamType: type,
        sortOrder:  sort++,
      );
    }).toList();
  }
}
