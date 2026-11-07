import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/services/sync_shrink_gate.dart';

void main() {
  group('isDrasticShrink', () {
    test('needs at least 50 previous rows', () {
      expect(isDrasticShrink(previous: 49, current: 0), isFalse);
      expect(isDrasticShrink(previous: 50, current: 4), isTrue);
    });
    test('below 10% of previous is drastic, 10% or more is not', () {
      expect(isDrasticShrink(previous: 1000, current: 99), isTrue);
      expect(isDrasticShrink(previous: 1000, current: 100), isFalse);
      expect(isDrasticShrink(previous: 1000, current: 1000), isFalse);
    });
  });

  group('m3uShrinkVerdict (H3)', () {
    test('expired account: small valid M3U WITH Content-Length is rejected', () {
      expect(
        m3uShrinkVerdict(previous: 5000, current: 3, sawContentLength: true),
        M3uShrinkVerdict.drasticShrink,
      );
    });
    test('drastic shrink also without Content-Length', () {
      expect(
        m3uShrinkVerdict(previous: 5000, current: 3, sawContentLength: false),
        M3uShrinkVerdict.drasticShrink,
      );
    });
    test('half-size gate only without Content-Length', () {
      expect(
        m3uShrinkVerdict(previous: 1000, current: 400, sawContentLength: false),
        M3uShrinkVerdict.incomplete,
      );
      expect(
        m3uShrinkVerdict(previous: 1000, current: 400, sawContentLength: true),
        M3uShrinkVerdict.accept,
      );
    });
    test('small lists and growth are accepted', () {
      expect(m3uShrinkVerdict(previous: 0, current: 10, sawContentLength: true),
          M3uShrinkVerdict.accept);
      expect(m3uShrinkVerdict(previous: 20, current: 1, sawContentLength: true),
          M3uShrinkVerdict.accept);
      expect(m3uShrinkVerdict(previous: 100, current: 120, sawContentLength: false),
          M3uShrinkVerdict.accept);
    });
  });

  group('xtreamKeepDecision (H2)', () {
    test('all failed types are kept, not only the first', () {
      final d = xtreamKeepDecision(
        before: {'live': 500, 'movie': 800, 'series': 90},
        loaded: {'live': 480},
        failedTypes: {'movie', 'series'},
      );
      expect(d.keepTypes, {'movie', 'series'});
      expect(d.shrunkTypes, isEmpty);
    });
    test('type that had rows and now returns 0 is kept', () {
      final d = xtreamKeepDecision(
        before: {'live': 10, 'movie': 300},
        loaded: {'live': 0, 'movie': 290},
        failedTypes: const {},
      );
      expect(d.keepTypes, {'live'});
      expect(d.shrunkTypes, {'live'});
    });
    test('drastic shrink (< 10% of >= 50) is kept', () {
      final d = xtreamKeepDecision(
        before: {'live': 5000, 'movie': 40},
        loaded: {'live': 12, 'movie': 2},
        failedTypes: const {},
      );
      expect(d.keepTypes, {'live'});
      expect(d.shrunkTypes, {'live'});
    });
    test('normal refresh deletes nothing extra', () {
      final d = xtreamKeepDecision(
        before: {'live': 5000},
        loaded: {'live': 4900, 'movie': 0},
        failedTypes: const {},
      );
      expect(d.keepTypes, isEmpty);
      expect(d.shrunkTypes, isEmpty);
    });
    test('empty before (first sync) keeps nothing', () {
      final d = xtreamKeepDecision(
        before: const {},
        loaded: {'live': 0, 'movie': 5},
        failedTypes: const {},
      );
      expect(d.keepTypes, isEmpty);
    });
  });

  group('requireJsonList (H2)', () {
    test('List passes through', () {
      expect(requireJsonList([1, 2], 'get_live_streams'), [1, 2]);
      expect(requireJsonList(<dynamic>[], 'get_live_streams'), isEmpty);
    });
    test('non-List bodies throw FormatException', () {
      for (final body in <Object?>[
        <String, dynamic>{},
        null,
        {'user_info': {'auth': 0}},
        'oops',
      ]) {
        expect(() => requireJsonList(body, 'get_live_streams'),
            throwsA(isA<FormatException>()), reason: '$body');
      }
    });
  });
}
