import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Shared poster grid geometry: column count from a max tile width of 140
/// (same rule as `SliverGridDelegateWithMaxCrossAxisExtent`) and a row height
/// of image (2:3) + fixed caption, so every poster grid in the app lines up.
SliverGridDelegate posterGridDelegate(
  double availableWidth, {
  double textScale = 1.0,
}) {
  const spacing = Spacing.sm;
  final columns =
      ((availableWidth + spacing) / (Dimens.posterGridMaxW + spacing))
          .ceil()
          .clamp(2, 12);
  final tileW = (availableWidth - spacing * (columns - 1)) / columns;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: spacing,
    mainAxisSpacing: Spacing.md,
    mainAxisExtent: Dimens.posterTileHeight(tileW, textScale: textScale),
  );
}

/// Lazily built poster grid using [posterGridDelegate].
class PosterGridView extends StatelessWidget {
  const PosterGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics? physics;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    Spacing.lg, Spacing.md, Spacing.lg, Spacing.lg,
  );

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) => GridView.builder(
        physics: physics,
        padding: padding,
        gridDelegate: posterGridDelegate(
          c.maxWidth - padding.horizontal,
          textScale: scale,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
