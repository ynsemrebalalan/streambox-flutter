import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// Deterministic two-tone gradient + faint movie icon. Same title -> same
/// colours, so a grid of missing posters doesn't look like one grey slab.
class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    super.key,
    required this.seed,
    this.icon = Icons.movie_outlined,
  });

  final String seed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = AppPalette.of(context).posterPlaceholder;
    final hue = (seed.hashCode.abs() % 360).toDouble();
    final tint = HSLColor.fromAHSL(1, hue, 0.45,
            Theme.of(context).brightness == Brightness.dark ? 0.32 : 0.78)
        .toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(base, tint, 0.55)!, base],
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (_, c) => Icon(
            icon,
            size: (c.biggest.shortestSide * 0.36).clamp(16.0, 56.0),
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

/// Network poster: fills its parent, fades in over 180 ms, decodes at the
/// displayed size (memCacheWidth) and shows [PosterPlaceholder] while loading
/// or on error.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    required this.seed,
    this.width,
    this.fit = BoxFit.cover,
    this.httpHeaders,
  });

  final String? url;
  final String seed;
  /// Logical display width; used to size the decode cache.
  final double? width;
  final BoxFit fit;
  final Map<String, String>? httpHeaders;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return PosterPlaceholder(seed: seed);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = width ?? Dimens.posterWTablet;
    return CachedNetworkImage(
      imageUrl: u,
      httpHeaders: httpHeaders,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: (w * dpr).round(),
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => PosterPlaceholder(seed: seed),
      errorWidget: (_, __, ___) => PosterPlaceholder(seed: seed),
    );
  }
}

/// Fixed-height caption under a poster: max 2 lines, label size.
class PosterCaption extends StatelessWidget {
  const PosterCaption(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: Dimens.posterCaptionHFor(scale),
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.xs + 2),
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
