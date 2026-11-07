import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/services/xtream_service.dart';

void main() {
  group('XtreamUrls.base — normalize (cift slash yok)', () {
    test('sondaki slash tek olur', () {
      expect(XtreamUrls.base('http://h:8080'), 'http://h:8080/');
      expect(XtreamUrls.base('http://h:8080/'), 'http://h:8080/');
      expect(XtreamUrls.base('http://h:8080///'), 'http://h:8080/');
      expect(XtreamUrls.base('  http://h:8080/  '), 'http://h:8080/');
    });
    test('kullanici player_api.php / get.php yapistirdiysa kirpilir', () {
      expect(XtreamUrls.base('http://h:8080/player_api.php'), 'http://h:8080/');
      expect(XtreamUrls.base('http://h/get.php?username=a&password=b'),
          'http://h/');
    });
    test('sema yoksa http eklenir', () {
      expect(XtreamUrls.base('h.example:8080'), 'http://h.example:8080/');
    });
  });

  group('XtreamMapper (Android XtreamLoader paritesi)', () {
    const base = 'http://h:8080/';
    test('canli URL .m3u8, kategori fallback "Canli"', () {
      final r = XtreamMapper.live(
        {'stream_id': 12, 'name': 'TRT 1', 'stream_icon': 'i',
          'category_id': '9', 'epg_channel_id': 'trt1.tr'},
        const {},
        base: base, user: 'u', pass: 'p', playlistId: 'pl', sortOrder: 3,
      )!;
      expect(r['streamUrl'], 'http://h:8080/live/u/p/12.m3u8');
      expect(r['category'], 'Canli');
      expect(r['streamType'], 'live');
      expect(r['sortOrder'], 3);
      expect(r['tvgId'], 'trt1.tr');
    });
    test('stream_id <= 0 atlanir', () {
      expect(
          XtreamMapper.live({'stream_id': 0, 'name': 'x'}, const {},
              base: base, user: 'u', pass: 'p', playlistId: 'pl',
              sortOrder: 0),
          isNull);
    });
    test('film uzantisi saglayicidan, bossa mp4; kategori map', () {
      final r = XtreamMapper.movie(
        {'stream_id': '5', 'name': 'F', 'container_extension': ''},
        const {'1': 'Aksiyon'},
        base: base, user: 'u', pass: 'p', playlistId: 'pl', sortOrder: 0,
      )!;
      expect(r['streamUrl'], 'http://h:8080/movie/u/p/5.mp4');
      expect(r['category'], 'Film');
      final m = XtreamMapper.movie(
        {'stream_id': 6, 'name': 'G', 'container_extension': 'mkv',
          'category_id': '1'},
        const {'1': 'Aksiyon'},
        base: base, user: 'u', pass: 'p', playlistId: 'pl', sortOrder: 0,
      )!;
      expect(m['streamUrl'], 'http://h:8080/movie/u/p/6.mkv');
      expect(m['category'], 'Aksiyon');
    });
    test('dizi container: get_series_info URL, sezon/bolum 0', () {
      final r = XtreamMapper.seriesContainer(
        {'series_id': 77, 'name': 'Yargi', 'cover': 'c'},
        const {},
        base: base, user: 'u', pass: 'p', playlistId: 'pl', sortOrder: 0,
      )!;
      expect(r['streamUrl'],
          'http://h:8080/player_api.php?username=u&password=p&action=get_series_info&series_id=77');
      expect(r['seriesName'], 'Yargi');
      expect(r['seasonNumber'], 0);
      expect(r['episodeNumber'], 0);
      expect(r['category'], 'Dizi');
      final ch = ChannelModel.fromMap(r);
      expect(ch.isSeriesContainer, isTrue);
    });
  });

  group('XtreamMapper.episodes (lazy get_series_info)', () {
    const container = ChannelModel(
      id: 'cid', playlistId: 'pl', name: 'Yargi',
      streamUrl: 'http://h/player_api.php?username=u&password=p&action=get_series_info&series_id=77',
      logoUrl: 'cover', category: 'Dizi', streamType: 'series',
      seriesName: 'Yargi', sortOrder: 5000,
    );
    test('sezon anahtari, bolum no, uzanti fallback mp4, sira', () {
      final eps = XtreamMapper.episodes(
        {
          'episodes': {
            '1': [
              {'id': '101', 'title': 'Bolum A', 'episode_num': 1},
              {'id': '102', 'title': 'Yargi S01E02', 'episode_num': '2',
                'container_extension': 'mkv'},
            ],
            '0': [
              {'id': '999', 'title': 'Ozel', 'episode_num': 1},
            ],
          },
        },
        container,
        base: 'http://h/', user: 'u', pass: 'p',
      );
      expect(eps.map((e) => e.streamUrl), [
        'http://h/series/u/p/101.mp4',
        'http://h/series/u/p/102.mkv',
      ]);
      expect(eps.map((e) => e.seasonNumber), [1, 1]);
      expect(eps.map((e) => e.episodeNumber), [1, 2]);
      expect(eps.first.seriesName, 'Yargi');
      expect(eps.first.logoUrl, 'cover');
      expect(eps.first.sortOrder, 5000);
      expect(eps.last.sortOrder, 5001);
      expect(eps.first.isSeriesContainer, isFalse);
      // Deterministik id — yeniden cekmede kullanici verisi korunur.
      expect(eps.first.id, XtreamMapper.episodeId('pl', '101'));
    });
    test('episodes liste formatinda da gelebilir', () {
      final eps = XtreamMapper.episodes(
        {
          'episodes': [
            [
              {'id': '1', 'title': 'x', 'season': 2, 'episode_num': 3},
            ],
          ],
        },
        container,
        base: 'http://h/', user: 'u', pass: 'p',
      );
      expect(eps.single.seasonNumber, 2);
    });
  });

  group('xtreamAccountProblem', () {
    final now = DateTime.utc(2026, 11, 3).millisecondsSinceEpoch;
    test('auth 0 → badLogin', () {
      expect(xtreamAccountProblem({'auth': 0}, nowMs: now)?.kind,
          XtreamAccountProblemKind.badLogin);
    });
    test('Expired + gecmis tarih', () {
      final p = xtreamAccountProblem(
          {'auth': 1, 'status': 'Expired', 'exp_date': '1735689600'},
          nowMs: now)!;
      expect(p.kind, XtreamAccountProblemKind.expired);
      expect(p.expiredOn, isNotNull);
    });
    test('Disabled / Banned', () {
      expect(xtreamAccountProblem({'status': 'Banned'}, nowMs: now)?.kind,
          XtreamAccountProblemKind.disabled);
    });
    test('Active + gecmis tarih ENGELLENMEZ', () {
      expect(
          xtreamAccountProblem(
              {'auth': 1, 'status': 'Active', 'exp_date': '1'}, nowMs: now),
          isNull);
      expect(xtreamAccountProblem(null, nowMs: now), isNull);
    });
  });
}
