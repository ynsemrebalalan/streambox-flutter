import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_tokens.dart';

export 'app_palette.dart';

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
  // Every ColorScheme role is set explicitly. Leaving roles unset makes
  // Flutter fall back to baseline-purple/white defaults (e.g. outlineVariant
  // = white -> glaring dividers, secondaryContainer -> yellow chips).

  static ThemeData get dark => _build(
        scaffold: AppColors.darkBg,
        palette:  AppPalette.dark,
        scheme: const ColorScheme(
          brightness:              Brightness.dark,
          primary:                 AppColors.accent,
          onPrimary:               AppColors.darkBg,
          primaryContainer:        AppColors.darkSurfaceVariant,
          onPrimaryContainer:      AppColors.accent,
          secondary:               Color(0xFFE8A800),
          onSecondary:             AppColors.darkBg,
          secondaryContainer:      Color(0xFF1F3358),
          onSecondaryContainer:    Color(0xFFC9D6EA),
          tertiary:                Color(0xFF7FB3FF),
          onTertiary:              AppColors.darkBg,
          tertiaryContainer:       Color(0xFF1B2D4F),
          onTertiaryContainer:     Color(0xFFC9D6EA),
          error:                   Color(0xFFFF6B6B),
          onError:                 AppColors.darkBg,
          errorContainer:          Color(0xFF4A1F28),
          onErrorContainer:        Color(0xFFFFDAD6),
          surface:                 AppColors.darkSurface,
          onSurface:               Colors.white,
          onSurfaceVariant:        Color(0xFF8FA6C8),
          surfaceDim:              AppColors.darkBg,
          surfaceBright:           Color(0xFF22355A),
          surfaceContainerLowest:  Color(0xFF0A1220),
          surfaceContainerLow:     Color(0xFF101B30),
          surfaceContainer:        AppColors.darkSurface,
          surfaceContainerHigh:    Color(0xFF18284A),
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          outline:                 Color(0xFF2A3D5F),
          outlineVariant:          Color(0xFF22355A),
          shadow:                  Colors.black,
          scrim:                   Colors.black,
          inverseSurface:          Color(0xFFE6ECF5),
          onInverseSurface:        AppColors.darkBg,
          inversePrimary:          Color(0xFF7A5F00),
          surfaceTint:             Colors.transparent,
        ),
      );

  static ThemeData get light => _build(
        scaffold: AppColors.lightBg,
        palette:  AppPalette.light,
        scheme: const ColorScheme(
          brightness:              Brightness.light,
          primary:                 AppColors.darkBg,
          onPrimary:               Colors.white,
          primaryContainer:        Color(0xFFDCE5F3),
          onPrimaryContainer:      AppColors.darkBg,
          secondary:               AppColors.lightOnSurfaceVar,
          onSecondary:             Colors.white,
          secondaryContainer:      Color(0xFFE3EAF6),
          onSecondaryContainer:    Color(0xFF1E3150),
          tertiary:                Color(0xFF1F5FBF),
          onTertiary:              Colors.white,
          tertiaryContainer:       Color(0xFFDCE7FA),
          onTertiaryContainer:     Color(0xFF0B2E66),
          error:                   Color(0xFFC62828),
          onError:                 Colors.white,
          errorContainer:          Color(0xFFFDE7E7),
          onErrorContainer:        Color(0xFF8C1D1D),
          surface:                 AppColors.lightSurface,
          onSurface:               AppColors.darkBg,
          onSurfaceVariant:        AppColors.lightOnSurfaceVar,
          surfaceDim:              Color(0xFFDFE6F2),
          surfaceBright:           Colors.white,
          surfaceContainerLowest:  Colors.white,
          surfaceContainerLow:     Color(0xFFF8FAFD),
          surfaceContainer:        AppColors.lightSurface,
          surfaceContainerHigh:    AppColors.lightSurfaceVariant,
          surfaceContainerHighest: Color(0xFFDFE6F2),
          outline:                 Color(0xFF7D8FAB),
          outlineVariant:          Color(0xFFD5DEEC),
          shadow:                  Colors.black,
          scrim:                   Colors.black,
          inverseSurface:          AppColors.darkSurface,
          onInverseSurface:        AppColors.lightSurface,
          inversePrimary:          AppColors.accent,
          surfaceTint:             Colors.transparent,
        ),
      );

  // ── Premium variants ───────────────────────────────────────────────────────
  // onPrimary/onSecondary picked per hue for >= 4.5:1 (see design audit).

  static ThemeData get crimson => _premiumDark(
        primary:     const Color(0xFFC93B3B), // white 5.03:1
        onPrimary:   Colors.white,
        accentText:  const Color(0xFFF07575), // 6.7:1 on bg
        secondary:   const Color(0xFFE8B956),
        onSecondary: AppColors.darkBg,
        bg:          const Color(0xFF1A0E0E),
        surface:     const Color(0xFF2A1818),
      );

  static ThemeData get royal => _premiumDark(
        primary:     const Color(0xFF7C4DEB), // white 5.10:1
        onPrimary:   Colors.white,
        accentText:  const Color(0xFFA78BFA), // 6.96:1 on bg
        secondary:   const Color(0xFFC0C5CE),
        onSecondary: AppColors.darkBg,        // 10.5:1 (white was 1.73)
        bg:          const Color(0xFF120D24),
        surface:     const Color(0xFF1F1838),
      );

  static ThemeData get forest => _premiumDark(
        primary:     const Color(0xFF4ADE80),
        onPrimary:   AppColors.darkBg,        // 10.5:1 (white was 1.74)
        accentText:  const Color(0xFF4ADE80),
        secondary:   const Color(0xFFB45309),
        onSecondary: Colors.white,
        bg:          const Color(0xFF0E1A14),
        surface:     const Color(0xFF182A22),
      );

  static ThemeData get ocean => _premiumDark(
        primary:     const Color(0xFF38BDF8),
        onPrimary:   AppColors.darkBg,        // 8.5:1 (white was 2.14)
        accentText:  const Color(0xFF38BDF8),
        secondary:   const Color(0xFF14B8A6),
        onSecondary: AppColors.darkBg,        // 7.3:1 (white was 2.49)
        bg:          const Color(0xFF0B1A26),
        surface:     const Color(0xFF132B40),
      );

  static ThemeData _premiumDark({
    required Color primary,
    required Color onPrimary,
    required Color accentText,
    required Color secondary,
    required Color onSecondary,
    required Color bg,
    required Color surface,
  }) {
    Color tint(double t) => Color.lerp(surface, Colors.white, t)!;
    final high    = tint(0.05);
    final highest = tint(0.08);
    final scheme = ColorScheme(
      brightness:              Brightness.dark,
      primary:                 primary,
      onPrimary:               onPrimary,
      primaryContainer:        Color.lerp(surface, primary, 0.25)!,
      onPrimaryContainer:      Colors.white,
      secondary:               secondary,
      onSecondary:             onSecondary,
      secondaryContainer:      Color.lerp(surface, primary, 0.18)!,
      onSecondaryContainer:    Color.lerp(Colors.white, primary, 0.15)!,
      tertiary:                accentText,
      onTertiary:              AppColors.darkBg,
      tertiaryContainer:       highest,
      onTertiaryContainer:     Colors.white,
      error:                   const Color(0xFFFF6B6B),
      onError:                 AppColors.darkBg,
      errorContainer:          const Color(0xFF4A1F28),
      onErrorContainer:        const Color(0xFFFFDAD6),
      surface:                 surface,
      onSurface:               Colors.white,
      onSurfaceVariant:        Color.lerp(Colors.white, surface, 0.32)!,
      surfaceDim:              bg,
      surfaceBright:           tint(0.12),
      surfaceContainerLowest:  Color.lerp(bg, Colors.black, 0.2)!,
      surfaceContainerLow:     Color.lerp(bg, surface, 0.5)!,
      surfaceContainer:        surface,
      surfaceContainerHigh:    high,
      surfaceContainerHighest: highest,
      outline:                 tint(0.16),
      outlineVariant:          tint(0.10),
      shadow:                  Colors.black,
      scrim:                   Colors.black,
      inverseSurface:          const Color(0xFFECEFF4),
      onInverseSurface:        bg,
      inversePrimary:          Color.lerp(primary, Colors.black, 0.4)!,
      surfaceTint:             Colors.transparent,
    );
    return _build(
      scheme:   scheme,
      scaffold: bg,
      palette:  AppPalette.dark.copyWith(
        accentText:        accentText,
        proBadgeBg:        primary,
        proBadgeFg:        onPrimary,
        posterPlaceholder: high,
      ),
    );
  }

  // ── Shared component theming ───────────────────────────────────────────────

  /// iOS-like type ramp. Sizes in logical px (≈ pt). Nothing below 11.
  static const TextTheme _textTheme = TextTheme(
    displaySmall:   TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
    headlineSmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
    titleLarge:     TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25),
    titleMedium:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
    titleSmall:     TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
    bodyLarge:      TextStyle(fontSize: 17, fontWeight: FontWeight.w400, height: 1.35),
    bodyMedium:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.35),
    bodySmall:      TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.35),
    labelLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
    labelMedium:    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3),
    labelSmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.4),
  );

  static bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffold,
    required AppPalette palette,
  }) {
    final ios = _isCupertino;
    return ThemeData(
      useMaterial3:            true,
      colorScheme:             scheme,
      scaffoldBackgroundColor: scaffold,
      canvasColor:             scaffold,
      textTheme:               _textTheme,
      extensions:              <ThemeExtension<dynamic>>[palette],
      splashFactory:           ios ? NoSplash.splashFactory : null,
      highlightColor:          ios ? scheme.onSurface.withValues(alpha: 0.08) : null,
      appBarTheme: AppBarTheme(
        backgroundColor:        scaffold,
        surfaceTintColor:       Colors.transparent,
        scrolledUnderElevation: 0,
        elevation:              0,
      ),
      cardTheme: CardThemeData(
        elevation:        AppElevation.card,
        color:            scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin:           EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        space:     1,
        color:     scheme.outlineVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor:   scheme.secondaryContainer,
        side:            BorderSide(color: scheme.outlineVariant, width: 0.5),
        labelStyle:      _textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle:   true,
        backgroundColor:  scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        dragHandleColor:  scheme.onSurfaceVariant.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:  scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
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
