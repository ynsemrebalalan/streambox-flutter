import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'poster_grid.dart';

/// Pulses its whole subtree between 50% and 100% opacity (1.2 s period).
///
/// Wrap a group of [SkeletonBox]es in ONE [SkeletonPulse] so they share a
/// single ticker and pulse in sync. Honours "reduce motion"
/// (`MediaQuery.disableAnimations`) by rendering static.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    lowerBound: 0.5,
    upperBound: 1.0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: FadeTransition(opacity: _ctrl, child: widget.child),
      );
}

/// Static placeholder block. Put inside a [SkeletonPulse].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadius.xs,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Skeleton of a channel row: 48×48 logo (r10) + two text lines.
class ChannelRowSkeleton extends StatelessWidget {
  const ChannelRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.channelItemHPad,
          vertical: Dimens.channelItemVPad,
        ),
        child: Row(
          children: [
            SkeletonBox(
              width: Dimens.channelLogoSize,
              height: Dimens.channelLogoSize,
              radius: AppRadius.sm,
            ),
            SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: SkeletonBox(height: 14),
                  ),
                  SizedBox(height: Spacing.sm),
                  FractionallySizedBox(
                    widthFactor: 0.35,
                    child: SkeletonBox(height: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Skeleton of a poster tile: 2:3 image (r12) + caption line.
class PosterSkeleton extends StatelessWidget {
  const PosterSkeleton({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: Dimens.posterAspect,
              child: SkeletonBox(radius: AppRadius.card),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: Spacing.sm, right: Spacing.lg),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SkeletonBox(height: 11),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Full-screen channel list skeleton (non-scrollable, fills the viewport).
class ChannelListSkeleton extends StatelessWidget {
  const ChannelListSkeleton({super.key, this.rows = 10});

  final int rows;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows,
          itemBuilder: (_, __) => const ChannelRowSkeleton(),
        ),
      );
}

/// Poster grid skeleton matching the real poster grid geometry.
class PosterGridSkeleton extends StatelessWidget {
  const PosterGridSkeleton({super.key, this.count = 12});

  final int count;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: PosterGridView(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (_, __) => const PosterSkeleton(),
        ),
      );
}
