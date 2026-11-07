import 'package:flutter/material.dart';

/// Brand / status colours that don't map 1:1 to a Material [ColorScheme] role.
///
/// Read with `AppPalette.of(context)`. Every [ThemeData] built by `AppTheme`
/// registers one; [of] falls back to [dark] so widgets in tests without the
/// app theme still render.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.accentText,
    required this.live,
    required this.onLive,
    required this.success,
    required this.proBadgeBg,
    required this.proBadgeFg,
    required this.scrimTop,
    required this.scrimBottom,
    required this.posterPlaceholder,
  });

  /// Brand accent used as *text/icon* on the surface (AA on surface/bg).
  final Color accentText;
  /// LIVE badge background.
  final Color live;
  final Color onLive;
  final Color success;
  /// "PRO" / featured badge.
  final Color proBadgeBg;
  final Color proBadgeFg;
  /// Image scrims (top / bottom of posters, player overlay).
  final Color scrimTop;
  final Color scrimBottom;
  /// Poster / logo placeholder fill.
  final Color posterPlaceholder;

  static const dark = AppPalette(
    accentText:        Color(0xFFF5C518), // 9.6:1 on #142038
    live:              Color(0xFFD32F2F), // white text 4.98:1
    onLive:            Colors.white,
    success:           Color(0xFF4CAF50), // 5.84:1 on #142038
    proBadgeBg:        Color(0xFFF5C518),
    proBadgeFg:        Color(0xFF0C1526), // 11.2:1
    scrimTop:          Color(0xB3000000),
    scrimBottom:       Color(0xD9000000),
    posterPlaceholder: Color(0xFF18284A),
  );

  static const light = AppPalette(
    accentText:        Color(0xFF7A5F00), // 6.06:1 on white (gold was 1.63)
    live:              Color(0xFFD32F2F),
    onLive:            Colors.white,
    success:           Color(0xFF2E7D32), // 5.13:1 on white
    proBadgeBg:        Color(0xFFF5C518),
    proBadgeFg:        Color(0xFF0C1526),
    scrimTop:          Color(0xB3000000),
    scrimBottom:       Color(0xD9000000),
    posterPlaceholder: Color(0xFFE8EDF7),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? accentText,
    Color? live,
    Color? onLive,
    Color? success,
    Color? proBadgeBg,
    Color? proBadgeFg,
    Color? scrimTop,
    Color? scrimBottom,
    Color? posterPlaceholder,
  }) =>
      AppPalette(
        accentText:        accentText ?? this.accentText,
        live:              live ?? this.live,
        onLive:            onLive ?? this.onLive,
        success:           success ?? this.success,
        proBadgeBg:        proBadgeBg ?? this.proBadgeBg,
        proBadgeFg:        proBadgeFg ?? this.proBadgeFg,
        scrimTop:          scrimTop ?? this.scrimTop,
        scrimBottom:       scrimBottom ?? this.scrimBottom,
        posterPlaceholder: posterPlaceholder ?? this.posterPlaceholder,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      accentText:        l(accentText, other.accentText),
      live:              l(live, other.live),
      onLive:            l(onLive, other.onLive),
      success:           l(success, other.success),
      proBadgeBg:        l(proBadgeBg, other.proBadgeBg),
      proBadgeFg:        l(proBadgeFg, other.proBadgeFg),
      scrimTop:          l(scrimTop, other.scrimTop),
      scrimBottom:       l(scrimBottom, other.scrimBottom),
      posterPlaceholder: l(posterPlaceholder, other.posterPlaceholder),
    );
  }
}
