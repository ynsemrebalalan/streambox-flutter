import 'package:flutter/widgets.dart';

/// Responsive breakpoints for phone / tablet (iPad) / large tablet.
abstract final class Responsive {
  /// Compact: phones (< 600dp)
  static const double compactBreakpoint = 600;

  /// Medium: small tablets, iPad portrait (600–840dp)
  static const double mediumBreakpoint = 840;

  /// Expanded: large tablets, iPad landscape (> 840dp)

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= compactBreakpoint;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mediumBreakpoint;

  /// Movie/poster grid column count based on available width.
  static int posterGridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 6;
    if (w >= mediumBreakpoint) return 5;
    if (w >= compactBreakpoint) return 4;
    return 3;
  }

  /// Max content width for form-like screens (settings, playlists).
  /// On phones returns full width; on tablets constrains to 600dp.
  static double formMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= mediumBreakpoint) return 680;
    if (w >= compactBreakpoint) return 600;
    return w;
  }
}

/// Centers content with a max width constraint on tablets.
/// On phones, renders child full-width.
class ResponsiveCenter extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const ResponsiveCenter({
    super.key,
    required this.maxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
