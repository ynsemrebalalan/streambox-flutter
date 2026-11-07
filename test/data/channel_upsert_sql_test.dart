import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/repositories/channel_repository.dart';

void main() {
  const row = <String, Object?>{
    'id': 'abc',
    'name': 'TRT 1',
    'streamUrl': 'http://h/live/u/p/1.ts',
    'streamType': 'live',
    'category': 'Ulusal',
    'searchKey': 'trt 1',
  };
  const userColumns = [
    'isFavorite', 'lastWatched', 'lastPosition', 'duration', 'addedAt'
  ];

  group('UPSERT (SQLite >= 3.24)', () {
    test('modern path: single ON CONFLICT statement', () {
      final st = ChannelRepository.upsertStatements('pl', 7, 1000, row,
          legacy: false);
      expect(st, hasLength(1));
      expect(st.single.$1, contains('ON CONFLICT(id) DO UPDATE SET'));
      expect(st.single.$2, ChannelRepository.upsertArgs('pl', 7, 1000, row));
    });

    test('legacy path: INSERT OR IGNORE + UPDATE WHERE id = ?', () {
      final st = ChannelRepository.upsertStatements('pl', 7, 1000, row,
          legacy: true);
      expect(st, hasLength(2));
      final (ins, insArgs) = st[0];
      final (upd, updArgs) = st[1];
      expect(ins, startsWith('INSERT OR IGNORE INTO channels'));
      expect(ins, isNot(contains('ON CONFLICT')));
      expect(insArgs, ChannelRepository.upsertArgs('pl', 7, 1000, row));
      expect(upd, startsWith('UPDATE channels SET '));
      expect(upd, endsWith(' WHERE id = ?'));
      expect(updArgs.last, 'abc');
      // UPDATE yalniz saglayici kolonlarini yazar (upsert ile ayni).
      expect(updArgs, hasLength(ChannelRepository.providerColumns.length + 1));
      expect(updArgs.sublist(0, updArgs.length - 1),
          ChannelRepository.upsertArgs('pl', 7, 1000, row).sublist(1, 14));
    });

    test('both paths leave user columns and addedAt untouched on update', () {
      final modernSet = ChannelRepository.upsertSql().split('DO UPDATE SET').last;
      final legacyUpd = ChannelRepository.legacyUpdateSql();
      for (final c in userColumns) {
        expect(modernSet, isNot(contains('$c =')), reason: c);
        expect(legacyUpd, isNot(contains('$c =')), reason: c);
      }
      for (final c in ChannelRepository.providerColumns) {
        expect(legacyUpd, contains('$c = ?'), reason: c);
      }
    });

    test('detects UPSERT syntax errors only', () {
      expect(
          ChannelRepository.isUpsertUnsupportedError(
              'DatabaseException(near "ON": syntax error (code 1 SQLITE_ERROR))'),
          isTrue);
      expect(
          ChannelRepository.isUpsertUnsupportedError(
              'near "DO": syntax error'),
          isTrue);
      expect(
          ChannelRepository.isUpsertUnsupportedError(
              'DatabaseException(database is locked)'),
          isFalse);
    });
  });
}
