import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/epg/epg_guide_layout.dart';

void main() {
  final start = DateTime.utc(2026, 11, 3).millisecondsSinceEpoch;
  const min = 60000;
  final layout = GuideLayout(
      windowStartMs: start, windowEndMs: start + 24 * 60 * min, pxPerMinute: 4);

  test('genislik sureyle orantili', () {
    expect(layout.block(start + 60 * min, start + 90 * min), (240.0, 120.0));
    expect(layout.totalWidth, 24 * 60 * 4);
  });
  test('pencereye kirpilir / disindaysa null', () {
    expect(layout.block(start - 30 * min, start + 30 * min), (0.0, 120.0));
    expect(layout.block(start - 60 * min, start - 1), isNull);
    expect(layout.block(start + 10 * min, start + 10 * min), isNull);
  });
  test('30 dk tikleri', () {
    final t = layout.ticks();
    expect(t.length, 48);
    expect(t[1] - t[0], 30 * min);
  });
  test('simdi cizgisi', () {
    expect(layout.nowOffset(start + 15 * min), 60.0);
    expect(layout.nowOffset(start - 1), isNull);
  });
}
