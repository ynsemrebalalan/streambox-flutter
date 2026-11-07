import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/models/playlist_model.dart';
import 'package:iptv_ai_player/data/services/m3u_parser.dart';

const _playlist = PlaylistModel(
  id: 'pl1',
  name: 'Test',
  type: 'm3u',
  url: 'http://example.com/list.m3u',
);

List<ChannelModel> _parse(String body) =>
    M3uParser.parse(_playlist, '#EXTM3U\n$body');

ChannelModel _one(String extinf, String url) {
  final list = _parse('$extinf\n$url\n');
  expect(list, hasLength(1));
  return list.first;
}

void main() {
  group('M3uParser stream type — canli kanal adindaki sayi dizi sayilmaz', () {
    test('uzantisiz m3u_plus canli kanallar live kalir', () {
      for (final name in [
        'TRT 1',
        'Kanal 7 HD',
        'beIN Sports 1 HD',
        'Show TV 4K',
      ]) {
        final ch = _one(
          '#EXTINF:-1 tvg-id="x" group-title="Ulusal",$name',
          'http://host:8080/user/pass/12345',
        );
        expect(ch.streamType, 'live', reason: name);
        expect(ch.seriesName, '', reason: name);
        expect(ch.episodeNumber, 0, reason: name);
      }
    });

    test('/movie/ path her zaman movie (sondaki sayi bolum degil)', () {
      for (final name in ['Rocky 2', 'Toy Story 4', 'Hızlı ve Öfkeli 7']) {
        final ch = _one(
          '#EXTINF:-1 group-title="Yabancı Filmler",$name',
          'http://host/movie/u/p/99.mkv',
        );
        expect(ch.streamType, 'movie', reason: name);
      }
    });

    test('/series/ path series', () {
      final ch = _one(
        '#EXTINF:-1 group-title="Diziler",Yargı S01E05',
        'http://host/series/u/p/5.mkv',
      );
      expect(ch.streamType, 'series');
      expect(ch.seriesName, 'Yargı');
      expect(ch.seasonNumber, 1);
      expect(ch.episodeNumber, 5);
    });

    test('/live/ path live', () {
      final ch = _one(
        '#EXTINF:-1 group-title="Filmler",Sinema TV 1',
        'http://host/live/u/p/7.ts',
      );
      expect(ch.streamType, 'live');
    });

    test('guclu dizi isareti (SxxExx, 1x05, sezon) uzantisiz akista series',
        () {
      expect(
        _one('#EXTINF:-1 group-title="Genel",Ezel S02E10', 'http://h/a/b/1')
            .streamType,
        'series',
      );
      expect(
        _one('#EXTINF:-1 group-title="Genel",Lost 1x05', 'http://h/a/b/2')
            .streamType,
        'series',
      );
      expect(
        _one('#EXTINF:-1 group-title="Genel",Kurtlar Vadisi 2. Sezon 3. Bölüm',
                'http://h/a/b/3')
            .streamType,
        'series',
      );
    });

    test('zayif isaret (Bolum N) film grubunda dizi sayilmaz', () {
      final dune = _one(
        '#EXTINF:-1 group-title="DUBLAJ FİLMLER",Dune Bölüm 2',
        'http://h/vod/dune.mp4',
      );
      expect(dune.streamType, 'movie');

      final yargi = _one(
        '#EXTINF:-1 group-title="Yerli Diziler",Yargı - Bölüm 5',
        'http://h/a/b/9',
      );
      expect(yargi.streamType, 'series');
      expect(yargi.seriesName, 'Yargı');
      expect(yargi.episodeNumber, 5);
    });

    test('uzantisiz akista kategori keyword movie/series yapmaz', () {
      for (final g in [
        '▱ SINEMA',
        '▱ BELGESEL',
        'Aksiyon Filmleri',
        '▱ DIAMANT DIZI',
      ]) {
        final ch = _one(
          '#EXTINF:-1 group-title="$g",Grand Cinema',
          'http://host:8080/user/pass/555',
        );
        expect(ch.streamType, 'live', reason: g);
      }
    });

    test('uzantisiz akista "(yyyy)" yil kalibi movie', () {
      final ch = _one(
        '#EXTINF:-1 group-title="Genel",Inception (2010)',
        'http://host:8080/user/pass/556',
      );
      expect(ch.streamType, 'movie');
    });

    test('VOD uzantisi: film grubu movie, anime grubu series', () {
      expect(
        _one('#EXTINF:-1 group-title="Filmler",Matrix', 'http://h/x/matrix.mp4')
            .streamType,
        'movie',
      );
      final anime = _one(
        '#EXTINF:-1 group-title="Anime",Naruto 12',
        'http://h/x/naruto12.mkv',
      );
      expect(anime.streamType, 'series');
      // Tip zaten series oldugunda sondaki sayi bolum olarak ayrilir.
      expect(anime.seriesName, 'Naruto');
      expect(anime.episodeNumber, 12);
    });

    test('.m3u8 canli', () {
      expect(
        _one('#EXTINF:-1 group-title="Ulusal",Kanal D 2', 'http://h/kd.m3u8')
            .streamType,
        'live',
      );
    });

    test('public detectStreamType reclassify icin ayni kurallari uygular', () {
      expect(M3uParser.detectStreamType('Ulusal', 'TRT 1', 'http://h/u/p/1'),
          'live');
      expect(
          M3uParser.detectStreamType(
              'Filmler', 'Rocky 2', 'http://h/movie/u/p/1.mp4'),
          'movie');
      expect(M3uParser.detectStreamType('Genel', 'Yargı S01E02', ''), 'series');
    });
  });

  group('M3uParser kanal adi', () {
    test('bos tvg-name display name ezmez', () {
      final ch = _one(
        '#EXTINF:-1 tvg-name="" group-title="Ulusal",TRT 1',
        'http://h/live/u/p/1.ts',
      );
      expect(ch.name, 'TRT 1');
    });

    test('display name once gelir', () {
      final ch = _one(
        '#EXTINF:-1 tvg-name="trt1hd" group-title="Ulusal",TRT 1 HD',
        'http://h/live/u/p/1.ts',
      );
      expect(ch.name, 'TRT 1 HD');
    });

    test('display name bossa dolu tvg-name kullanilir', () {
      final ch = _one(
        '#EXTINF:-1 tvg-name="TRT Haber" group-title="Haber",',
        'http://h/live/u/p/2.ts',
      );
      expect(ch.name, 'TRT Haber');
    });
  });
}
