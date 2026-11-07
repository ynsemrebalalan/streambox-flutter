import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/playlist_model.dart';
import 'package:iptv_ai_player/data/services/m3u_parser.dart';
import 'package:iptv_ai_player/data/services/m3u_stream_loader.dart';

const _body = '#EXTM3U url-tvg="http://epg.example/guide.xml.gz,http://b/x.xml"\n'
    '#EXTINF:-1 tvg-id="trt1" group-title="Ulusal",TRT 1\n'
    'http://h/live/u/p/1.ts\n'
    '#EXTINF:-1 group-title="Filmler",Film A (2020)\n'
    'http://h/movie/u/p/2.mp4\n'
    '#EXTINF:-1 group-title="Dizi",Yargı S01E02\n'
    'http://h/series/u/p/3.mkv\n';

void main() {
  group('M3uLineParser', () {
    test('header url-tvg ilk URL olarak okunur', () {
      final p = M3uLineParser(playlistId: 'pl', allowedTypes: const {
        'live', 'movie', 'series',
      });
      for (final l in const LineSplitter().convert(_body)) {
        p.addLine(l);
      }
      expect(p.epgUrl, 'http://epg.example/guide.xml.gz');
    });

    test('x-tvg-url da desteklenir', () {
      final p = M3uLineParser(playlistId: 'pl', allowedTypes: const {'live'});
      p.addLine('#EXTM3U x-tvg-url="http://e/x.xml"');
      expect(p.epgUrl, 'http://e/x.xml');
    });

    test('allowedTypes filtresi ve sortOrder', () {
      final p = M3uLineParser(
          playlistId: 'pl', allowedTypes: const {'live', 'series'});
      final out = [
        for (final l in const LineSplitter().convert(_body)) p.addLine(l),
      ].whereType<Object>().toList();
      expect(out, hasLength(2));
    });

    test('M3uParser.parse ayni sonucu verir (geriye uyum)', () {
      const pl = PlaylistModel(
          id: 'pl', name: 'n', type: 'm3u', url: 'u', allowedTypes: 'movie');
      final list = M3uParser.parse(pl, _body);
      expect(list.map((c) => c.name), ['Film A (2020)']);
    });
  });

  group('parseM3uExpiry (Android EditPlaylistScreen paritesi)', () {
    test('exp saniye → ms', () {
      expect(parseM3uExpiry('http://h/get.php?u=a&exp=1735689600'),
          1735689600000);
    });
    test('expiryDate / expires ve ms degeri', () {
      expect(parseM3uExpiry('http://h/x?expiryDate=1735689600'),
          1735689600000);
      expect(parseM3uExpiry('http://h/x?expires=1735689600000'),
          1735689600000);
    });
    test('param yoksa / gecersizse null', () {
      expect(parseM3uExpiry('http://h/x.m3u'), isNull);
      expect(parseM3uExpiry('http://h/x?exp=abc'), isNull);
      expect(parseM3uExpiry(''), isNull);
    });
  });

  group('M3uStreamLoader (isolate + akisli indirme)', () {
    late HttpServer server;
    late String base;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = 'http://127.0.0.1:${server.port}';
      server.listen((req) async {
        final path = req.uri.path;
        if (path == '/etag.m3u' &&
            req.headers.value('if-none-match') == '"v1"') {
          req.response.statusCode = 304;
          await req.response.close();
          return;
        }
        if (path == '/missing.m3u') {
          req.response.statusCode = 404;
          await req.response.close();
          return;
        }
        if (path == '/big.m3u') {
          final sb = StringBuffer('#EXTM3U\n');
          for (var i = 0; i < 5000; i++) {
            sb
              ..writeln('#EXTINF:-1 group-title="G${i % 7}",Kanal $i')
              ..writeln('http://h/live/u/p/$i.ts');
          }
          req.response.headers.set('ETag', '"big"');
          req.response.write(sb.toString());
          await req.response.close();
          return;
        }
        final bytes = utf8.encode(_body);
        if (path == '/list.m3u.gz') {
          req.response.add(gzip.encode(bytes));
        } else {
          req.response.headers.set('ETag', '"v1"');
          req.response.add(bytes);
        }
        await req.response.close();
      });
    });

    tearDown(() => server.close(force: true));

    PlaylistModel pl(String path, {String etag = ''}) => PlaylistModel(
        id: 'pl', name: 'n', type: 'm3u', url: '$base$path', etag: etag);

    test('batch batch gonderir, header EPG ve ETag yakalanir', () async {
      final rows = <Map<String, Object?>>[];
      final out = await M3uStreamLoader.load(
        playlist: pl('/list.m3u'),
        onBatch: (b) async => rows.addAll(b),
      );
      expect(out.notModified, isFalse);
      expect(out.count, 3);
      expect(rows, hasLength(3));
      expect(out.etag, '"v1"');
      expect(out.epgUrl, 'http://epg.example/guide.xml.gz');
      expect(rows.first['name'], 'TRT 1');
      expect(rows.first['searchKey'], isNotEmpty);
      expect(rows.first[M3uStreamLoader.categoriesKey], ['Ulusal']);
    });

    test('.m3u.gz acilir', () async {
      final rows = <Map<String, Object?>>[];
      final out = await M3uStreamLoader.load(
        playlist: pl('/list.m3u.gz'),
        onBatch: (b) async => rows.addAll(b),
      );
      expect(out.count, 3);
    });

    test('304 Not Modified → notModified, batch yok', () async {
      var batches = 0;
      final out = await M3uStreamLoader.load(
        playlist: pl('/etag.m3u', etag: '"v1"'),
        onBatch: (_) async => batches++,
      );
      expect(out.notModified, isTrue);
      expect(batches, 0);
    });

    test('HTTP hata → M3uLoadException(status)', () async {
      expect(
        () => M3uStreamLoader.load(
            playlist: pl('/missing.m3u'), onBatch: (_) async {}),
        throwsA(isA<M3uLoadException>()
            .having((e) => e.statusCode, 'status', 404)),
      );
    });

    test('buyuk liste: ilk batch kucuk, toplam dogru, sira korunur', () async {
      final sizes = <int>[];
      var last = -1;
      var ordered = true;
      final out = await M3uStreamLoader.load(
        playlist: pl('/big.m3u'),
        batchSize: 1000,
        onBatch: (b) async {
          sizes.add(b.length);
          for (final r in b) {
            final so = r['sortOrder'] as int;
            if (so <= last) ordered = false;
            last = so;
          }
        },
      );
      expect(out.count, 5000);
      expect(sizes.first, M3uStreamLoader.firstBatchSize);
      expect(sizes.fold<int>(0, (a, b) => a + b), 5000);
      expect(ordered, isTrue);
    });
  });
}
