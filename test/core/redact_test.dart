import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/utils/redact.dart';
import 'package:iptv_ai_player/features/player/services/error_report_service.dart';

void main() {
  group('redactSensitive (H7)', () {
    test('Xtream stream URL keeps only scheme + host', () {
      final out = redactSensitive(
          'Failed to open http://iptv.example.com:8080/live/john/s3cret/1234.ts.');
      expect(out, 'Failed to open http://iptv.example.com:8080/<redacted>');
      expect(out, isNot(contains('john')));
      expect(out, isNot(contains('s3cret')));
    });

    test('M3U get.php username/password', () {
      final out = redactSensitive(
          'HTTP 403 https://h.tv/get.php?username=alice&password=pw123&type=m3u_plus');
      expect(out, 'HTTP 403 https://h.tv/<redacted>');
    });

    test('Stalker mac= and token=', () {
      final out = redactSensitive(
          'open failed: http://portal.tv/play/live.php?mac=00:1A:79:12:34:56&stream=5&token=abcDEF');
      expect(out, isNot(contains('00:1A:79')));
      expect(out, isNot(contains('abcDEF')));
      expect(out, contains('http://portal.tv/<redacted>'));
    });

    test('userinfo in URL is dropped', () {
      final out = redactSensitive('rtmp://bob:pw@cdn.tv/app/stream');
      expect(out, 'rtmp://cdn.tv/<redacted>');
    });

    test('bare Xtream path segments without scheme', () {
      final out = redactSensitive('segment /movie/john/s3cret/77.mkv not found');
      expect(out, 'segment /movie/<redacted>/<redacted>/77.mkv not found');
    });

    test('bare query values without URL', () {
      final out = redactSensitive(
          'params username=alice&Password=pw&token=t0k mac=00:1A:79:AA:BB:CC done');
      expect(out,
          'params username=<redacted>&Password=<redacted>&token=<redacted> mac=<redacted> done');
    });

    test('text without secrets is unchanged', () {
      const s = 'Failed to recognize file format.';
      expect(redactSensitive(s), s);
    });
  });

  group('buildErrorReportMessage (H7)', () {
    test('error text and note are redacted', () {
      final msg = buildErrorReportMessage(
        channelName: 'TRT 1',
        errorMessage: 'Failed to open http://h:80/live/u1/p1/9.ts',
        device: 'Apple iPhone15,2',
        osVersion: '18.1',
        appVersion: '2.0.0',
        note: 'my link http://h:80/get.php?username=u1&password=p1',
      );
      expect(msg, isNot(contains('u1')));
      expect(msg, isNot(contains('p1')));
      expect(msg, contains('Kanal: TRT 1'));
      expect(msg, contains('http://h:80/<redacted>'));
    });
  });
}
