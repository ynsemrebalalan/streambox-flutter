import 'package:flutter/painting.dart';

/// Ayarlar > Altyazı'da kaydedilen stil (settings tablosu string değerleri)
/// → hem AI altyazı overlay'i hem gömülü altyazı (media_kit SubtitleView)
/// için kullanılan çözümlenmiş stil.
///
/// Not: media_kit `libass: false` (varsayılan) ile gömülü altyazıyı mpv
/// texture'a değil Flutter `SubtitleView`'a çizer; bu yüzden mpv
/// `sub-font-size/sub-color` yerine `SubtitleViewConfiguration` uygulanır.
class SubtitleStyleSettings {
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;

  const SubtitleStyleSettings({
    this.fontSize = 16,
    this.textColor = const Color(0xFFFFFFFF),
    this.backgroundColor = const Color(0xAA000000),
  });

  static const Map<String, Color> textColors = {
    'white': Color(0xFFFFFFFF),
    'yellow': Color(0xFFFFEB3B),
    'green': Color(0xFF69F0AE),
    'cyan': Color(0xFF18FFFF),
  };

  static const Map<String, Color> bgColors = {
    'semi': Color(0xAA000000),
    'opaque': Color(0xFF000000),
    'none': Color(0x00000000),
  };

  factory SubtitleStyleSettings.fromRaw({
    String? fontSize,
    String? textColor,
    String? bgColor,
  }) {
    final size = double.tryParse(fontSize ?? '') ?? 16;
    return SubtitleStyleSettings(
      fontSize: size.clamp(10, 40).toDouble(),
      textColor: textColors[textColor] ?? textColors['white']!,
      backgroundColor: bgColors[bgColor] ?? bgColors['semi']!,
    );
  }
}
