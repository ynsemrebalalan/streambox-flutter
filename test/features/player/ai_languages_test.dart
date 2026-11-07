import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/supported_ai_languages.dart';

void main() {
  group('SupportedAiLanguages', () {
    test('36 codes identical to Android list', () {
      expect(SupportedAiLanguages.codes.length, 36);
      expect(SupportedAiLanguages.codes, [
        'ar', 'az', 'bg', 'cs', 'da', 'de', 'el', 'en', 'es', 'fa',
        'fi', 'fr', 'he', 'hi', 'hr', 'hu', 'id', 'it', 'ja', 'ka',
        'ko', 'ms', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sr',
        'sv', 'th', 'tr', 'uk', 'vi', 'zh',
      ]);
    });

    test('every code has a display name', () {
      for (final c in SupportedAiLanguages.codes) {
        expect(SupportedAiLanguages.displayName(c), isNotEmpty, reason: c);
        expect(SupportedAiLanguages.displayName(c), isNot(c.toUpperCase()), reason: c);
      }
    });

    test('unknown code falls back to upper-case code', () {
      expect(SupportedAiLanguages.displayName('xx'), 'XX');
      expect(SupportedAiLanguages.displayName(''), '');
    });

    test('sorted list is ordered by display name', () {
      final s = SupportedAiLanguages.sortedByDisplay();
      expect(s.length, 36);
      final names = s.map((e) => e.value.toLowerCase()).toList();
      final copy = [...names]..sort();
      expect(names, copy);
    });
  });

  group('resolveAiTargetLang', () {
    test('explicit pref wins', () {
      expect(resolveAiTargetLang(pref: 'de', deviceLang: 'tr'), 'de');
    });
    test('empty pref uses device language when supported', () {
      expect(resolveAiTargetLang(pref: '', deviceLang: 'it'), 'it');
      expect(resolveAiTargetLang(pref: '', deviceLang: 'pt_BR'), 'pt');
    });
    test('unsupported device language falls back to en', () {
      expect(resolveAiTargetLang(pref: '', deviceLang: 'xx'), 'en');
      expect(resolveAiTargetLang(pref: '', deviceLang: ''), 'en');
    });
    test('unsupported pref is ignored', () {
      expect(resolveAiTargetLang(pref: 'zz', deviceLang: 'tr'), 'tr');
    });
  });
}
