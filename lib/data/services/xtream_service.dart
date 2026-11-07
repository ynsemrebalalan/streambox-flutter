import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/device_tier.dart';
import '../../core/utils/http_client.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';
import '../repositories/channel_repository.dart';
import 'isolate_batch_pump.dart';
import 'm3u_parser.dart';
import 'sync_cancel.dart';
import 'sync_shrink_gate.dart';

/// Xtream adres yardımcıları — Android XtreamLoader ile aynı URL biçimi.
class XtreamUrls {
  XtreamUrls._();

  /// Sunucu adresini `scheme://host[:port]/` biçimine indirger: tek sondaki
  /// slash, kullanıcının yapıştırdığı `player_api.php` / `get.php` kırpılır,
  /// şema yoksa http eklenir. Stream URL'lerinde çift slash oluşmaz.
  static String base(String host) {
    var h = host.trim();
    if (h.isEmpty) return h;
    if (!h.contains('://')) h = 'http://$h';
    final q = h.indexOf('?');
    if (q >= 0) h = h.substring(0, q);
    for (final suffix in const ['player_api.php', 'get.php', 'xmltv.php']) {
      if (h.toLowerCase().endsWith(suffix)) {
        h = h.substring(0, h.length - suffix.length);
      }
    }
    while (h.endsWith('/')) {
      h = h.substring(0, h.length - 1);
    }
    return '$h/';
  }

  static String api(String base, String user, String pass) =>
      '${base}player_api.php?username=${Uri.encodeComponent(user)}'
      '&password=${Uri.encodeComponent(pass)}';
}

/// JSON → kanal satırı dönüşümleri (saf; isolate içinde de çalışır).
class XtreamMapper {
  XtreamMapper._();
  static const _uuid = Uuid();

  static String _id(String pid, String type, String id) =>
      _uuid.v5(Namespace.url.value, '$pid:$type:$id');

  static String episodeId(String pid, String epId) =>
      _uuid.v5(Namespace.url.value, '$pid:series:$epId');

  static int _int(Object? v) =>
      v is int ? v : int.tryParse(v?.toString().trim() ?? '') ?? 0;

  static String _str(Object? v) => v?.toString() ?? '';

  /// Kategori adları: `category_ids` dizi / `category_id` (virgüllü olabilir)
  /// → catMap; bulunamazsa `category_name`, o da yoksa [fallback]
  /// (Android: "Canli" / "Film" / "Dizi").
  static List<String> categories(
      Map<String, dynamic> s, Map<String, String> catMap, String fallback) {
    final ids = <String>{};
    final raw = s['category_ids'];
    if (raw is List) {
      for (final e in raw) {
        final v = _str(e).trim();
        if (v.isNotEmpty) ids.add(v);
      }
    }
    if (ids.isEmpty) {
      for (final part in _str(s['category_id']).split(',')) {
        final v = part.trim();
        if (v.isNotEmpty) ids.add(v);
      }
    }
    final names = <String>{};
    for (final id in ids) {
      final n = catMap[id];
      if (n != null && n.trim().isNotEmpty) names.add(n.trim());
    }
    if (names.isNotEmpty) return names.toList();
    final own = _str(s['category_name']).trim();
    return [own.isNotEmpty ? own : fallback];
  }

  static Map<String, Object?> _row({
    required String id,
    required String playlistId,
    required String name,
    required String url,
    required String logo,
    required List<String> cats,
    required String type,
    required int sortOrder,
    String tvgId = '',
    String seriesName = '',
  }) {
    final ch = ChannelModel(
      id: id,
      playlistId: playlistId,
      name: name,
      streamUrl: url,
      logoUrl: logo,
      category: cats.first,
      categoryIds: cats,
      streamType: type,
      sortOrder: sortOrder,
      tvgId: tvgId,
      seriesName: seriesName,
    );
    return {...ch.toMap(), '__cats': cats};
  }

  static Map<String, Object?>? live(
    Map<String, dynamic> s,
    Map<String, String> cats, {
    required String base,
    required String user,
    required String pass,
    required String playlistId,
    required int sortOrder,
  }) {
    final sid = _int(s['stream_id']);
    if (sid <= 0) return null;
    return _row(
      id: _id(playlistId, 'live', '$sid'),
      playlistId: playlistId,
      name: _str(s['name']),
      // Android: canlı yayın HLS (.m3u8).
      url: '${base}live/$user/$pass/$sid.m3u8',
      logo: _str(s['stream_icon']),
      cats: categories(s, cats, 'Canli'),
      type: 'live',
      sortOrder: sortOrder,
      tvgId: _str(s['epg_channel_id']).trim(),
    );
  }

  static Map<String, Object?>? movie(
    Map<String, dynamic> s,
    Map<String, String> cats, {
    required String base,
    required String user,
    required String pass,
    required String playlistId,
    required int sortOrder,
  }) {
    final sid = _int(s['stream_id']);
    if (sid <= 0) return null;
    final ext = _str(s['container_extension']).trim();
    return _row(
      id: _id(playlistId, 'movie', '$sid'),
      playlistId: playlistId,
      name: _str(s['name']),
      url: '${base}movie/$user/$pass/$sid.${ext.isEmpty ? 'mp4' : ext}',
      logo: _str(s['stream_icon']),
      cats: categories(s, cats, 'Film'),
      type: 'movie',
      sortOrder: sortOrder,
    );
  }

  /// Dizi container satırı — bölümler açılışta lazy çekilir.
  static Map<String, Object?>? seriesContainer(
    Map<String, dynamic> s,
    Map<String, String> cats, {
    required String base,
    required String user,
    required String pass,
    required String playlistId,
    required int sortOrder,
  }) {
    final sid = _int(s['series_id']);
    if (sid <= 0) return null;
    final name = _str(s['name']);
    return _row(
      id: _id(playlistId, 'seriesc', '$sid'),
      playlistId: playlistId,
      name: name,
      url: '${base}player_api.php?username=$user&password=$pass'
          '&action=get_series_info&series_id=$sid',
      logo: _str(s['cover']),
      cats: categories(s, cats, 'Dizi'),
      type: 'series',
      sortOrder: sortOrder,
      seriesName: name,
    );
  }

  /// `series_id` — container URL'inden.
  static String? seriesIdOf(String containerUrl) =>
      RegExp(r'series_id=(\d+)').firstMatch(containerUrl)?.group(1);

  /// `get_series_info` cevabı → bölümler. Android loadSeriesEpisodes:
  /// sezon anahtarı > 0, sezon = başlıktan parse > ep.season > anahtar,
  /// bölüm = başlıktan parse > episode_num. Uzantı boşsa mp4.
  /// sortOrder container'ınkinden ardışık (dizi içi sağlayıcı sırası).
  static List<ChannelModel> episodes(
    Map<String, dynamic> info,
    ChannelModel container, {
    required String base,
    required String user,
    required String pass,
  }) {
    final raw = info['episodes'];
    final seasons = <MapEntry<int, List>>[];
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value is List) {
          seasons.add(MapEntry(_int(e.key), e.value as List));
        }
      }
    } else if (raw is List) {
      // Bazı paneller diziyi liste olarak döner — sezon ep['season']'dan.
      for (final e in raw) {
        if (e is List) seasons.add(MapEntry(-1, e));
      }
    }
    final infoCover = info['info'] is Map
        ? _str((info['info'] as Map)['cover'])
        : '';
    final out = <ChannelModel>[];
    var sort = container.sortOrder;
    for (final season in seasons) {
      if (season.key == 0) continue;
      for (final item in season.value) {
        if (item is! Map) continue;
        final ep = item.cast<String, dynamic>();
        final epId = _str(ep['id']).trim();
        if (epId.isEmpty) continue;
        final title = _str(ep['title']);
        final (_, ps, pe) = M3uParser.parseSeriesInfo(title);
        final epSeason = _int(ep['season']);
        final finalSeason = ps > 0
            ? ps
            : epSeason > 0
                ? epSeason
                : (season.key > 0 ? season.key : 1);
        final finalEpisode = pe > 0 ? pe : _int(ep['episode_num']);
        final ext = _str(ep['container_extension']).trim();
        final epInfo = ep['info'] is Map ? ep['info'] as Map : const {};
        final cover = _str(epInfo['cover']).isNotEmpty
            ? _str(epInfo['cover'])
            : _str(epInfo['movie_image']).isNotEmpty
                ? _str(epInfo['movie_image'])
                : container.logoUrl.isNotEmpty
                    ? container.logoUrl
                    : infoCover;
        out.add(ChannelModel(
          id: episodeId(container.playlistId, epId),
          playlistId: container.playlistId,
          name: title,
          streamUrl: '${base}series/$user/$pass/$epId.${ext.isEmpty ? 'mp4' : ext}',
          logoUrl: cover,
          category: container.category,
          categoryIds: container.categoryIds,
          streamType: 'series',
          seriesName: container.seriesName.isNotEmpty
              ? container.seriesName
              : container.name,
          seasonNumber: finalSeason,
          episodeNumber: finalEpisode,
          sortOrder: sort++,
        ));
      }
    }
    return out;
  }
}

/// Xtream hesap sorunu türü.
enum XtreamAccountProblemKind { badLogin, expired, disabled }

class XtreamAccountProblem implements Exception {
  final XtreamAccountProblemKind kind;
  /// "dd.MM.yyyy" — yalnız [kind] expired ve tarih geçmişse.
  final String? expiredOn;
  const XtreamAccountProblem(this.kind, {this.expiredOn});
  @override
  String toString() => 'XtreamAccountProblem($kind, $expiredOn)';
}

/// Android `xtreamAccountProblem` paritesi: yanlış şifre (`auth: 0`),
/// süresi dolmuş (`status: Expired`), kapatılmış (`Disabled`/`Banned`).
/// Tarihi geçmiş ama "Active" hesap ENGELLENMEZ (paneller tarihi yanlış
/// gönderebiliyor).
XtreamAccountProblem? xtreamAccountProblem(Map<String, dynamic>? info,
    {int? nowMs}) {
  if (info == null) return null;
  if (info['auth']?.toString().trim() == '0') {
    return const XtreamAccountProblem(XtreamAccountProblemKind.badLogin);
  }
  switch (info['status']?.toString().trim().toLowerCase()) {
    case 'expired':
      final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
      final sec = int.tryParse(info['exp_date']?.toString().trim() ?? '');
      String? date;
      if (sec != null && sec > 0 && sec * 1000 <= now) {
        final d = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        date = '${d.day.toString().padLeft(2, '0')}.'
            '${d.month.toString().padLeft(2, '0')}.${d.year}';
      }
      return XtreamAccountProblem(XtreamAccountProblemKind.expired,
          expiredOn: date);
    case 'disabled':
    case 'banned':
      return const XtreamAccountProblem(XtreamAccountProblemKind.disabled);
  }
  return null;
}

/// Tür bazlı yükleme sonucu.
class XtreamLoadOutcome {
  final int count;

  /// Başarıyla yüklenen türler ve yazılan satır sayıları (0 dahil).
  final Map<String, int> countsByType;

  /// Başarısız türler → hata (diğer türler yüklendiyse sync yine başarılı;
  /// HEPSİNİN eski satırları korunur).
  final Map<String, Object> errorsByType;

  const XtreamLoadOutcome(this.count,
      {this.countsByType = const {}, this.errorsByType = const {}});

  /// İlk başarısız türün hatası (live → movie → series sırası).
  Object? get firstError =>
      errorsByType.isEmpty ? null : errorsByType.values.first;
  String? get firstErrorType =>
      errorsByType.isEmpty ? null : errorsByType.keys.first;
}

/// Xtream Codes yükleyici — Android XtreamLoader paritesi:
///  1. `player_api.php` ile hesap kontrolü (net hata mesajı),
///  2. canlı → film → dizi sırasıyla, her tür kendi isolate'ında indirilip
///     batch'ler halinde yazılır; bir türün hatası diğerlerini durdurmaz,
///  3. diziler container olarak yazılır, bölümler açılışta lazy +
///     sınırlı arka plan prefetch ile çekilir.
class XtreamService {
  XtreamService._();

  /// Hesap bilgisi (`user_info`). Ağ hatası fırlatır; JSON değilse null.
  static Future<Map<String, dynamic>?> authenticate(PlaylistModel p) async {
    final url = XtreamUrls.api(XtreamUrls.base(p.url), p.username, p.password);
    final resp = await AppHttp.get(Uri.parse(url),
        timeout: const Duration(seconds: 20), retries: 2);
    if (resp.statusCode != 200) {
      throw HttpStatusException(resp.statusCode, p.url);
    }
    try {
      final body = jsonDecode(utf8.decode(resp.bodyBytes, allowMalformed: true));
      if (body is Map && body['user_info'] is Map) {
        return (body['user_info'] as Map).cast<String, dynamic>();
      }
    } catch (_) {
      // JSON değil — bazı paneller kökte boş döner; kanal adımında anlaşılır.
    }
    return null;
  }

  /// Tüm izinli türleri yükler. [onType] faz bildirimi ('live'|'movie'|'series').
  static Future<XtreamLoadOutcome> loadAll(
    PlaylistModel p, {
    required Future<void> Function(List<Map<String, Object?>> rows) onBatch,
    void Function(String type)? onType,
  }) async {
    final problem = xtreamAccountProblem(await authenticate(p));
    if (problem != null) throw problem;

    final allowed = p.allowedTypes.split(',').map((e) => e.trim()).toSet();
    final base = XtreamUrls.base(p.url);
    var sort = 0;
    var total = 0;
    final counts = <String, int>{};
    final errors = <String, Object>{};
    for (final type in const ['live', 'movie', 'series']) {
      if (!allowed.contains(type)) continue;
      onType?.call(type);
      var typeCount = 0;
      try {
        final res = await runBatchIsolate(_typeWorker, {
          'type': type,
          'base': base,
          'user': p.username,
          'pass': p.password,
          'playlistId': p.id,
          'startSort': sort,
          'lowTier': DeviceProfile.tier == DeviceTier.low,
        }, onBatch: (rows) async {
          await onBatch(rows);
          total += rows.length;
          typeCount += rows.length;
        });
        sort = res['nextSort'] as int? ?? sort;
        counts[type] = typeCount;
      } on SyncCancelledException {
        rethrow;
      } catch (e) {
        if (kDebugMode) debugPrint('[Xtream] $type failed: $e');
        errors[type] = e;
      }
    }
    return XtreamLoadOutcome(total,
        countsByType: counts, errorsByType: errors);
  }

  static Future<Map<String, Object?>> _typeWorker(
      BatchSink sink, Map<String, Object?> cfg) async {
    final type = cfg['type'] as String;
    final base = cfg['base'] as String;
    final user = cfg['user'] as String;
    final pass = cfg['pass'] as String;
    final pid = cfg['playlistId'] as String;
    var sort = cfg['startSort'] as int;
    final restSize = (cfg['lowTier'] as bool? ?? false) ? 500 : 1000;
    final api = XtreamUrls.api(base, user, pass);
    final (catAction, listAction) = switch (type) {
      'live'  => ('get_live_categories', 'get_live_streams'),
      'movie' => ('get_vod_categories', 'get_vod_streams'),
      _       => ('get_series_categories', 'get_series'),
    };
    final catMap = <String, String>{};
    try {
      final cats = await isolateGetJson('$api&action=$catAction');
      if (cats is List) {
        for (final c in cats) {
          if (c is Map) {
            catMap[c['category_id']?.toString() ?? ''] =
                c['category_name']?.toString() ?? '';
          }
        }
      }
    } catch (_) {
      // Kategori listesi olmadan da kanallar yüklenebilir (fallback adlar).
    }
    // Liste olmayan geçerli JSON ({} / null / {"user_info":{"auth":0}}) =
    // format hatası; "0 öğe" sayılırsa o türün tüm satırları silinirdi.
    final list = requireJsonList(
        await isolateGetJson('$api&action=$listAction',
            timeout: const Duration(seconds: 120)),
        listAction);

    var batch = <Map<String, Object?>>[];
    var limit = 100; // ilk parça küçük — ilk ekran erken dolsun
    var count = 0;
    for (final item in list) {
      if (item is! Map) continue;
      final s = item.cast<String, dynamic>();
      final Map<String, Object?>? row;
      switch (type) {
        case 'live':
          row = XtreamMapper.live(s, catMap,
              base: base, user: user, pass: pass, playlistId: pid,
              sortOrder: sort);
        case 'movie':
          row = XtreamMapper.movie(s, catMap,
              base: base, user: user, pass: pass, playlistId: pid,
              sortOrder: sort);
        default:
          row = XtreamMapper.seriesContainer(s, catMap,
              base: base, user: user, pass: pass, playlistId: pid,
              sortOrder: sort);
      }
      if (row == null) continue;
      // Dizi container'ları arasında boşluk: lazy bölümler container'ın
      // sortOrder'ından ardışık sıralanır, sonraki diziyle çakışmaz.
      sort += type == 'series' ? seriesSortGap : 1;
      batch.add(row);
      if (batch.length >= limit) {
        if (!await sink.emit(batch)) return {'count': count, 'nextSort': sort};
        count += batch.length;
        batch = <Map<String, Object?>>[];
        limit = restSize;
      }
    }
    if (batch.isNotEmpty) {
      await sink.emit(batch);
      count += batch.length;
    }
    return {'count': count, 'nextSort': sort};
  }

  /// Bir dizinin bölüm sıralaması için ayrılan sortOrder aralığı.
  static const seriesSortGap = 1000;

  /// Container'ın bölümlerini çeker (get_series_info). Hata fırlatır.
  static Future<List<ChannelModel>> fetchSeriesEpisodes(
      PlaylistModel p, ChannelModel container) async {
    final sid = XtreamMapper.seriesIdOf(container.streamUrl);
    if (sid == null) return const [];
    final base = XtreamUrls.base(p.url);
    final url = '${XtreamUrls.api(base, p.username, p.password)}'
        '&action=get_series_info&series_id=$sid';
    final resp = await AppHttp.get(Uri.parse(url),
        timeout: const Duration(seconds: 20), retries: 2);
    if (resp.statusCode != 200) {
      throw HttpStatusException(resp.statusCode, p.url);
    }
    final body = jsonDecode(utf8.decode(resp.bodyBytes, allowMalformed: true));
    if (body is! Map) return const [];
    return XtreamMapper.episodes(body.cast<String, dynamic>(), container,
        base: base, user: p.username, pass: p.password);
  }

  /// Container'ı açılışta bölümlerle değiştirir. Dönüş: yazılan bölüm sayısı.
  static Future<int> loadSeriesContainer(
    PlaylistModel p,
    ChannelModel container,
    ChannelRepository repo,
  ) async {
    final eps = await fetchSeriesEpisodes(p, container);
    if (eps.isEmpty) return 0;
    await repo.replaceSeriesContainer(container, eps);
    return eps.length;
  }

  static final _prefetching = <String>{};

  /// Sınırlı arka plan prefetch (Android prefetchAllSeriesEpisodes; düşük
  /// cihazda çalışmaz). İlk [limit] container, [concurrency] paralel istek.
  static Future<int> prefetchSeries(
    PlaylistModel p,
    ChannelRepository repo, {
    int limit = 150,
    int concurrency = 3,
  }) async {
    if (p.type != 'xtream' || DeviceProfile.tier == DeviceTier.low) return 0;
    if (!_prefetching.add(p.id)) return 0;
    var done = 0;
    try {
      final pending = await repo.getPendingSeriesContainers(p.id, limit: limit);
      for (var i = 0; i < pending.length; i += concurrency) {
        final slice = pending.skip(i).take(concurrency);
        final results = await Future.wait(slice.map((c) async {
          try {
            return await loadSeriesContainer(p, c, repo) > 0 ? 1 : 0;
          } catch (_) {
            return 0;
          }
        }));
        done += results.fold<int>(0, (a, b) => a + b);
      }
    } finally {
      _prefetching.remove(p.id);
    }
    return done;
  }
}
