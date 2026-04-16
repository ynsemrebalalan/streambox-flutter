import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/models/epg_model.dart';
import '../home_provider.dart';

// EPG current programme provider for a given tvgId
final _epgCurrentProvider =
    FutureProvider.autoDispose.family<EpgProgrammeModel?, String>(
  (ref, tvgId) {
    if (tvgId.isEmpty) return Future.value(null);
    return ref.read(epgRepoProvider).getCurrent(tvgId);
  },
);

class ChannelListItem extends ConsumerStatefulWidget {
  final ChannelModel channel;

  const ChannelListItem({super.key, required this.channel});

  @override
  ConsumerState<ChannelListItem> createState() => _ChannelListItemState();
}

class _ChannelListItemState extends ConsumerState<ChannelListItem> {
  bool _focused = false;

  void _openPlayer() {
    final channel = widget.channel;
    context.push(
      AppRoutes.player,
      extra: {
        'channelId':       channel.id,
        'channelUrl':      channel.streamUrl,
        'title':           channel.name,
        'initialPosition': channel.lastPosition,
        'streamType':      channel.streamType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final channel = widget.channel;

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        // Enter/Select/Space/numpadEnter/gameButtonA → oynat
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          _openPlayer();
          return KeyEventResult.handled;
        }
        // Kumandayla favorileme: Sag ok → favori toggle
        // (Google TV kumandalarinda sag ok yatay scroll yapar,
        //  ama liste tek kolonsa favori icin kullanilabilir)
        if (key == LogicalKeyboardKey.arrowRight) {
          ref.read(homeProvider.notifier).toggleFavorite(channel);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: _openPlayer,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _focused
                ? AppColors.accent.withValues(alpha: 0.18)
                : Colors.transparent,
            // Focus halinde sol kenar belirgin cizgi (TV'de hangi
            // kanal secili oldugunu net gosterir)
            border: _focused
                ? const Border(
                    left: BorderSide(color: AppColors.accent, width: 3))
                : null,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimens.channelItemHPad,
              vertical:   Dimens.channelItemVPad),
          child: Row(
          children: [
            _ChannelLogo(url: channel.logoUrl),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style:     TextStyle(
                        fontSize:   TextSize.channel,
                        fontWeight: _focused
                            ? FontWeight.w700
                            : FontWeight.w500),
                  ),
                  if (channel.streamType == 'live' && channel.tvgId.isNotEmpty)
                    _EpgLine(tvgId: channel.tvgId)
                  else if (channel.category.isNotEmpty)
                    Text(
                      channel.category,
                      style: TextStyle(
                          fontSize: TextSize.caption,
                          color:    cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            // Favori yildizi + focus'taysa ipucu
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_focused)
                  Text('►',
                      style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5))),
                IconButton(
                  iconSize: 26,
                  icon: Icon(
                    channel.isFavorite ? Icons.star : Icons.star_border,
                    color: channel.isFavorite
                        ? AppColors.accent
                        : cs.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      ref.read(homeProvider.notifier).toggleFavorite(channel),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _ChannelLogo extends StatelessWidget {
  final String url;
  const _ChannelLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.channelLogoRadius),
      child: SizedBox(
        width:  Dimens.channelLogoSize,
        height: Dimens.channelLogoSize,
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl:    url,
                fit:         BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: cs.surfaceContainerHighest),
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.live_tv,
                      color: cs.onSurfaceVariant, size: 24),
                ),
              )
            : Container(
                color: cs.surfaceContainerHighest,
                child: Icon(Icons.live_tv,
                    color: cs.onSurfaceVariant, size: 24),
              ),
      ),
    );
  }
}

// ── EPG inline line ───────────────────────────────────────────────────────────

class _EpgLine extends ConsumerWidget {
  final String tvgId;
  const _EpgLine({required this.tvgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs    = Theme.of(context).colorScheme;
    final async = ref.watch(_epgCurrentProvider(tvgId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
      data: (prog) {
        if (prog == null) return const SizedBox.shrink();
        return Row(
          children: [
            Expanded(
              child: Text(
                prog.title,
                maxLines:  1,
                overflow:  TextOverflow.ellipsis,
                style:     TextStyle(
                    fontSize: TextSize.caption,
                    color:    cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                value:            prog.progress,
                backgroundColor:  cs.surfaceContainerHighest,
                color:            AppColors.accent,
                minHeight:        3,
                borderRadius:     BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}
