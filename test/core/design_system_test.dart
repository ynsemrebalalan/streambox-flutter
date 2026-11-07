import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/theme/app_theme.dart';
import 'package:iptv_ai_player/core/theme/app_tokens.dart';
import 'package:iptv_ai_player/core/widgets/empty_state.dart';
import 'package:iptv_ai_player/core/widgets/poster_grid.dart';
import 'package:iptv_ai_player/core/widgets/skeleton.dart';
import 'package:iptv_ai_player/features/player/widgets/player_overlays.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

final _themes = <String, ThemeData>{
  'dark': AppTheme.dark,
  'light': AppTheme.light,
  'crimson': AppTheme.crimson,
  'royal': AppTheme.royal,
  'forest': AppTheme.forest,
  'ocean': AppTheme.ocean,
};

void main() {
  group('AppTheme color roles', () {
    for (final MapEntry(key: name, value: theme) in _themes.entries) {
      final cs = theme.colorScheme;

      test('$name: on-colours meet WCAG AA (4.5:1)', () {
        expect(_contrast(cs.onPrimary, cs.primary), greaterThanOrEqualTo(4.5));
        expect(_contrast(cs.onSecondary, cs.secondary),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(cs.onSecondaryContainer, cs.secondaryContainer),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(cs.onSurface, cs.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(cs.onSurfaceVariant, cs.surface),
            greaterThanOrEqualTo(4.5));
      });

      test('$name: no Material baseline fallbacks leak through', () {
        // Unset roles used to resolve to white dividers / yellow chips.
        expect(cs.outlineVariant, isNot(Colors.white));
        expect(cs.secondaryContainer, isNot(const Color(0xFFE8A800)));
        expect(cs.surfaceTint, Colors.transparent);
      });

      test('$name: registers AppPalette with readable accent text', () {
        final palette = theme.extension<AppPalette>();
        expect(palette, isNotNull);
        expect(_contrast(palette!.accentText, theme.scaffoldBackgroundColor),
            greaterThanOrEqualTo(4.5));
        expect(_contrast(palette.proBadgeFg, palette.proBadgeBg),
            greaterThanOrEqualTo(4.5));
      });

      test('$name: type ramp has nothing below 11pt', () {
        final t = theme.textTheme;
        for (final style in [
          t.labelSmall, t.labelMedium, t.bodySmall, t.bodyMedium,
          t.titleSmall, t.titleMedium, t.titleLarge,
        ]) {
          expect(style?.fontSize, greaterThanOrEqualTo(11));
        }
        expect(t.bodyMedium?.fontSize, 16);
        expect(t.titleMedium?.fontSize, 17);
      });
    }
  });

  group('posterGridDelegate', () {
    test('tile height = 2:3 image + fixed caption', () {
      final d = posterGridDelegate(360)
          as SliverGridDelegateWithFixedCrossAxisCount;
      // 360 wide, max tile 140 + 8 spacing -> 3 columns.
      expect(d.crossAxisCount, 3);
      final tileW = (360 - Spacing.sm * 2) / 3;
      expect(d.mainAxisExtent, closeTo(tileW * 1.5 + Dimens.posterCaptionH, 0.01));
    });

    test('caption grows with text scale (capped at 1.3)', () {
      final a = posterGridDelegate(360, textScale: 1.3)
          as SliverGridDelegateWithFixedCrossAxisCount;
      final b = posterGridDelegate(360, textScale: 2.0)
          as SliverGridDelegateWithFixedCrossAxisCount;
      expect(a.mainAxisExtent, b.mainAxisExtent);
    });
  });

  group('EmptyState', () {
    testWidgets('shows title, message and fires the action', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'Nothing here',
            message: 'Add something',
            actionLabel: 'Add',
            onAction: () => tapped++,
          ),
        ),
      ));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add something'), findsOneWidget);
      await tester.tap(find.text('Add'));
      expect(tapped, 1);
    });

    testWidgets('error variant tints the icon with colorScheme.error',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: EmptyState.error(title: 'Failed')),
      ));
      final icon = tester.widget<Icon>(find.byType(Icon).first);
      expect(icon.color, AppTheme.light.colorScheme.error);
    });
  });

  group('SkeletonPulse', () {
    testWidgets('is static when the OS asks to reduce motion', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SkeletonPulse(child: SkeletonBox(width: 10, height: 10)),
        ),
      ));
      // No ticking animation -> settles immediately.
      await tester.pumpAndSettle();
      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, 1.0);
    });
  });

  group('ActionFeedbackOverlay', () {
    Future<Alignment> alignmentFor(WidgetTester tester, bool controls) async {
      await tester.pumpWidget(MaterialApp(
        home: Stack(children: [
          ActionFeedbackOverlay(
            icon: Icons.pause,
            text: 'Paused',
            controlsVisible: controls,
          ),
        ]),
      ));
      return tester
          .widget<AnimatedAlign>(find.byType(AnimatedAlign))
          .alignment as Alignment;
    }

    testWidgets('moves above the play button while controls are visible',
        (tester) async {
      expect(await alignmentFor(tester, true), const Alignment(0, -0.6));
    });

    testWidgets('stays centred when controls are hidden', (tester) async {
      expect(await alignmentFor(tester, false), Alignment.center);
    });
  });
}
