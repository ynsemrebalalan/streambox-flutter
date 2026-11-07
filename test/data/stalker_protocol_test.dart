import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/services/stalker/stalker_protocol.dart';

void main() {
  group('StalkerUrls.endpoints — portal yolu varyantlari', () {
    test('kok adres → portal.php, sonra stalker_portal/server/load.php', () {
      final e = StalkerUrls.endpoints('http://p.tv:8080');
      expect(e.map((x) => x.api), [
        'http://p.tv:8080/portal.php',
        'http://p.tv:8080/stalker_portal/server/load.php',
      ]);
      expect(e.first.base, 'http://p.tv:8080');
      expect(e.first.referer, 'http://p.tv:8080/c/');
    });
    test('sema yoksa http eklenir, bosluk / sondaki slash kirpilir', () {
      expect(
        StalkerUrls.endpoints('  p.tv:8080///  ').first.api,
        'http://p.tv:8080/portal.php',
      );
    });
    test('/c/ (MAG web arayuzu) kirpilir', () {
      expect(
        StalkerUrls.endpoints('http://p.tv:8080/c/').first.api,
        'http://p.tv:8080/portal.php',
      );
      expect(
        StalkerUrls.endpoints('http://p.tv/c').first.api,
        'http://p.tv/portal.php',
      );
      expect(
        StalkerUrls.endpoints('http://p.tv/c/index.html').first.api,
        'http://p.tv/portal.php',
      );
    });
    test('/stalker_portal/ → server/load.php once, kok portal.php yedek', () {
      final e = StalkerUrls.endpoints('http://p.tv/stalker_portal/');
      expect(e.map((x) => x.api), [
        'http://p.tv/stalker_portal/server/load.php',
        'http://p.tv/portal.php',
      ]);
      expect(e.first.referer, 'http://p.tv/stalker_portal/c/');
      expect(
        StalkerUrls.endpoints('http://p.tv/stalker_portal/c/').first.api,
        'http://p.tv/stalker_portal/server/load.php',
      );
    });
    test('portal.php dogrudan verildiyse aynen kullanilir (query atilir)', () {
      final e = StalkerUrls.endpoints('http://p.tv:80/portal.php?x=1');
      expect(e, hasLength(1));
      expect(e.first.api, 'http://p.tv:80/portal.php');
      expect(e.first.base, 'http://p.tv:80');
    });
    test('server/load.php dogrudan verildiyse aynen kullanilir', () {
      final e = StalkerUrls.endpoints(
        'https://p.tv/stalker_portal/server/load.php',
      );
      expect(e, hasLength(1));
      expect(e.first.api, 'https://p.tv/stalker_portal/server/load.php');
      expect(e.first.base, 'https://p.tv/stalker_portal');
    });
    test('bos girdi → bos liste', () {
      expect(StalkerUrls.endpoints('   '), isEmpty);
    });
    test('clean: kaydedilecek bicim', () {
      expect(StalkerUrls.clean(' p.tv:8080/c/ '), 'http://p.tv:8080/c');
    });
    test('M3U export adaylari (Android withM3uExportStream sirasi)', () {
      final e = StalkerUrls.endpoints('http://p.tv:8080').first;
      expect(StalkerUrls.exportCandidates(e, '00:1A:79:00:00:01'), [
        'http://p.tv:8080/portal.php?action=export_itv_list&type=export_m3u&mac=00:1A:79:00:00:01&output=hls',
        'http://p.tv:8080/portal.php?action=export_itv_list&type=m3u_plus&mac=00:1A:79:00:00:01',
        'http://p.tv:8080/get.php?username=00:1A:79:00:00:01&password=00:1A:79:00:00:01&type=m3u_plus&output=hls',
      ]);
    });
  });

  group('StalkerMac', () {
    test('gecerli bicim normalize edilir (buyuk harf, iki nokta)', () {
      expect(StalkerMac.normalize('00:1a:79:ab:cd:ef'), '00:1A:79:AB:CD:EF');
      expect(StalkerMac.normalize(' 00-1A-79-AB-CD-EF '), '00:1A:79:AB:CD:EF');
      expect(StalkerMac.normalize('001A79ABCDEF'), '00:1A:79:AB:CD:EF');
    });
    test('gecersiz bicimler reddedilir', () {
      for (final bad in [
        '',
        '00:1A:79:AB:CD',
        '00:1A:79:AB:CD:EF:00',
        '00:1A:79:AB:CD:EG',
        '0:1A:79:AB:CD:EF',
        'hello',
      ]) {
        expect(StalkerMac.normalize(bad), isNull, reason: bad);
        expect(StalkerMac.isValid(bad), isFalse, reason: bad);
      }
    });
    test(
      'format: yazarken filtre (Android onValueChange) + 12 hex → kolonlu',
      () {
        expect(StalkerMac.format('00:1a:79:x?'), '00:1A:79:');
        expect(StalkerMac.format('001a79abcdef'), '00:1A:79:AB:CD:EF');
      },
    );
    test('random: MAG oneki 00:1A:79 ve gecerli', () {
      final m = StalkerMac.random(Random(1));
      expect(m, startsWith('00:1A:79:'));
      expect(StalkerMac.isValid(m), isTrue);
    });
  });

  group('StalkerJson — yanit ayristirma', () {
    test('handshake token', () {
      expect(
        StalkerJson.token(
          StalkerJson.decode(
            utf8.encode('{"js":{"token":"ABC123","random":"x"}}'),
          ),
        ),
        'ABC123',
      );
      expect(
        StalkerJson.token(StalkerJson.decode(utf8.encode('{"js":{}}'))),
        isNull,
      );
      expect(
        StalkerJson.token(
          StalkerJson.decode(utf8.encode('{"js":{"token":""}}')),
        ),
        isNull,
      );
    });
    test('JSON degil / onunde cop olan govde tolere edilir', () {
      expect(StalkerJson.decode(utf8.encode('<html>404</html>')), isNull);
      expect(
        StalkerJson.token(
          StalkerJson.decode(utf8.encode('﻿  junk{"js":{"token":"T"}}')),
        ),
        'T',
      );
    });
    test(
      'kanal sayfasi: data / total_items / max_page_items (string sayi)',
      () {
        final p = StalkerJson.page(
          StalkerJson.decode(
            utf8.encode(
              jsonEncode({
                'js': {
                  'total_items': '30',
                  'max_page_items': 14,
                  'data': [
                    {'id': '1', 'name': 'A'},
                    {'id': '2', 'name': 'B'},
                  ],
                },
              }),
            ),
          ),
        );
        expect(p.items, hasLength(2));
        expect(p.totalItems, 30);
        expect(p.maxPageItems, 14);
      },
    );
    test('js dogrudan liste olabilir; eksik sayilar varsayilan', () {
      final p = StalkerJson.page({
        'js': [
          {'id': '1'},
        ],
      });
      expect(p.items, hasLength(1));
      expect(p.totalItems, 0);
      expect(p.maxPageItems, 14);
      expect(StalkerJson.page(null).items, isEmpty);
    });
    test('genres: id → title, "*" (Tumu) atlanir', () {
      final g = StalkerJson.genres({
        'js': [
          {'id': '*', 'title': 'All'},
          {'id': 5, 'title': 'Spor'},
          {'id': '7', 'title': 'Haber'},
        ],
      });
      expect(g, {'5': 'Spor', '7': 'Haber'});
    });
    test('create_link cmd: ffmpeg/ffrt oneki temizlenir', () {
      expect(
        StalkerJson.linkCmd({
          'js': {'cmd': 'ffmpeg http://s.tv/live/1.ts?play_token=x'},
        }),
        'http://s.tv/live/1.ts?play_token=x',
      );
      expect(
        StalkerJson.linkCmd({
          'js': {'cmd': 'ffrt http://a/b'},
        }),
        'http://a/b',
      );
      expect(
        StalkerJson.linkCmd({
          'js': {'cmd': ' http://a/b '},
        }),
        'http://a/b',
      );
      expect(
        StalkerJson.linkCmd({
          'js': {'cmd': ''},
        }),
        isNull,
      );
      expect(
        StalkerJson.linkCmd({
          'js': {'error': 'nothing_to_play'},
        }),
        isNull,
      );
      expect(StalkerJson.linkCmd(null), isNull);
    });
  });

  group('cleanStalkerCmd / stalkerNeedsResolve', () {
    test('onek temizleme', () {
      expect(cleanStalkerCmd('ffmpeg http://h/x'), 'http://h/x');
      expect(cleanStalkerCmd('ffrt http://h/x'), 'http://h/x');
      expect(cleanStalkerCmd('auto  http://h/x'), 'http://h/x');
      expect(cleanStalkerCmd('http://h/x'), 'http://h/x');
      expect(cleanStalkerCmd('rtmp://h/x'), 'rtmp://h/x');
    });
    test('play-time cozumleme gerekir mi (Android resolveUrl kurali)', () {
      expect(stalkerNeedsResolve('ffrt http://localhost/ch/1'), isTrue);
      expect(stalkerNeedsResolve('ffmpeg http://real.tv/1.ts'), isTrue);
      expect(stalkerNeedsResolve('http://localhost/ch/1_'), isTrue);
      expect(stalkerNeedsResolve('http://real.tv/live/1.m3u8'), isFalse);
      expect(stalkerNeedsResolve(''), isFalse);
    });
  });

  group('StalkerMapper.channel', () {
    test('kanal JSON → satir (cmd isaretci, genre map, xmltv_id)', () {
      final r =
          StalkerMapper.channel(
            {
              'id': '101',
              'name': 'TRT 1 HD',
              'cmd': 'ffrt http://localhost/ch/101_',
              'logo': 'http://p.tv/misc/logos/320/101.png',
              'tv_genre_id': '5',
              'xmltv_id': 'trt1.tr',
            },
            playlistId: 'pl',
            genres: const {'5': 'Ulusal'},
            sortOrder: 7,
          )!;
      final ch = ChannelModel.fromMap(r);
      expect(ch.name, 'TRT 1 HD');
      expect(ch.streamUrl, 'ffrt http://localhost/ch/101_');
      expect(ch.category, 'Ulusal');
      expect(ch.streamType, 'live');
      expect(ch.sortOrder, 7);
      expect(ch.tvgId, 'trt1.tr');
      expect(ch.logoUrl, 'http://p.tv/misc/logos/320/101.png');
      expect(r['__cats'], ['Ulusal']);
      expect(r['searchKey'], isNotEmpty);
    });
    test('id deterministik (yeniden yuklemede favori/gecmis korunur)', () {
      Map<String, Object?> m() =>
          StalkerMapper.channel(
            {'id': '9', 'name': 'X', 'cmd': 'ffrt http://localhost/ch/9'},
            playlistId: 'pl',
            genres: const {},
            sortOrder: 0,
          )!;
      expect(m()['id'], m()['id']);
      final other =
          StalkerMapper.channel(
            {'id': '9', 'name': 'X', 'cmd': 'c'},
            playlistId: 'pl2',
            genres: const {},
            sortOrder: 0,
          )!;
      expect(other['id'], isNot(m()['id']));
    });
    test(
      'cmd yoksa Android yedegi; genre adi / "Canli" yedegi; null alanlar',
      () {
        final r =
            StalkerMapper.channel(
              {
                'id': 3,
                'name': null,
                'cmd': null,
                'logo': null,
                'genre': 'Spor',
              },
              playlistId: 'pl',
              genres: const {},
              sortOrder: 0,
            )!;
        expect(r['streamUrl'], 'ffrt http://localhost/ch/3');
        expect(r['category'], 'Spor');
        expect(r['name'], '');
        expect(r['logoUrl'], '');
        final r2 =
            StalkerMapper.channel(
              {'id': 4, 'name': 'Y'},
              playlistId: 'pl',
              genres: const {},
              sortOrder: 0,
            )!;
        expect(r2['category'], 'Canli');
      },
    );
    test('goreli logo atilir (gecersiz resim URL\'i olmasin)', () {
      final r =
          StalkerMapper.channel(
            {'id': '1', 'name': 'A', 'cmd': 'c', 'logo': '101.png'},
            playlistId: 'pl',
            genres: const {},
            sortOrder: 0,
          )!;
      expect(r['logoUrl'], '');
    });
    test('id ve cmd ikisi de yoksa atlanir', () {
      expect(
        StalkerMapper.channel(
          {'name': 'A'},
          playlistId: 'pl',
          genres: const {},
          sortOrder: 0,
        ),
        isNull,
      );
    });
  });

  group('StalkerPaging', () {
    test('maxPages: ceil(total/perPage), perPage<=0 → 1', () {
      expect(StalkerPaging.maxPages(30, 14), 3);
      expect(StalkerPaging.maxPages(28, 14), 2);
      expect(StalkerPaging.maxPages(0, 14), 0);
      expect(StalkerPaging.maxPages(30, 0), 1);
    });
    test('hasMore', () {
      // Sayfa 1/3, 14 geldi → devam
      expect(
        StalkerPaging.hasMore(
          page: 1,
          totalItems: 30,
          perPage: 14,
          fetched: 14,
          lastPageSize: 14,
        ),
        isTrue,
      );
      // Son sayfa
      expect(
        StalkerPaging.hasMore(
          page: 3,
          totalItems: 30,
          perPage: 14,
          fetched: 30,
          lastPageSize: 2,
        ),
        isFalse,
      );
      // Portal tum listeyi tek sayfada dondurdu (max_page_items=14 dese de)
      expect(
        StalkerPaging.hasMore(
          page: 1,
          totalItems: 500,
          perPage: 14,
          fetched: 500,
          lastPageSize: 500,
        ),
        isFalse,
      );
      // Bos sayfa
      expect(
        StalkerPaging.hasMore(
          page: 1,
          totalItems: 30,
          perPage: 14,
          fetched: 0,
          lastPageSize: 0,
        ),
        isFalse,
      );
      // Guvenlik ust siniri
      expect(
        StalkerPaging.hasMore(
          page: StalkerPaging.maxPageCap,
          totalItems: 1 << 30,
          perPage: 1,
          fetched: 10,
          lastPageSize: 1,
        ),
        isFalse,
      );
    });
  });

  group('StalkerHeaders (MAG taklidi)', () {
    test('cookie / UA / referer / bearer', () {
      final e = StalkerUrls.endpoints('http://p.tv').first;
      final h = StalkerHeaders.build(
        endpoint: e,
        mac: '00:1A:79:00:00:01',
        token: 'TK',
        lang: 'de',
      );
      expect(
        h['Cookie'],
        'mac=00:1A:79:00:00:01; stb_lang=de; timezone=Europe/Istanbul',
      );
      expect(h['User-Agent'], contains('MAG200 stbapp'));
      expect(h['X-User-Agent'], 'Model: MAG200; Link: Ethernet');
      expect(h['Referer'], 'http://p.tv/c/');
      expect(h['Authorization'], 'Bearer TK');
      expect(
        StalkerHeaders.build(
          endpoint: e,
          mac: 'm',
        ).containsKey('Authorization'),
        isFalse,
      );
    });
  });
}
