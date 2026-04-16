import '../models/subtitle_cue.dart';

/// WebVTT format parser.
/// WEBVTT header + "HH:MM:SS.mmm --> HH:MM:SS.mmm" timeline'lari parse eder.
class VttParser {
  static List<SubtitleCue> parse(String vtt) {
    final cues = <SubtitleCue>[];
    final lines = vtt.split('\n');
    var i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();

      // Timeline: "00:00:01.000 --> 00:00:04.500"
      if (line.contains('-->')) {
        final arrowIdx = line.indexOf('-->');
        final startStr = line.substring(0, arrowIdx).trim();
        final endRaw = line
            .substring(arrowIdx + 3)
            .trim()
            .split(RegExp(r'\s'))
            .first; // position/settings sonrasini ignore et

        final startMs = _parseTime(startStr);
        final endMs = _parseTime(endRaw);

        // Text satirlarini topla (bos satira kadar)
        final textLines = <String>[];
        i++;
        while (i < lines.length && lines[i].trim().isNotEmpty) {
          final cleaned =
              lines[i].trim().replaceAll(RegExp(r'<[^>]+>'), ''); // HTML tag
          if (cleaned.isNotEmpty) textLines.add(cleaned);
          i++;
        }

        if (textLines.isNotEmpty && startMs < endMs) {
          cues.add(SubtitleCue(
            startMs: startMs,
            endMs: endMs,
            text: textLines.join('\n'),
          ));
        }
        continue;
      }
      i++;
    }
    return cues;
  }

  /// "HH:MM:SS.mmm" veya "MM:SS.mmm" → milliseconds.
  static int _parseTime(String time) {
    final cleaned = time.replaceAll(',', '.'); // SRT compat
    final parts = cleaned.split(':');
    try {
      if (parts.length == 3) {
        final h = int.parse(parts[0].trim());
        final m = int.parse(parts[1].trim());
        final sec = double.parse(parts[2].trim());
        return ((h * 3600 + m * 60) * 1000 + (sec * 1000)).round();
      } else if (parts.length == 2) {
        final m = int.parse(parts[0].trim());
        final sec = double.parse(parts[1].trim());
        return ((m * 60) * 1000 + (sec * 1000)).round();
      }
    } catch (_) {}
    return 0;
  }
}
