import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/services/epg_service.dart';

void main() {
  const h = 3600 * 1000;
  final now = DateTime.utc(2026, 11, 3).millisecondsSinceEpoch;

  bool due({bool pro = true, String url = 'http://e', int last = 0, int cov = 0}) =>
      shouldRefreshEpg(
          isPro: pro, url: url, lastRefreshMs: last, coverageEndMs: cov, nowMs: now);

  test('Pro degil veya URL yok → hayir', () {
    expect(due(pro: false), isFalse);
    expect(due(url: ' '), isFalse);
  });
  test('veri yok → evet (varsayilan kapali DEGIL)', () {
    expect(due(), isTrue);
  });
  test('kapsam 6 sa sonrasini asiyorsa → hayir', () {
    expect(due(cov: now + 7 * h), isFalse);
    expect(due(cov: now + 5 * h), isTrue);
  });
  test('cooldown 6 sa', () {
    expect(due(last: now - 2 * h), isFalse);
    expect(due(last: now - 7 * h), isTrue);
  });
}
