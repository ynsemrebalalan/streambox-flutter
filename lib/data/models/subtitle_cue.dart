/// Tek bir altyazi satirini temsil eder (baslangic → bitis + metin).
class SubtitleCue {
  final int startMs;
  final int endMs;
  final String text;

  const SubtitleCue({
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        's': startMs,
        'e': endMs,
        't': text,
      };

  factory SubtitleCue.fromJson(Map<String, dynamic> json) => SubtitleCue(
        startMs: json['s'] as int,
        endMs: json['e'] as int,
        text: json['t'] as String,
      );

  /// Bu cue verilen pozisyonda aktif mi?
  bool isActive(int positionMs) => positionMs >= startMs && positionMs <= endMs;
}
