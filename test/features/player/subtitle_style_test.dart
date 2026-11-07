import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/subtitle_style.dart';

void main() {
  group('SubtitleStyleSettings.fromRaw', () {
    test('defaults when nothing saved', () {
      final s = SubtitleStyleSettings.fromRaw();
      expect(s.fontSize, 16);
      expect(s.textColor, const Color(0xFFFFFFFF));
      expect(s.backgroundColor, const Color(0xAA000000));
    });

    test('maps saved option keys', () {
      final s = SubtitleStyleSettings.fromRaw(
          fontSize: '24', textColor: 'yellow', bgColor: 'opaque');
      expect(s.fontSize, 24);
      expect(s.textColor, const Color(0xFFFFEB3B));
      expect(s.backgroundColor, const Color(0xFF000000));
    });

    test('none bg is transparent', () {
      final s = SubtitleStyleSettings.fromRaw(bgColor: 'none');
      expect(s.backgroundColor.a, 0);
    });

    test('invalid values fall back safely', () {
      final s = SubtitleStyleSettings.fromRaw(
          fontSize: 'abc', textColor: 'purple', bgColor: '??');
      expect(s.fontSize, 16);
      expect(s.textColor, const Color(0xFFFFFFFF));
      expect(s.backgroundColor, const Color(0xAA000000));
    });

    test('font size clamps to sane range', () {
      expect(SubtitleStyleSettings.fromRaw(fontSize: '2').fontSize, 10);
      expect(SubtitleStyleSettings.fromRaw(fontSize: '200').fontSize, 40);
    });
  });
}
