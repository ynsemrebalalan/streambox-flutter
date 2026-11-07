import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/playback_error.dart';

void main() {
  group('classifyPlaybackError', () {
    test('format / codec problems', () {
      expect(classifyPlaybackError('Failed to recognize file format.'),
          PlaybackErrorKind.unsupportedFormat);
      expect(classifyPlaybackError('No video or audio streams selected.'),
          PlaybackErrorKind.unsupportedFormat);
      expect(classifyPlaybackError('Could not open codec'), PlaybackErrorKind.unsupportedFormat);
    });
    test('corrupt data', () {
      expect(classifyPlaybackError('Invalid data found when processing input'),
          PlaybackErrorKind.corruptStream);
    });
    test('network / source unavailable', () {
      expect(classifyPlaybackError('Failed to open http://x'), PlaybackErrorKind.unavailable);
      expect(classifyPlaybackError('HTTP error 404 Not Found'), PlaybackErrorKind.unavailable);
      expect(classifyPlaybackError('stall 12s (buffering=true)'), PlaybackErrorKind.unavailable);
      expect(classifyPlaybackError(''), PlaybackErrorKind.unavailable);
    });
  });
}
