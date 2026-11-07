import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/services/xmltv_stream_parser.dart';

const _xml = '''<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="trt1.tr">
    <display-name lang="en">TRT One</display-name>
    <display-name lang="tr">TRT 1</display-name>
    <icon src="http://i/trt1.png"/>
  </channel>
  <channel id="other.tr"><display-name>Other</display-name></channel>
  <programme start="20261103200000 +0300" stop="20261103210000 +0300" channel="trt1.tr">
    <title lang="en">News</title>
    <title lang="tr">Ana Haber &amp; Spor</title>
    <desc lang="tr">Gunun haberleri</desc>
    <category lang="tr">Haber</category>
  </programme>
  <programme start="20261103210000 +0300" stop="20261103220000 +0300" channel="other.tr">
    <title>Film</title>
  </programme>
  <programme start="20261103220000 +0300" stop="20261103230000 +0300" channel="unknown.tr">
    <title>Ghost</title>
  </programme>
  <programme start="20200101000000 +0000" stop="20200101010000 +0000" channel="trt1.tr">
    <title>Old</title>
  </programme>
</tv>''';

void main() {
  final now = DateTime.utc(2026, 11, 3, 12).millisecondsSinceEpoch;

  Future<XmltvParseResult> run({Set<String>? allowed}) async {
    final progs = <Map<String, Object?>>[];
    final r = await XmltvStreamParser.parse(
      Stream.value(_xml),
      playlistId: 'pl',
      allowedTvgIds: allowed,
      minStopMs: now - 2 * 24 * 3600 * 1000,
      onProgrammes: (b) async => progs.addAll(b),
      batchSize: 1,
    );
    return XmltvParseResult(r.channels, progs);
  }

  test('kanallar: tr display-name tercih, icon', () async {
    final r = await run();
    expect(r.channels.map((c) => c['tvgId']), ['trt1.tr', 'other.tr']);
    expect(r.channels.first['displayName'], 'TRT 1');
    expect(r.channels.first['icon'], 'http://i/trt1.png');
  });

  test('programlar: tr baslik, entity, saat dilimi; bilinmeyen kanal ve eski atlanir', () async {
    final r = await run();
    expect(r.programmes.map((p) => p['title']), ['Ana Haber & Spor', 'Film']);
    final p = r.programmes.first;
    expect(p['description'], 'Gunun haberleri');
    expect(p['category'], 'Haber');
    expect(p['startTime'], DateTime.utc(2026, 11, 3, 17).millisecondsSinceEpoch);
    expect(p['id'], 'trt1.tr_${p['startTime']}');
  });

  test('allowedTvgIds: yalniz playlist kanallari tutulur', () async {
    final r = await run(allowed: {'other.tr'});
    expect(r.programmes.map((p) => p['title']), ['Film']);
  });

  test('parseXmltvTime', () {
    expect(parseXmltvTime('20240101120000 +0300'),
        DateTime.utc(2024, 1, 1, 9).millisecondsSinceEpoch);
    expect(parseXmltvTime('20240101120000'),
        DateTime.utc(2024, 1, 1, 12).millisecondsSinceEpoch);
    expect(parseXmltvTime('bad'), 0);
  });
}
