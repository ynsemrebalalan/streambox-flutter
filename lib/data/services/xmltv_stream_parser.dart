import 'dart:async';

import 'package:xml/xml_events.dart';

/// Ayrıştırma sonucu (channels: epg_channels satırları, programmes: test için).
class XmltvParseResult {
  final List<Map<String, Object?>> channels;
  final List<Map<String, Object?>> programmes;
  const XmltvParseResult(this.channels, this.programmes);
}

/// XMLTV zamanı "20240101120000 +0300" → UTC ms. Hatalıysa 0.
int parseXmltvTime(String s) {
  final t = s.trim();
  if (t.length < 14) return 0;
  final y = int.tryParse(t.substring(0, 4));
  final mo = int.tryParse(t.substring(4, 6));
  final d = int.tryParse(t.substring(6, 8));
  final h = int.tryParse(t.substring(8, 10));
  final mi = int.tryParse(t.substring(10, 12));
  final se = int.tryParse(t.substring(12, 14));
  if (y == null || mo == null || d == null || h == null || mi == null || se == null) {
    return 0;
  }
  var offsetMs = 0;
  final sp = t.indexOf(' ');
  if (sp > 0) {
    final tz = t.substring(sp + 1).trim();
    if (tz.length >= 5 && (tz[0] == '+' || tz[0] == '-')) {
      final oh = int.tryParse(tz.substring(1, 3)) ?? 0;
      final om = int.tryParse(tz.substring(3, 5)) ?? 0;
      offsetMs = (tz[0] == '-' ? -1 : 1) * (oh * 60 + om) * 60000;
    }
  }
  return DateTime.utc(y, mo, d, h, mi, se).millisecondsSinceEpoch - offsetMs;
}

/// Akışlı XMLTV ayrıştırıcı (Android XmltvParser paritesi, pull-parser
/// yerine xml event stream). Tüm XML hiç belleğe alınmaz; programlar
/// batch'ler halinde [onProgrammes]'a verilir.
///
///  - Dil tercihi: tr > en > ilk (display-name / title / desc / category).
///  - Yalnız bilinen kanalların programları: [allowedTvgIds] verilirse o set
///    (playlist'in tvg-id'leri), yoksa dosyada tanımlı `<channel>`'lar.
///  - [minStopMs]'den önce biten programlar atılır (2 günden eski).
class XmltvStreamParser {
  XmltvStreamParser._();

  static Future<XmltvParseResult> parse(
    Stream<String> text, {
    required String playlistId,
    required Future<void> Function(List<Map<String, Object?>> batch) onProgrammes,
    Set<String>? allowedTvgIds,
    int minStopMs = 0,
    int batchSize = 2000,
  }) async {
    final channels = <Map<String, Object?>>[];
    final declared = <String>{};
    var batch = <Map<String, Object?>>[];

    // Kanal durumu
    String? chId;
    String? chName;
    String? chNameLang;
    String chIcon = '';
    // Program durumu
    Map<String, String>? prog;
    final langOf = <String, String>{};
    // Metin hedefi
    String? textField;
    String? textLang;
    final buf = StringBuffer();

    bool better(String? existing, String lang) =>
        existing == null || lang == 'tr' || (existing != 'tr' && lang == 'en');

    String attr(XmlStartElementEvent e, String name) {
      for (final a in e.attributes) {
        if (a.name == name) return a.value;
      }
      return '';
    }

    await for (final events in text.toXmlEvents().normalizeEvents()) {
      for (final e in events) {
        if (e is XmlStartElementEvent) {
          switch (e.name) {
            case 'channel':
              chId = attr(e, 'id');
              chName = null;
              chNameLang = null;
              chIcon = '';
            case 'programme':
              prog = {
                'start': attr(e, 'start'),
                'stop': attr(e, 'stop'),
                'channel': attr(e, 'channel'),
              };
              langOf.clear();
            case 'display-name' when chId != null && prog == null:
              final lang = attr(e, 'lang');
              if (better(chNameLang, lang)) {
                textField = 'display-name';
                textLang = lang;
                buf.clear();
              }
            case 'title' || 'desc' || 'category' when prog != null:
              final lang = attr(e, 'lang');
              if (better(langOf[e.name], lang)) {
                textField = e.name;
                textLang = lang;
                buf.clear();
              }
            case 'icon':
              final src = attr(e, 'src');
              if (prog != null) {
                prog['icon'] ??= src;
              } else if (chId != null && chIcon.isEmpty) {
                chIcon = src;
              }
          }
          if (e.isSelfClosing && textField == e.name) textField = null;
        } else if (e is XmlTextEvent) {
          if (textField != null) buf.write(e.value);
        } else if (e is XmlCDATAEvent) {
          if (textField != null) buf.write(e.value);
        } else if (e is XmlEndElementEvent) {
          if (textField != null && e.name == textField) {
            final v = buf.toString().trim();
            if (textField == 'display-name') {
              chName = v;
              chNameLang = textLang;
            } else if (prog != null) {
              prog[textField] = v;
              langOf[textField] = textLang ?? '';
            }
            textField = null;
          }
          if (e.name == 'channel' && chId != null) {
            final id = chId.trim();
            if (id.isNotEmpty && declared.add(id)) {
              channels.add({
                'tvgId': id,
                'playlistId': playlistId,
                'displayName': (chName ?? '').isEmpty ? id : chName,
                'icon': chIcon,
              });
            }
            chId = null;
          } else if (e.name == 'programme' && prog != null) {
            final p = prog;
            prog = null;
            final cid = p['channel']!.trim();
            final known = allowedTvgIds != null
                ? allowedTvgIds.contains(cid)
                : declared.contains(cid);
            if (!known) continue;
            final start = parseXmltvTime(p['start']!);
            final stop = parseXmltvTime(p['stop']!);
            if (start == 0 || stop == 0 || stop < minStopMs) continue;
            batch.add({
              'id': '${cid}_$start',
              'channelId': cid,
              'title': p['title'] ?? '',
              'description': p['desc'] ?? '',
              'startTime': start,
              'stopTime': stop,
              'category': p['category'] ?? '',
              'icon': p['icon'] ?? '',
            });
            if (batch.length >= batchSize) {
              await onProgrammes(batch);
              batch = <Map<String, Object?>>[];
            }
          }
        }
      }
    }
    if (batch.isNotEmpty) await onProgrammes(batch);
    return XmltvParseResult(channels, const []);
  }
}
