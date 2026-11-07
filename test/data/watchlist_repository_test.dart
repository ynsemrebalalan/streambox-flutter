import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/repositories/watchlist_repository.dart';

void main() {
  group('WatchlistRepository.fromJoinedRow (cross-playlist snapshot)', () {
    test('kanal varsa guncel satir', () {
      final ch = WatchlistRepository.fromJoinedRow({
        'wCid': 'c1', 'wPid': 'p1', 'wName': 'Eski', 'wUrl': 'u',
        'id': 'c1', 'playlistId': 'p1', 'name': 'Yeni', 'streamUrl': 'u2',
        'isFavorite': 1,
      })!;
      expect(ch.name, 'Yeni');
      expect(ch.isFavorite, isTrue);
    });
    test('kanal silinmisse snapshot', () {
      final ch = WatchlistRepository.fromJoinedRow({
        'wCid': 'c1', 'wPid': 'p1', 'wName': 'Film', 'wUrl': 'http://x',
        'wType': 'movie', 'wSeason': 0, 'wEp': 0,
        'id': null, 'playlistId': null,
      })!;
      expect(ch.id, 'c1');
      expect(ch.playlistId, 'p1');
      expect(ch.name, 'Film');
      expect(ch.streamType, 'movie');
    });
    test('snapshot bos + kanal yok → null', () {
      expect(
          WatchlistRepository.fromJoinedRow(
              {'wCid': 'c', 'wPid': 'p', 'wUrl': '', 'id': null}),
          isNull);
    });
  });
}
