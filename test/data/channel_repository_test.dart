import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/repositories/channel_repository.dart';

ChannelModel _ch(
  String id, {
  String name = 'X',
  String type = 'live',
  String seriesName = '',
  String category = 'Genel',
  int sortOrder = 0,
}) =>
    ChannelModel(
      id: id,
      playlistId: 'pl',
      name: name,
      streamUrl: 'http://h/$id',
      streamType: type,
      seriesName: seriesName,
      category: category,
      sortOrder: sortOrder,
    );

void main() {
  group('ChannelModel.toMap searchKey', () {
    test('her yazma yolunda searchKey dolu (name + seriesName katlanmis)', () {
      final m = _ch('1',
              name: 'S01E02 Bölüm', type: 'series', seriesName: 'Diriliş Ertuğrul')
          .toMap();
      expect(m['searchKey'], 's01e02 bolum dirilis ertugrul');
    });
  });

  group('applyPreservedUserState (sync kullanici verisini korur)', () {
    test('favori / izleme gecmisi yeni satira aktarilir', () {
      final fresh = _ch('a').toMap();
      final out = ChannelRepository.applyPreservedUserState(fresh, {
        'isFavorite': 1,
        'lastWatched': 1700,
        'lastPosition': 42,
        'isWatched': 1,
        'duration': 3600,
      });
      expect(out['isFavorite'], 1);
      expect(out['lastWatched'], 1700);
      expect(out['lastPosition'], 42);
      expect(out['isWatched'], 1);
      expect(out['duration'], 3600);
      // Diger alanlar yeni satirdan gelir.
      expect(out['name'], 'X');
      expect(out['streamUrl'], 'http://h/a');
    });

    test('korunan kayit yoksa satir aynen kalir', () {
      final fresh = _ch('b').toMap();
      expect(ChannelRepository.applyPreservedUserState(fresh, null), fresh);
    });

    test('girdi map mutate edilmez', () {
      final fresh = _ch('c').toMap();
      ChannelRepository.applyPreservedUserState(fresh, {'isFavorite': 1});
      expect(fresh['isFavorite'], 0);
    });

    test('preservedUserColumns sorgu kolonlari', () {
      expect(
        ChannelRepository.preservedUserColumns,
        containsAll(<String>[
          'isFavorite',
          'lastWatched',
          'lastPosition',
          'isWatched',
          'duration',
        ]),
      );
    });
  });

  group('groupSearchResults', () {
    test('dizi bolumleri seriesName basina tek sonuc, sira korunur', () {
      final res = ChannelRepository.groupSearchResults([
        _ch('1', name: 'Yargı S01E01', type: 'series', seriesName: 'Yargı', sortOrder: 1),
        _ch('2', name: 'Yargı Film', type: 'movie', sortOrder: 2),
        _ch('3', name: 'Yargı S01E02', type: 'series', seriesName: 'Yargı', sortOrder: 3),
        _ch('4', name: 'Yargı TV', type: 'live', sortOrder: 4),
        _ch('5', name: 'Tek', type: 'series', sortOrder: 5),
      ]);
      expect(res.map((c) => c.id).toList(), ['1', '2', '4', '5']);
    });

    test('limit uygulanir', () {
      final many = [for (var i = 0; i < 300; i++) _ch('$i', sortOrder: i)];
      expect(ChannelRepository.groupSearchResults(many, limit: 200),
          hasLength(200));
    });
  });

  group('isChannelVisibleInSearch', () {
    test('gizli kategori ve tab kurali uygulanir', () {
      final hidden = {'Yetişkin'};
      expect(
          ChannelRepository.isChannelVisibleInSearch(
              _ch('1', category: 'Yetişkin'), hidden),
          isFalse);
      expect(
          ChannelRepository.isChannelVisibleInSearch(
              _ch('2', category: ' Yetişkin '), hidden),
          isFalse);
      // Canli kanal film kategorisinde -> canli listesinde de gizli.
      expect(
          ChannelRepository.isChannelVisibleInSearch(
              _ch('3', category: 'Aksiyon Filmleri'), hidden),
          isFalse);
      expect(
          ChannelRepository.isChannelVisibleInSearch(
              _ch('4', category: 'Ulusal'), hidden),
          isTrue);
    });
  });
}
