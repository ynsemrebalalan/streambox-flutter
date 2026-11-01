import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/other_apps/other_apps.dart';

Map<String, dynamic> _app(
  String slug, {
  String? android = 'https://play.google.com/store/apps/details?id=com.x',
  String? ios = 'https://apps.apple.com/us/app/x/id1',
  String icon = 'https://daveddeva.com/icons/x.png',
  bool kids = false,
}) =>
    {
      'slug': slug,
      'packageName': 'com.$slug',
      'name': {'tr': 'Ad $slug', 'en': 'Name $slug'},
      'tagline': {'tr': 'Kısa $slug', 'en': 'Short $slug'},
      'icon': icon,
      'android': android,
      'ios': ios,
      'web': 'https://daveddeva.com/apps/$slug',
      'kids': kids,
    };

String _doc(List<Map<String, dynamic>> apps, {int schema = 1}) =>
    jsonEncode({'schema': schema, 'apps': apps});

List<OtherApp> _parse(
  String raw, {
  String self = 'com.self',
  OtherAppsPlatform platform = OtherAppsPlatform.android,
  String lang = 'tr',
}) =>
    parseOtherApps(raw, selfPackage: self, platform: platform, lang: lang);

void main() {
  test('uygulama kendini listelemez', () {
    final list = _parse(_doc([_app('a'), _app('self')]), self: 'com.self');
    expect(list.map((a) => a.slug), ['a']);
  });

  test('Android listesinde Play bağlantısı olmayan uygulama gösterilmez', () {
    final list = _parse(_doc([_app('a', android: null), _app('b')]));
    expect(list.map((a) => a.slug), ['b']);
    expect(list.single.storeUrl, startsWith('https://play.google.com/'));
  });

  test('iOS listesinde App Store bağlantısı kullanılır', () {
    final list = _parse(_doc([_app('a', ios: null), _app('b')]), platform: OtherAppsPlatform.ios);
    expect(list.single.storeUrl, startsWith('https://apps.apple.com/'));
  });

  test('izinli olmayan alan adına giden bağlantı reddedilir', () {
    final list = _parse(_doc([
      _app('kotu', android: 'https://evil.example.com/app.apk'),
      _app('http', android: 'http://play.google.com/store/apps/details?id=x'),
      _app('iyi'),
    ]));
    expect(list.map((a) => a.slug), ['iyi']);
  });

  test('izinsiz ikon adresi boşaltılır ama uygulama kalır', () {
    final list = _parse(_doc([_app('a', icon: 'https://evil.example.com/i.png')]));
    expect(list.single.iconUrl, isNull);
  });

  test('dil yoksa önce İngilizceye düşer', () {
    final list = _parse(_doc([_app('a')]), lang: 'de');
    expect(list.single.name, 'Name a');
  });

  test('bilinmeyen sürüm, bozuk JSON ve eksik alanlar boş liste döner', () {
    expect(_parse(_doc([_app('a')], schema: 2)), isEmpty);
    expect(_parse('{bozuk'), isEmpty);
    expect(_parse(jsonEncode({'schema': 1, 'apps': [{'slug': 'x'}]})), isEmpty);
  });

  test('çocuk uygulaması işareti taşınır', () {
    expect(_parse(_doc([_app('k', kids: true)])).single.kids, isTrue);
  });
}
