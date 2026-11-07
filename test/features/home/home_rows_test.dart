import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/data/repositories/channel_repository.dart';
import 'package:iptv_ai_player/features/home/home_rows.dart';
import 'package:iptv_ai_player/features/home/home_state.dart';

ChannelModel _ep(String id,
        {String series = 'Dizi',
        int pos = 0,
        int dur = 0,
        bool watched = false,
        String url = ''}) =>
    ChannelModel(
      id: id,
      playlistId: 'pl',
      name: 'Ep $id',
      streamUrl: url.isEmpty ? 'http://h/$id' : url,
      streamType: 'series',
      seriesName: series,
      seasonNumber: 1,
      lastPosition: pos,
      duration: dur,
      isWatched: watched,
      lastWatched: 1,
    );

void main() {
  group('resolveContinueWatching (Android Nerede Kaldim)', () {
    test('biten bolum sonrakine ilerler, devam eden kalir', () async {
      final out = await resolveContinueWatching(
        [
          _ep('a1', series: 'A', watched: true),
          _ep('b1', series: 'B', pos: 1000, dur: 3600000),
        ],
        (ep) async => ep.id == 'a1' ? _ep('a2', series: 'A') : null,
      );
      expect(out.map((e) => e.id), ['a2', 'b1']);
    });

    test('son 60 sn = bitti; sonraki yoksa ayni bolum', () async {
      final out = await resolveContinueWatching(
        [_ep('x', pos: 3550000, dur: 3600000)],
        (_) async => null,
      );
      expect(out.single.id, 'x');
      expect(isEpisodeNearEnd(_ep('y', pos: 3550000, dur: 3600000)), isTrue);
      expect(isEpisodeNearEnd(_ep('z', pos: 100, dur: 3600000)), isFalse);
    });

    test('ayni dizi iki kez gorunmez', () async {
      final out = await resolveContinueWatching(
        [_ep('a2', series: 'A'), _ep('a1', series: 'A')],
        (_) async => null,
      );
      expect(out.map((e) => e.id), ['a2']);
    });
  });

  group('A-Z siralama (Turkce, buyuk/kucuk duyarsiz)', () {
    ChannelModel c(String n) =>
        ChannelModel(id: n, playlistId: 'p', name: n, streamUrl: 'u$n');
    test('fold ile siralar', () {
      final s = sortChannelsByName([c('zeta'), c('İstanbul'), c('apple'), c('Işık')]);
      expect(s.map((e) => e.name), ['apple', 'Işık', 'İstanbul', 'zeta']);
    });
    test('HomeState.sortedChannels kullanir', () {
      final st = HomeState(channels: [c('b'), c('A'), c('c')],
          sortOrder: SortOrder.nameAsc);
      expect(st.sortedChannels.map((e) => e.name), ['A', 'b', 'c']);
      final d = st.copyWith(sortOrder: SortOrder.nameDesc);
      expect(d.sortedChannels.map((e) => e.name), ['c', 'b', 'A']);
    });
  });

  test('arama kapsami sekme turu', () {
    expect(searchStreamTypeForTab('live'), 'live');
    expect(searchStreamTypeForTab('home'), isNull);
    expect(searchStreamTypeForTab('favorites'), isNull);
  });

  test('dedupeRecents id + streamUrl', () {
    final list = [
      _ep('1', url: 'http://s/1'),
      _ep('1', url: 'http://s/1'),
      _ep('2', url: 'http://s/1'),
      _ep('3', url: 'http://s/3'),
    ];
    expect(ChannelRepository.dedupeRecents(list).map((e) => e.id), ['1', '3']);
  });

  test('isSeriesContainer', () {
    const c = ChannelModel(
        id: 'c', playlistId: 'p', name: 'D', streamType: 'series',
        streamUrl: 'http://h/player_api.php?action=get_series_info&series_id=1');
    expect(c.isSeriesContainer, isTrue);
    expect(_ep('e').isSeriesContainer, isFalse);
  });

  test('upsertSql kullanici kolonlarini guncellemez', () {
    final sql = ChannelRepository.upsertSql();
    final set = sql.substring(sql.indexOf('DO UPDATE SET'));
    for (final col in const [
      'isFavorite', 'lastWatched', 'lastPosition', 'isWatched', 'duration',
      'addedAt',
    ]) {
      expect(set.contains('$col ='), isFalse, reason: col);
    }
    expect(set, contains('syncGen = excluded.syncGen'));
    final args = ChannelRepository.upsertArgs('pl', 7, 1, {'id': 'x', 'name': 'N'});
    expect(args.length, '?'.allMatches(sql).length);
  });
}
