import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/features/player/logic/next_episode.dart';

ChannelModel ep(String id, {int s = 1, int e = 0, int order = 0}) => ChannelModel(
      id: id,
      playlistId: 'p',
      name: id,
      streamUrl: 'http://x/$id.mkv',
      streamType: 'series',
      seriesName: 'Show',
      seasonNumber: s,
      episodeNumber: e,
      sortOrder: order,
    );

void main() {
  group('selectNextEpisode', () {
    test('same season by sortOrder', () {
      final list = [ep('a', e: 1, order: 1), ep('b', e: 2, order: 2), ep('c', e: 3, order: 3)];
      expect(selectNextEpisode(list[0], list)?.id, 'b');
    });

    test('unordered input still picks smallest greater sortOrder', () {
      final list = [ep('c', e: 3, order: 30), ep('a', e: 1, order: 10), ep('b', e: 2, order: 20)];
      expect(selectNextEpisode(list[1], list)?.id, 'b');
    });

    test('stale sortOrder (all 0) falls back to episode number', () {
      final list = [ep('a', e: 1), ep('c', e: 3), ep('b', e: 2)];
      expect(selectNextEpisode(list[0], list)?.id, 'b');
    });

    test('end of season jumps to first episode of next season', () {
      final list = [
        ep('s1e1', s: 1, e: 1, order: 1),
        ep('s1e2', s: 1, e: 2, order: 2),
        ep('s2e2', s: 2, e: 2, order: 4),
        ep('s2e1', s: 2, e: 1, order: 3),
        ep('s3e1', s: 3, e: 1, order: 5),
      ];
      expect(selectNextEpisode(list[1], list)?.id, 's2e1');
    });

    test('season 0 never jumps seasons', () {
      final list = [ep('a', s: 0, e: 1, order: 1), ep('b', s: 1, e: 1, order: 2)];
      expect(selectNextEpisode(list[0], list), isNull);
    });

    test('last episode of last season → null', () {
      final list = [ep('a', e: 1, order: 1), ep('b', e: 2, order: 2)];
      expect(selectNextEpisode(list[1], list), isNull);
    });

    test('non-series content → null', () {
      final movie = ChannelModel(
          id: 'm', playlistId: 'p', name: 'm', streamUrl: 'u', streamType: 'movie');
      expect(selectNextEpisode(movie, [movie]), isNull);
    });
  });
}
