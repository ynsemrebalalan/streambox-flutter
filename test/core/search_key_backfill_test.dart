import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/database/app_database.dart';

void main() {
  test('searchKey backfill pages by rowid cursor (M1)', () {
    final sql = AppDatabase.searchKeyBackfillSql;
    expect(sql, contains('rowid > ?'));
    expect(sql, contains('ORDER BY rowid'));
    expect(sql, contains('LIMIT ?'));
    expect(sql, contains("searchKey = ''"));
  });
}
