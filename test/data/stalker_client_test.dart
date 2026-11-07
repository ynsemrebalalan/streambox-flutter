import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/playlist_model.dart';
import 'package:iptv_ai_player/data/services/stalker/stalker_client.dart';
import 'package:iptv_ai_player/data/services/stalker/stalker_loader.dart';
import 'package:iptv_ai_player/data/services/stalker/stalker_stream_resolver.dart';

const _mac = '00:1A:79:12:34:56';

/// Sahte Stalker/MAG portali (yerel HttpServer) — davranis bayraklari ile.
class _FakePortal {
  late HttpServer server;
  String get root => 'http://127.0.0.1:${server.port}';

  /// API yolu ('/portal.php' veya '/stalker_portal/server/load.php').
  String apiPath = '/portal.php';
  int totalChannels = 30;
  int perPage = 14;
  bool giveToken = true;
  bool exportM3u = false;
  bool allChannelsEmpty = false;
  bool ignorePaging = false;
  bool createLinkAlwaysEmpty = false;

  int handshakes = 0;
  int profiles = 0;
  int createLinks = 0;
  String currentToken = '';
  final actions = <String>[];
  final cookies = <String>[];

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  Future<void> stop() => server.close(force: true);

  void _json(HttpRequest req, Object body, {int status = 200}) {
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(body));
    req.response.close();
  }

  bool _authed(HttpRequest req) =>
      req.headers.value('authorization') == 'Bearer $currentToken';

  Future<void> _handle(HttpRequest req) async {
    final q = req.uri.queryParameters;
    final action = q['action'] ?? '';
    cookies.add(req.headers.value('cookie') ?? '');
    if (req.uri.path == '/get.php') {
      req.response.statusCode = 404;
      await req.response.close();
      return;
    }
    if (req.uri.path != apiPath) {
      req.response.statusCode = 404;
      await req.response.close();
      return;
    }
    actions.add(action);
    switch (action) {
      case 'export_itv_list':
        if (!exportM3u) {
          // Gercek portallar desteklemiyorsa genelde JSON/HTML doner.
          req.response.write('{"js":[]}');
          await req.response.close();
          return;
        }
        req.response.write(
          '#EXTM3U\n'
          '#EXTINF:-1 tvg-id="a" group-title="Spor",Kanal A\n'
          'http://stream.tv/a.m3u8\n'
          '#EXTINF:-1 group-title="Haber",Kanal B\n'
          'http://stream.tv/b.m3u8\n',
        );
        await req.response.close();
        return;
      case 'handshake':
        handshakes++;
        if (!giveToken) return _json(req, {'js': {}});
        currentToken = 'TOKEN$handshakes';
        return _json(req, {
          'js': {'token': currentToken},
        });
      case 'get_profile':
        profiles++;
        if (!_authed(req)) return _json(req, {}, status: 401);
        return _json(req, {
          'js': {'id': 1, 'status': 0},
        });
      case 'get_genres':
        return _json(req, {
          'js': [
            {'id': '*', 'title': 'All'},
            {'id': '1', 'title': 'Spor'},
            {'id': '2', 'title': 'Haber'},
          ],
        });
      case 'get_all_channels':
      case 'get_ordered_list':
        if (!_authed(req)) return _json(req, {}, status: 401);
        if (action == 'get_all_channels' && allChannelsEmpty) {
          return _json(req, {
            'js': {'total_items': 0, 'max_page_items': 14, 'data': []},
          });
        }
        final page = ignorePaging ? 1 : int.parse(q['p'] ?? '1');
        final start = (page - 1) * perPage;
        final data = [
          for (var i = start; i < start + perPage && i < totalChannels; i++)
            {
              'id': '$i',
              'name': 'Ch $i',
              'cmd': 'ffrt http://localhost/ch/${i}_',
              'tv_genre_id': i.isEven ? '1' : '2',
            },
        ];
        return _json(req, {
          'js': {
            'total_items': totalChannels,
            'max_page_items': perPage,
            'data': data,
          },
        });
      case 'create_link':
        createLinks++;
        if (!_authed(req)) return _json(req, {}, status: 401);
        if (createLinkAlwaysEmpty) {
          return _json(req, {
            'js': {'cmd': ''},
          });
        }
        final cmd = q['cmd'] ?? '';
        final id = RegExp(r'/ch/(\d+)').firstMatch(cmd)?.group(1) ?? 'x';
        return _json(req, {
          'js': {'cmd': 'ffmpeg http://stream.tv/live/$id.ts?play_token=pt'},
        });
    }
    _json(req, {}, status: 400);
  }
}

PlaylistModel _pl(String url, {String mac = _mac, String id = 'pl'}) =>
    PlaylistModel(id: id, name: 'S', type: 'stalker', url: url, username: mac);

void main() {
  late _FakePortal portal;

  setUp(() async {
    StalkerStreamResolver.clearCache();
    portal = _FakePortal();
    await portal.start();
  });
  tearDown(() => portal.stop());

  group('StalkerClient', () {
    test('connect: handshake + get_profile, MAG cookie gonderilir', () async {
      final c = StalkerClient(portalUrl: portal.root, mac: _mac, lang: 'tr');
      final s = await c.connect();
      expect(s.token, 'TOKEN1');
      expect(s.endpoint.api, '${portal.root}/portal.php');
      expect(portal.profiles, 1);
      expect(
        portal.cookies.first,
        'mac=$_mac; stb_lang=tr; timezone=Europe/Istanbul',
      );
    });

    test('portal.php yoksa stalker_portal/server/load.php denenir', () async {
      portal.apiPath = '/stalker_portal/server/load.php';
      final c = StalkerClient(portalUrl: '${portal.root}/c/', mac: _mac);
      final s = await c.connect();
      expect(s.endpoint.api, '${portal.root}/stalker_portal/server/load.php');
    });

    test('token yok → StalkerConnectException(network: false)', () async {
      portal.giveToken = false;
      final c = StalkerClient(portalUrl: portal.root, mac: _mac);
      await expectLater(
        c.connect(),
        throwsA(
          isA<StalkerConnectException>().having(
            (e) => e.network,
            'network',
            isFalse,
          ),
        ),
      );
    });

    test('sunucu kapali → StalkerConnectException(network: true)', () async {
      final dead = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = dead.port;
      await dead.close(force: true);
      final c = StalkerClient(portalUrl: 'http://127.0.0.1:$port', mac: _mac);
      await expectLater(
        c.connect(),
        throwsA(
          isA<StalkerConnectException>().having(
            (e) => e.network,
            'network',
            isTrue,
          ),
        ),
      );
    });

    test(
      'get_all_channels sayfalama: 30 kanal / 14 → 3 sayfa, genre map',
      () async {
        final c = StalkerClient(portalUrl: portal.root, mac: _mac);
        final s = await c.connect();
        final rows = <Map<String, Object?>>[];
        final n = await c.loadLiveChannels(
          s,
          playlistId: 'pl',
          onBatch: (b) async => rows.addAll(b),
        );
        expect(n, 30);
        expect(rows, hasLength(30));
        expect(portal.actions.where((a) => a == 'get_all_channels').length, 3);
        expect(rows.first['category'], 'Spor');
        expect(rows[1]['category'], 'Haber');
        expect(rows.first['streamUrl'], 'ffrt http://localhost/ch/0_');
        expect([
          for (final r in rows) r['sortOrder'],
        ], List.generate(30, (i) => i));
      },
    );

    test(
      'portal sayfalamayi yok sayarsa sonsuz donmez, tekrar yazilmaz',
      () async {
        portal.ignorePaging = true;
        final c = StalkerClient(portalUrl: portal.root, mac: _mac);
        final s = await c.connect();
        final rows = <Map<String, Object?>>[];
        final n = await c.loadLiveChannels(
          s,
          playlistId: 'pl',
          onBatch: (b) async => rows.addAll(b),
        );
        expect(n, 14);
        expect(portal.actions.where((a) => a == 'get_all_channels').length, 2);
      },
    );

    test('get_all_channels bos → get_ordered_list yedegi', () async {
      portal.allChannelsEmpty = true;
      final c = StalkerClient(portalUrl: portal.root, mac: _mac);
      final s = await c.connect();
      final n = await c.loadLiveChannels(
        s,
        playlistId: 'pl',
        onBatch: (_) async {},
      );
      expect(n, 30);
      expect(portal.actions, contains('get_ordered_list'));
    });

    test('createLink: gecerli token → temiz URL; 401 → null', () async {
      final c = StalkerClient(portalUrl: portal.root, mac: _mac);
      final s = await c.connect();
      expect(
        await c.createLink(s, 'ffrt http://localhost/ch/7_'),
        'http://stream.tv/live/7.ts?play_token=pt',
      );
      final stale = StalkerSession(s.endpoint, 'OLD');
      expect(await c.createLink(stale, 'ffrt http://localhost/ch/7_'), isNull);
    });
  });

  group('StalkerLoader (hibrit)', () {
    test('M3U export hizli yolu: kanallar dogrudan URL ile', () async {
      portal.exportM3u = true;
      final rows = <Map<String, Object?>>[];
      final out = await StalkerLoader.load(
        _pl(portal.root),
        onBatch: (b) async => rows.addAll(b),
      );
      expect(out.viaExport, isTrue);
      expect(out.count, 2);
      expect(rows.first['streamUrl'], 'http://stream.tv/a.m3u8');
      expect(portal.handshakes, 0);
      // Export istegi de MAG cookie'si tasir.
      expect(portal.cookies.first, startsWith('mac=$_mac'));
    });

    test('export yok → tam protokol (onProtocolStart cagrilir)', () async {
      var protocolStarted = 0;
      final phases = <StalkerPhase>[];
      final rows = <Map<String, Object?>>[];
      final out = await StalkerLoader.load(
        _pl(portal.root),
        onBatch: (b) async => rows.addAll(b),
        onPhase: phases.add,
        onProtocolStart: () => protocolStarted++,
      );
      expect(out.viaExport, isFalse);
      expect(out.count, 30);
      expect(rows, hasLength(30));
      expect(protocolStarted, 1);
      expect(
        phases,
        containsAllInOrder([
          StalkerPhase.tryingExport,
          StalkerPhase.connecting,
          StalkerPhase.fetching,
        ]),
      );
    });

    test(
      'kisa export (onceki listenin yarisindan az) → protokole duser',
      () async {
        portal.exportM3u = true;
        final out = await StalkerLoader.load(
          _pl(portal.root),
          onBatch: (_) async {},
          previousCount: 100,
        );
        expect(out.viaExport, isFalse);
        expect(out.count, 30);
      },
    );

    test('gecersiz MAC → StalkerMacException, ag istegi yok', () async {
      await expectLater(
        StalkerLoader.load(
          _pl(portal.root, mac: '12:34'),
          onBatch: (_) async {},
        ),
        throwsA(isA<StalkerMacException>()),
      );
      expect(portal.actions, isEmpty);
    });

    test('token yok → StalkerConnectException', () async {
      portal.giveToken = false;
      await expectLater(
        StalkerLoader.load(_pl(portal.root), onBatch: (_) async {}),
        throwsA(isA<StalkerConnectException>()),
      );
    });
  });

  group('StalkerStreamResolver (create_link, token yenileme)', () {
    test(
      'stalker disi playlist / dogrudan URL → aynen, ag istegi yok',
      () async {
        const m3u = PlaylistModel(id: 'x', name: 'n', type: 'm3u', url: 'u');
        expect(
          await StalkerStreamResolver.resolve(m3u, 'ffrt http://localhost/1'),
          'ffrt http://localhost/1',
        );
        expect(
          await StalkerStreamResolver.resolve(
            _pl(portal.root),
            'http://stream.tv/a.m3u8',
          ),
          'http://stream.tv/a.m3u8',
        );
        expect(portal.actions, isEmpty);
      },
    );

    test(
      'ilk cozum handshake yapar, sonraki token onbellegini kullanir',
      () async {
        final p = _pl(portal.root);
        expect(
          await StalkerStreamResolver.resolve(p, 'ffrt http://localhost/ch/5_'),
          'http://stream.tv/live/5.ts?play_token=pt',
        );
        expect(portal.handshakes, 1);
        expect(
          await StalkerStreamResolver.resolve(p, 'ffrt http://localhost/ch/6_'),
          'http://stream.tv/live/6.ts?play_token=pt',
        );
        expect(portal.handshakes, 1);
      },
    );

    test('suresi dolmus token (401) → yeniden handshake + tekrar', () async {
      // Android bulut kaydi: token password alaninda.
      final p = _pl(portal.root).copyWith(password: 'EXPIRED');
      final url = await StalkerStreamResolver.resolve(
        p,
        'ffrt http://localhost/ch/9_',
      );
      expect(url, 'http://stream.tv/live/9.ts?play_token=pt');
      expect(portal.createLinks, 2);
      expect(portal.handshakes, 1);
    });

    test('sync oturumu onbellege alinir (handshake tekrarlanmaz)', () async {
      final p = _pl(portal.root);
      final c = StalkerClient(portalUrl: p.url, mac: _mac);
      StalkerStreamResolver.remember(p, await c.connect());
      await StalkerStreamResolver.resolve(p, 'ffrt http://localhost/ch/1_');
      expect(portal.handshakes, 1);
    });

    test('create_link hep bos → null (oynatici hata gosterir)', () async {
      portal.createLinkAlwaysEmpty = true;
      expect(
        await StalkerStreamResolver.resolve(
          _pl(portal.root),
          'ffrt http://localhost/ch/1_',
        ),
        isNull,
      );
    });
  });
}
