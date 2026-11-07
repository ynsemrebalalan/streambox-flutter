import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/models/epg_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../data/services/cloud_sync_service.dart';
import '../../billing/widgets/paywall_trigger.dart';
import '../../parental/parental_guard.dart';
import '../home_provider.dart';
import 'series_section.dart';

// EPG current programme provider for a given tvgId
// EPG now/next (Android kanal satırı: şimdiki program + "Sonra: …").
final _epgCurrentProvider = FutureProvider.autoDispose
    .family<({EpgProgrammeModel? now, EpgProgrammeModel? next}), String>(
  (ref, tvgId) => ref.read(epgRepoProvider).getNowNext(tvgId),
);

class ChannelListItem extends ConsumerStatefulWidget {
  final ChannelModel channel;
  /// true ise (arama sonuclari) dizi satiri dizi adini gosterir ve tiklayinca
  /// seri detay sheet'ini acar; bolum dogrudan oynatilmaz.
  final bool openSeriesDetail;

  const ChannelListItem({
    super.key,
    required this.channel,
    this.openSeriesDetail = false,
  });

  @override
  ConsumerState<ChannelListItem> createState() => _ChannelListItemState();
}

class _ChannelListItemState extends ConsumerState<ChannelListItem> {
  bool _focused = false;

  bool get _asSeries =>
      widget.openSeriesDetail &&
      widget.channel.streamType == 'series' &&
      widget.channel.seriesName.isNotEmpty;

  void _openPlayer() {
    if (_asSeries) {
      openSeries(context, ref, widget.channel);
      return;
    }
    openChannelGuarded(context, ref, widget.channel);
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    ref.read(homeProvider.notifier).toggleFavorite(widget.channel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final channel = widget.channel;
    // D-pad / klavye ipucu sadece geleneksel (non-touch) focus modunda.
    final showRemoteHint = _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

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
          _toggleFavorite();
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
                ? cs.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            // Focus halinde sol kenar belirgin cizgi (TV'de hangi
            // kanal secili oldugunu net gosterir)
            border: _focused
                ? Border(left: BorderSide(color: cs.primary, width: 3))
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
                    _asSeries ? channel.seriesName : channel.name,
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: _focused
                            ? FontWeight.w700
                            : FontWeight.w500),
                  ),
                  // v6: Live + EPG → solda EPG / sağda kategori chip.
                  // Diğer durumlarda tek başına chip (kompakt badge).
                  if (channel.streamType == 'live' && channel.tvgId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          if (channel.category.isNotEmpty) ...[
                            _categoryChip(context, channel.category),
                            const SizedBox(width: 6),
                          ],
                          Expanded(child: _EpgLine(tvgId: channel.tvgId)),
                        ],
                      ),
                    )
                  else if (channel.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: _categoryChip(context, channel.category),
                    ),
                ],
              ),
            ),
            // Watchlist (bookmark) + Favori (star) + focus'taysa ipucu.
            // Watchlist sadece movie/series için anlamlı (live "sonra izle"
            // pratik değil); live kanallarda gizlenir.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showRemoteHint)
                  ExcludeSemantics(
                    child: Text('►',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5))),
                  ),
                if (channel.streamType != 'live')
                  _WatchlistButton(channel: channel),
                IconButton(
                  iconSize: 26,
                  tooltip: channel.isFavorite
                      ? l.playerFavoriteRemove
                      : l.playerFavoriteAdd,
                  isSelected: channel.isFavorite,
                  icon: Icon(
                    channel.isFavorite ? Icons.star : Icons.star_border,
                    color: channel.isFavorite
                        ? AppPalette.of(context).accentText
                        : cs.onSurfaceVariant,
                  ),
                  onPressed: _toggleFavorite,
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

/// v6: Kategori chip — secondaryContainer (sessiz lacivert) üzerinde kompakt
/// badge. Channel kart altında tip/kategori göstermek için kullanılır.
Widget _categoryChip(BuildContext context, String category) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: cs.secondaryContainer,
      borderRadius: BorderRadius.circular(AppRadius.xs),
    ),
    child: Text(
      category,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        color: cs.onSecondaryContainer,
        height: 1.1,
      ),
    ),
  );
}

// ── Watchlist toggle ─────────────────────────────────────────────────────────
//
// Watchlist tablosundan polled state. Toggle sonrası UI hızlı feedback
// vermesi için optimistic update yapılır, DB başarısız olursa state geri
// alınır.

class _WatchlistButton extends ConsumerStatefulWidget {
  final ChannelModel channel;
  const _WatchlistButton({required this.channel});

  @override
  ConsumerState<_WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends ConsumerState<_WatchlistButton> {
  bool? _local;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final repo = ref.read(watchlistRepoProvider);
    final v = await repo.isInWatchlist(
        widget.channel.id, widget.channel.playlistId);
    if (mounted) setState(() => _local = v);
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final prev = _local ?? false;
    // Ekleme Pro (Android paritesi); cikarma her zaman serbest.
    if (!prev && !await ensureWatchlistAddAllowed(context, ref)) return;
    if (!mounted) return;
    HapticFeedback.lightImpact();
    final repo = ref.read(watchlistRepoProvider);
    setState(() {
      _local = !prev;
      _busy = true;
    });
    try {
      await repo.toggle(widget.channel);
      // Cloud sync — Pro + auth ise yedeklenir, değilse no-op.
      // ignore: unawaited_futures
      CloudSyncService.pushWatchlist(widget.channel, added: !prev);
    } catch (_) {
      if (mounted) setState(() => _local = prev);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final inList = _local ?? false;
    return IconButton(
      iconSize: 24,
      tooltip: inList ? l.watchlistRemoveTooltip : l.watchlistAddTooltip,
      isSelected: inList,
      icon: Icon(
        inList ? Icons.bookmark : Icons.bookmark_outline,
        color: inList ? AppPalette.of(context).accentText : cs.onSurfaceVariant,
      ),
      onPressed: _toggle,
    );
  }
}

class _ChannelLogo extends StatelessWidget {
  final String url;
  const _ChannelLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final fallback = Container(
      color: cs.surfaceContainerHigh,
      child: Icon(Icons.live_tv, color: cs.onSurfaceVariant, size: 24),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.channelLogoRadius),
      child: SizedBox(
        width:  Dimens.channelLogoSize,
        height: Dimens.channelLogoSize,
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl:       url,
                fit:            BoxFit.cover,
                memCacheWidth:  (Dimens.channelLogoSize * dpr).round(),
                fadeInDuration: const Duration(milliseconds: 180),
                placeholder: (_, __) =>
                    Container(color: cs.surfaceContainerHigh),
                errorWidget: (_, __, ___) => fallback,
              )
            : fallback,
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
      data: (nn) {
        final prog = nn.now;
        final next = nn.next;
        if (prog == null && next == null) return const SizedBox.shrink();
        final style = Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400, color: cs.onSurfaceVariant);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prog != null)
              Row(
                children: [
                  Expanded(
                    child: Text(prog.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      value:            prog.progress,
                      backgroundColor:  cs.surfaceContainerHighest,
                      color:            cs.primary,
                      minHeight:        3,
                      borderRadius:     BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            if (next != null)
              Text(
                AppLocalizations.of(context).epgNextProgram(next.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style?.copyWith(fontSize: 11),
              ),
          ],
        );
      },
    );
  }
}
