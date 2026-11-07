import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/subtitle_cue.dart';
import 'package:iptv_ai_player/features/player/logic/translated_cues.dart';

void main() {
  const src = [
    SubtitleCue(startMs: 0, endMs: 1000, text: 'a'),
    SubtitleCue(startMs: 1000, endMs: 2000, text: 'b'),
  ];

  group('splitTranslatedCues (M5)', () {
    test('matching count keeps timings and is cacheable', () {
      final r = splitTranslatedCues(src, 'x\n<<CUE>>\ny')!;
      expect(r.aligned, isTrue);
      expect(r.cues.map((c) => c.text), ['x', 'y']);
      expect(r.cues[1].startMs, 1000);
    });

    test('count mismatch merges into one cue and is NOT cacheable', () {
      final r = splitTranslatedCues(src, 'x y z')!;
      expect(r.aligned, isFalse);
      expect(r.cues, hasLength(1));
      expect(r.cues.single.startMs, 0);
      expect(r.cues.single.endMs, 2000);
    });

    test('empty translation is a failure', () {
      expect(splitTranslatedCues(src, null), isNull);
      expect(splitTranslatedCues(src, '   '), isNull);
    });
  });
}
