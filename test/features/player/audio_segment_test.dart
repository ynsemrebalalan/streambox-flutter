import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/audio_segment.dart';

const _media = '''#EXTM3U
#EXT-X-TARGETDURATION:10
#EXTINF:10.0,
seg0.ts
#EXTINF:10.0,
seg1.ts
#EXTINF:10.0,
seg2.ts
#EXTINF:10.0,
seg3.ts
#EXTINF:10.0,
seg4.ts
#EXTINF:10.0,
seg5.ts
#EXTINF:10.0,
seg6.ts
#EXTINF:10.0,
seg7.ts
#EXTINF:10.0,
seg8.ts
#EXT-X-ENDLIST
''';

void main() {
  final base = Uri.parse('http://h/path/index.m3u8');

  group('selectHlsSegments', () {
    test('segments overlapping [start, start+60) with absolute urls', () {
      final r = selectHlsSegments(_media, base, startSec: 25);
      expect(r.map((s) => s.url).toList(), [
        'http://h/path/seg2.ts',
        'http://h/path/seg3.ts',
        'http://h/path/seg4.ts',
        'http://h/path/seg5.ts',
        'http://h/path/seg6.ts',
        'http://h/path/seg7.ts',
        'http://h/path/seg8.ts',
      ]);
      expect(r.first.startSec, 20);
    });

    test('start at 0 takes first 60s', () {
      final r = selectHlsSegments(_media, base, startSec: 0);
      expect(r.length, 6);
      expect(r.first.url, 'http://h/path/seg0.ts');
    });

    test('start past end returns empty', () {
      expect(selectHlsSegments(_media, base, startSec: 500), isEmpty);
    });

    test('absolute segment urls are kept', () {
      final r = selectHlsSegments('#EXTINF:5,\nhttp://cdn/a.ts\n', base, startSec: 0);
      expect(r.single.url, 'http://cdn/a.ts');
    });
  });

  group('pickHlsVariant', () {
    test('master playlist → lowest bandwidth variant', () {
      const master = '''#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1920x1080
hi/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
lo/index.m3u8
''';
      expect(pickHlsVariant(master, base), 'http://h/path/lo/index.m3u8');
    });
    test('media playlist → null', () {
      expect(pickHlsVariant(_media, base), isNull);
    });
  });

  group('progressiveByteRange', () {
    test('computes range around startSec from average bitrate', () {
      // 600 MB, 6000 s → 100 KB/s
      final r = progressiveByteRange(
          contentLength: 600000000, durationSec: 6000, startSec: 120, maxBytes: 50000000)!;
      expect(r.start, 12000000);
      expect(r.end, 12000000 + 6000000 - 1);
    });
    test('caps at maxBytes and at file end', () {
      final r = progressiveByteRange(
          contentLength: 1000, durationSec: 10, startSec: 9, maxBytes: 5000)!;
      expect(r.start, 900);
      expect(r.end, 999);
      final r2 = progressiveByteRange(
          contentLength: 10000000000, durationSec: 100, startSec: 0, maxBytes: 1000)!;
      expect(r2.end - r2.start + 1, 1000);
    });
    test('unknown length or duration → null', () {
      expect(progressiveByteRange(contentLength: 0, durationSec: 10, startSec: 0, maxBytes: 1), isNull);
      expect(progressiveByteRange(contentLength: 10, durationSec: 0, startSec: 0, maxBytes: 1), isNull);
    });
  });

  group('whisperCacheId', () {
    test('includes segment and target language', () {
      expect(whisperCacheId('ch1', 120, 'DE'), 'ch1_120_de_v2');
      expect(whisperCacheId('ch1', 120, ''), 'ch1_120_xx_v2');
    });
    test('alignSegment floors to 60s', () {
      expect(alignSegmentSec(73), 60);
      expect(alignSegmentSec(59), 0);
      expect(alignSegmentSec(120), 120);
    });
  });
}
