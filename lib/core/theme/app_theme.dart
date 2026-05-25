import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tek source-of-truth tema secimi. Sistem/Aydinlik/Karanlik varsayilanlar
/// herkese acik; 4 premium variant Pro entitlement gerektirir. Eski
/// ayri `themeMode` ayari kaldirildi — bu enum hem moda hem variant'a
/// karar verir.
enum PremiumTheme {
  defaultSystem,  // Cihaz sistem ayarini takip et
  defaultLight,
  defaultDark,
  crimson,    // Pro — koyu kırmızı + altın aksent
  royal,      // Pro — kraliyet moru + gümüş
  forest,     // Pro — koyu yeşil + bakır
  ocean;      // Pro — okyanus mavisi + turkuaz

  bool get isPro => switch (this) {
    defaultSystem || defaultDark || defaultLight => false,
    _ => true,
  };

  static PremiumTheme fromKey(String? key) => switch (key) {
    'crimson' => PremiumTheme.crimson,
    'royal'   => PremiumTheme.royal,
    'forest'  => PremiumTheme.forest,
    'ocean'   => PremiumTheme.ocean,
    'light'   => PremiumTheme.defaultLight,
    'system'  => PremiumTheme.defaultSystem,
    _         => PremiumTheme.defaultDark,
  };

  String get key => switch (this) {
    PremiumTheme.defaultSystem => 'system',
    PremiumTheme.defaultDark   => 'default',
    PremiumTheme.defaultLight  => 'light',
    PremiumTheme.crimson       => 'crimson',
    PremiumTheme.royal         => 'royal',
    PremiumTheme.forest        => 'forest',
    PremiumTheme.ocean         => 'ocean',
  };
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary:                    AppColors.accent,
          onPrimary:                  AppColors.darkBg,
          primaryContainer:           AppColors.darkSurfaceVariant,
          secondary:                  Color(0xFFE8A800),
          onSecondary:                AppColors.darkBg,
          surface:                    AppColors.darkSurface,
          surfaceContainerHighest:    AppColors.darkSurfaceVariant,
          onSurface:                  Colors.white,
          onSurfaceVariant:           AppColors.darkOnSurfaceVar,
          outline:                    AppColors.darkSurfaceVariant,
          error:                      Color(0xFFFF6B6B),
        ),
        scaffoldBackgroundColor: AppColors.darkBg,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary:                    AppColors.darkBg,
          onPrimary:                  Colors.white,
          primaryContainer:           AppColors.darkSurfaceVariant,
          onPrimaryContainer:         Colors.white,
          secondary:                  Color(0xFF3A506B),
          onSecondary:                Colors.white,
          surface:                    AppColors.lightSurface,
          surfaceContainerHighest:    AppColors.lightSurfaceVariant,
          onSurface:                  AppColors.darkBg,
          onSurfaceVariant:           AppColors.lightOnSurfaceVar,
          outline:                    AppColors.lightOutline,
          error:                      AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.lightBg,
      );

  // ── Premium variants ───────────────────────────────────────────────────────

  static ThemeData get crimson => _premiumDark(
        primary: const Color(0xFFD64545),
        secondary: const Color(0xFFE8B956),
        bg: const Color(0xFF1A0E0E),
        surface: const Color(0xFF2A1818),
      );

  static ThemeData get royal => _premiumDark(
        primary: const Color(0xFF8B5CF6),
        secondary: const Color(0xFFC0C5CE),
        bg: const Color(0xFF120D24),
        surface: const Color(0xFF1F1838),
      );

  static ThemeData get forest => _premiumDark(
        primary: const Color(0xFF4ADE80),
        secondary: const Color(0xFFB45309),
        bg: const Color(0xFF0E1A14),
        surface: const Color(0xFF182A22),
      );

  static ThemeData get ocean => _premiumDark(
        primary: const Color(0xFF38BDF8),
        secondary: const Color(0xFF14B8A6),
        bg: const Color(0xFF0B1A26),
        surface: const Color(0xFF132B40),
      );

  static ThemeData _premiumDark({
    required Color primary,
    required Color secondary,
    required Color bg,
    required Color surface,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary:                    primary,
        onPrimary:                  Colors.white,
        primaryContainer:           surface,
        secondary:                  secondary,
        onSecondary:                Colors.white,
        surface:                    surface,
        surfaceContainerHighest:    Color.lerp(surface, Colors.white, 0.06)!,
        onSurface:                  Colors.white,
        onSurfaceVariant:           Colors.white70,
        outline:                    Color.lerp(surface, Colors.white, 0.10)!,
        error:                      const Color(0xFFFF6B6B),
      ),
      scaffoldBackgroundColor: bg,
    );
  }

  /// PremiumTheme enum → ThemeData. UI doğrudan bunu çağırır.
  /// `defaultSystem` mod-aware oldugu icin burada `dark`'a dusurulur — gercek
  /// secim main.dart `MaterialApp.themeMode` ile yapilir.
  static ThemeData of(PremiumTheme variant) => switch (variant) {
    PremiumTheme.defaultSystem => dark,
    PremiumTheme.defaultDark   => dark,
    PremiumTheme.defaultLight  => light,
    PremiumTheme.crimson       => crimson,
    PremiumTheme.royal         => royal,
    PremiumTheme.forest        => forest,
    PremiumTheme.ocean         => ocean,
  };
}
