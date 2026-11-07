import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/cancel_epoch.dart';
import 'package:iptv_ai_player/features/player/services/mpv_audio_extractor.dart';

void main() {
  group('CancelEpoch (M3)', () {
    test('captured predicate flips only after bump', () {
      final e = CancelEpoch();
      final first = e.capture();
      expect(first(), isFalse);
      e.bump();
      expect(first(), isTrue);
      final second = e.capture();
      expect(second(), isFalse, reason: 'new work after stop is not cancelled');
    });
  });

  group('MpvAudioExtractor.isPcmAoConfirmed (M4)', () {
    test('only an explicit pcm ao is confirmed', () {
      expect(MpvAudioExtractor.isPcmAoConfirmed('pcm'), isTrue);
      expect(MpvAudioExtractor.isPcmAoConfirmed(''), isFalse);
      expect(MpvAudioExtractor.isPcmAoConfirmed('coreaudio'), isFalse);
      expect(MpvAudioExtractor.isPcmAoConfirmed('audiounit'), isFalse);
    });
  });
}
