/// Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 48.
abstract final class Spacing {
  static const double xs   =  4;
  static const double sm   =  8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double lgx  = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

/// Corner radius scale. Named `AppRadius` (not `Radius`) so it doesn't shadow
/// `dart:ui`'s `Radius` class.
abstract final class AppRadius {
  static const double xs   =   6;
  static const double sm   =  10;
  static const double md   =  14;
  static const double lg   =  20;
  static const double pill = 999;

  // Semantic aliases (kept so call sites read by intent).
  static const double badge  =  4;
  static const double input  =  8;
  static const double cardSm = sm;
  static const double card   = 12;
  static const double cardLg = md;
  static const double dialog = lg;
}

abstract final class AppElevation {
  static const double card        = 0;
  static const double cardFocused = 8;
  static const double bar         = 4;
  static const double dialog      = 16;
}

/// Legacy ad-hoc sizes. Prefer `Theme.of(context).textTheme` roles; kept for
/// call sites that still need a raw size. Nothing goes below 11pt.
abstract final class TextSize {
  static const double micro   = 11;
  static const double caption = 11;
  static const double label   = 12;
  static const double body    = 13;
  static const double bodyLg  = 14;
  static const double channel = 15;
  static const double titleSm = 16;
  static const double title   = 17;
  static const double titleLg = 20;
}

abstract final class Dimens {
  static const double topBarHeight    = 60;
  static const double bottomBarHeight = 60;

  static const double channelLogoSize    = 48;
  static const double channelLogoRadius  = AppRadius.sm;
  static const double channelItemHPad    = Spacing.lg;
  static const double channelItemVPad    = 10;
  static const double channelItemVPadEpg =  7;
  static const double focusBorderWidth   =  3;

  static const double categoryCardMinHeight = 80;
  static const double categoryAvatarSize    = 40;

  static const double buttonHeight   = 50;
  static const double buttonHeightSm = 44;
  static const double iconTouchTarget = 48;

  static const double dialogMaxHeightFraction = 0.88;

  // ── Posters (VOD / series) ────────────────────────────────────────────────
  /// Poster image aspect (width / height).
  static const double posterAspect      = 2 / 3;
  /// Fixed caption block under every poster (title, max 2 lines at 12pt).
  static const double posterCaptionH    = 36;
  /// Poster width in horizontal strips (phone).
  static const double posterW           = 112;
  /// Poster width in horizontal strips (tablet / TV, shortestSide >= 600).
  static const double posterWTablet     = 140;
  /// Grid max tile width — grid column count derives from this.
  static const double posterGridMaxW    = 140;

  /// EPG guide channel column width (tablet / TV).
  static const double epgChannelColTablet = 160;

  /// Poster width for the current layout.
  static double posterWidthFor(double shortestSide) =>
      shortestSide >= 600 ? posterWTablet : posterW;

  /// Caption height grown with Dynamic Type (text scale is clamped to 1.3
  /// app-wide, so this tops out at ~47).
  static double posterCaptionHFor(double textScale) =>
      posterCaptionH * textScale.clamp(1.0, 1.3);

  /// Total tile height (image 2:3 + caption) for a poster of [width].
  static double posterTileHeight(double width, {double textScale = 1.0}) =>
      width / posterAspect + posterCaptionHFor(textScale);
}
