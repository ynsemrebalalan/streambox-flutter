import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/features/home/widgets/series_section.dart';

ChannelModel _ep(String id, String series, int season, int ep, int sort) =>
    ChannelModel(
      id: id,
      playlistId: 'pl',
      name: '$series S${season}E$ep',
      streamUrl: 'http://h/$id',
      streamType: 'series',
      seriesName: series,
      seasonNumber: season,
      episodeNumber: ep,
      sortOrder: sort,
    );

void main() {
  test('bolumler sezon icinde sortOrder ile siralanir (episodeNumber degil)',
      () {
    // Provider title'i yanlis: "E04" etiketli bolum aslinda ilk bolum.
    final groups = groupSeriesEpisodes([
      _ep('c', 'Yargı', 1, 1, 30),
      _ep('a', 'Yargı', 1, 4, 10),
      _ep('b', 'Yargı', 1, 2, 20),
      _ep('d', 'Yargı', 2, 1, 5),
      _ep('x', 'Ezel', 1, 1, 1),
    ]);
    expect(groups.keys, ['Yargı', 'Ezel']);
    expect(groups['Yargı']![1]!.map((e) => e.id), ['a', 'b', 'c']);
    expect(groups['Yargı']![2]!.map((e) => e.id), ['d']);
  });

  test('seriesName bos ise ad ile gruplanir', () {
    final groups = groupSeriesEpisodes([_ep('z', '', 0, 0, 0)]);
    expect(groups.keys.single, ' S0E0');
  });
}
