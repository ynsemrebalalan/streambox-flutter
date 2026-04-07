import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/utils/http_client.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';

/// Xtream Codes API client.
/// Fetches live streams, VOD, and series from an Xtream-compatible IPTV panel.
class XtreamService {
  static const _uuid = Uuid();

  /// Paralel series_info fetch'te aynı anda atılacak istek sayısı.
  /// 6 = nazik yük (provider'ı kızdırmaz), hızlı (50 dizi ~5sn yerine ~1sn).
  static const _seriesConcurrency = 6;

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

    // Her diziyi paralel fetch et (en fazla _seriesConcurrency eszamanli).
    // Bir dizi fail olursa diger dizileri etkilemez, skip edilir.
    final channels = <ChannelModel>[];
    int sort = 0;

    for (var i = 0; i < series.length; i += _seriesConcurrency) {
      final batch = series.skip(i).take(_seriesConcurrency).toList();
      final results = await Future.wait(
        batch.map((s) => _fetchOneSeries(p, s, catMap)),
        eagerError: false,
      );
      for (final list in results) {
        for (final ch in list) {
          // sortOrder'i konsolide et
          channels.add(ch.copyWith(sortOrder: sort++));
        }
      }
    }
    return channels;
  }

  /// Tek bir dizinin tüm bölümlerini getirir. Fail olursa bos liste döner.
  static Future<List<ChannelModel>> _fetchOneSeries(
    PlaylistModel p,
    dynamic s,
    Map<String, String> catMap,
  ) async {
    final seriesId = s['series_id']?.toString() ?? '';
    final name     = s['name']?.toString() ?? '';
    final cat      = catMap[s['category_id']?.toString() ?? ''] ?? 'Genel';
    final logo     = s['cover']?.toString() ?? '';
    if (seriesId.isEmpty) return const [];

    try {
      final info = await _fetchMap(
          '${_base(p)}&action=get_series_info&series_id=$seriesId');
      final episodes = info['episodes'] as Map<String, dynamic>? ?? {};
      final out = <ChannelModel>[];

      for (final seasonEntry in episodes.entries) {
        final seasonNum = int.tryParse(seasonEntry.key) ?? 0;
        final eps = (seasonEntry.value as List).cast<Map<String, dynamic>>();

        for (final ep in eps) {
          final epId   = ep['id']?.toString() ?? '';
          final epNum  = int.tryParse(ep['episode_num']?.toString() ?? '0') ?? 0;
          final epName = ep['title']?.toString() ?? 'Bölüm $epNum';
          final ext    = ep['container_extension']?.toString() ?? 'mkv';
          final url    = '${p.url}/series/${p.username}/${p.password}/$epId.$ext';

          out.add(ChannelModel(
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
            sortOrder:     0, // caller overrides
          ));
        }
      }
      return out;
    } catch (_) {
      // Tek bir dizinin hatasi diger dizileri etkilemesin.
      return const [];
    }
  }

  static Future<List<ChannelModel>> fetchAll(PlaylistModel p) async {
    final allowed = p.allowedTypes.split(',');
    // 3 endpoint paralel: live + movie + series ayni anda cekilir.
    // Provider'a 3 eszamanli istek yerine seri bekleme (3x hizlanma).
    final futures = <Future<List<ChannelModel>>>[];
    if (allowed.contains('live'))   futures.add(fetchLive(p));
    if (allowed.contains('movie'))  futures.add(fetchVod(p));
    if (allowed.contains('series')) futures.add(fetchSeries(p));
    final lists = await Future.wait(futures, eagerError: false);
    return lists.expand((l) => l).toList(growable: false);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> _fetchJson(String url) async {
    final resp = await AppHttp.get(
      Uri.parse(url),
      timeout: const Duration(seconds: 20),
      retries: 3,
    );
    if (resp.statusCode != 200) {
      throw HttpStatusException(resp.statusCode, url);
    }
    final body = jsonDecode(resp.body);
    if (body is List) return body;
    return [];
  }

  static Future<Map<String, dynamic>> _fetchMap(String url) async {
    final resp = await AppHttp.get(
      Uri.parse(url),
      timeout: const Duration(seconds: 15),
      retries: 2,
    );
    if (resp.statusCode != 200) {
      throw HttpStatusException(resp.statusCode, url);
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
