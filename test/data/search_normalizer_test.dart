import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/utils/search_normalizer.dart';

void main() {
  group('foldSearchText', () {
    test('Turkce buyuk/kucuk harf katlamasi', () {
      expect(foldSearchText('İSTANBUL'), 'istanbul');
      expect(foldSearchText('IŞIK'), 'isik');
      expect(foldSearchText('ıspanak'), 'ispanak');
      expect(foldSearchText('Çağrı Gölü'), 'cagri golu');
      expect(foldSearchText('ŞEKER ÜZÜM ĞÖÇ'), 'seker uzum goc');
    });

    test('genel kucuk harf + trim', () {
      expect(foldSearchText('  Breaking BAD  '), 'breaking bad');
      expect(foldSearchText(''), '');
      expect(foldSearchText('   '), '');
    });

    test('ayni kelimenin farkli yazimlari eslesir', () {
      expect(foldSearchText('Diriliş Ertuğrul'),
          foldSearchText('DİRİLİŞ ERTUĞRUL'));
      expect(foldSearchText('Diriliş Ertuğrul'), 'dirilis ertugrul');
    });
  });

  group('buildSearchKey', () {
    test('name + seriesName birlikte indekslenir', () {
      final key = buildSearchKey('S01E05', 'Yargı');
      expect(key.contains('yargi'), isTrue);
      expect(key.contains('s01e05'), isTrue);
    });

    test('seriesName bossa sadece name', () {
      expect(buildSearchKey('TRT 1', ''), 'trt 1');
    });
  });

  group('searchLikePattern', () {
    test('katlanmis, trimli, iki yani joker', () {
      expect(searchLikePattern('  İst '), '%ist%');
    });

    test('LIKE ozel karakterleri kacirilir', () {
      expect(searchLikePattern('100%_a'), r'%100\%\_a%');
    });

    test('bos sorgu null', () {
      expect(searchLikePattern('   '), isNull);
    });
  });
}
