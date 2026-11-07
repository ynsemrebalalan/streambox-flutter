import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/playlists/playlist_auto_refresh.dart';

void main() {
  const h = 3600 * 1000;
  final now = DateTime.utc(2026, 11, 3).millisecondsSinceEpoch;

  bool due(int interval,
          {int last = 0, int attempt = 0, bool session = false, bool force = false}) =>
      shouldAutoRefresh(
        intervalHours: interval,
        lastRefreshAt: last,
        lastAttemptAt: attempt,
        nowMs: now,
        refreshedThisSession: session,
        force: force,
      );

  test('Kapali (0) asla', () {
    expect(due(0), isFalse);
    expect(due(0, last: now - 1000 * h), isFalse);
  });

  test('Her acilista (-1): oturumda bir kez', () {
    expect(due(-1, last: now - h), isTrue);
    expect(due(-1, last: now - h, session: true), isFalse);
  });

  test('periyodik: hic yenilenmemis → evet; aralik dolunca evet', () {
    expect(due(24), isTrue);
    expect(due(24, last: now - 23 * h), isFalse);
    expect(due(24, last: now - 24 * h), isTrue);
    expect(due(168, last: now - 100 * h), isFalse);
    expect(due(8760, last: now - 9000 * h), isTrue);
  });

  test('yarim kalan deneme 30 dk cooldown — force dahil', () {
    // deneme basarili damgadan yeni ve 10 dk once → atla
    expect(due(24, last: now - 48 * h, attempt: now - 10 * 60000), isFalse);
    expect(due(-1, last: now - 48 * h, attempt: now - 10 * 60000, force: true),
        isFalse);
    // cooldown doldu
    expect(due(24, last: now - 48 * h, attempt: now - 31 * 60000), isTrue);
  });

  test('force araligi atlar', () {
    expect(due(0, force: true), isTrue);
  });

  test('RefreshInterval secenekleri Android ile ayni', () {
    expect(RefreshInterval.values.map((e) => e.hours),
        [0, -1, 24, 168, 720, 8760]);
    expect(RefreshInterval.fromHours(168), RefreshInterval.week);
    expect(RefreshInterval.fromHours(12), RefreshInterval.day);
  });

  test('varsayilan: dusuk cihazda haftalik, aksi halde 1 gun', () {
    expect(defaultRefreshHours(lowDevice: false, stored: null), 24);
    expect(defaultRefreshHours(lowDevice: true, stored: null), 168);
    expect(defaultRefreshHours(lowDevice: true, stored: -1), 168);
    expect(defaultRefreshHours(lowDevice: false, stored: 0), 0);
  });
}
