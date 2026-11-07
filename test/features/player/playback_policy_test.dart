import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/playback_policy.dart';

void main() {
  group('shouldOfferResume', () {
    test('only above 10 seconds', () {
      expect(shouldOfferResume(savedMs: 10000, streamType: 'movie'), isFalse);
      expect(shouldOfferResume(savedMs: 10001, streamType: 'movie'), isTrue);
      expect(shouldOfferResume(savedMs: 60000, streamType: 'series'), isTrue);
    });
    test('never for live', () {
      expect(shouldOfferResume(savedMs: 600000, streamType: 'live'), isFalse);
    });
    test('not when the item was essentially finished', () {
      expect(
          shouldOfferResume(savedMs: 96000, streamType: 'movie', durationMs: 100000),
          isFalse);
      expect(
          shouldOfferResume(savedMs: 50000, streamType: 'movie', durationMs: 100000),
          isTrue);
    });
  });

  group('reachedWatchedThreshold', () {
    test('90% marks watched', () {
      expect(reachedWatchedThreshold(positionMs: 89, durationMs: 100), isFalse);
      expect(reachedWatchedThreshold(positionMs: 90, durationMs: 100), isTrue);
      expect(reachedWatchedThreshold(positionMs: 90, durationMs: 0), isFalse);
    });
  });

  group('EndOfMediaDetector', () {
    test('fires after 4 stalled ticks near the end', () {
      final d = EndOfMediaDetector();
      const dur = 100000;
      expect(d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true), isFalse);
      expect(d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true), isFalse);
      expect(d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true), isFalse);
      expect(d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true), isFalse);
      expect(d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true), isTrue);
    });
    test('progress resets the stall counter', () {
      final d = EndOfMediaDetector();
      const dur = 100000;
      for (var i = 0; i < 3; i++) {
        d.tick(positionMs: 99000, durationMs: dur, playWhenReady: true);
      }
      expect(d.tick(positionMs: 99200, durationMs: dur, playWhenReady: true), isFalse);
      expect(d.tick(positionMs: 99200, durationMs: dur, playWhenReady: true), isFalse);
    });
    test('paused or far from the end never fires', () {
      final d = EndOfMediaDetector();
      for (var i = 0; i < 10; i++) {
        expect(d.tick(positionMs: 99000, durationMs: 100000, playWhenReady: false), isFalse);
      }
      final d2 = EndOfMediaDetector();
      for (var i = 0; i < 10; i++) {
        expect(d2.tick(positionMs: 50000, durationMs: 100000, playWhenReady: true), isFalse);
      }
    });
  });

  group('player network options', () {
    test('user agent mirrors Android format', () {
      expect(playbackUserAgent('2.0.2'), 'StreamBox/2.0.2 (iOS)');
    });
    test('buffer ms maps to mpv cache seconds with clamp', () {
      expect(cacheSecsForBufferMs(8000), 10);
      expect(cacheSecsForBufferMs(2000), 4);
      expect(cacheSecsForBufferMs(500), 4); // clamp min 2000ms
      expect(cacheSecsForBufferMs(99999), 10); // clamp max 8000ms
    });
  });

  group('seekTargetMs', () {
    test('clamps at 0 and duration', () {
      expect(seekTargetMs(currentMs: 5000, deltaMs: -10000, durationMs: 100000), 0);
      expect(seekTargetMs(currentMs: 95000, deltaMs: 10000, durationMs: 100000), 100000);
      expect(seekTargetMs(currentMs: 5000, deltaMs: 10000, durationMs: 0), 15000);
    });
  });
}
