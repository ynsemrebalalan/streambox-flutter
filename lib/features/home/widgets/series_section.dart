import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/tv_focus.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/poster_grid.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/services/xtream_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../parental/parental_guard.dart';
import '../home_provider.dart';

/// Diziler tab'i — Kotlin paritesi (VodSeriesPosterGrid):
/// Ust seviye poster grid (her dizi tek kart). Karta tiklayinca alttan
/// bottom-sheet acilir; sezon chip'leri + bolum listesi orada.
///
/// 2026-05-25: Eskiden tum diziler dikey list halinde expand edilen Card'lar
/// olarak gosteriliyordu — film tab'i poster grid kullanirken dizi tab'i
/// farkli gorunum sergiliyordu (kullanici raporu).
class SeriesSection extends StatefulWidget {
  final List<ChannelModel> channels;

  const SeriesSection({super.key, required this.channels});

  @override
  State<SeriesSection> createState() => _SeriesSectionState();
}

class _SeriesSectionState extends State<SeriesSection> {
  // Gruplama her build'de degil, yalniz liste degisince yapilir (10k+ bolum).
  late Map<String, Map<int, List<ChannelModel>>> _groups =
      groupSeriesEpisodes(widget.channels);

  @override
  void didUpdateWidget(covariant SeriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.channels, widget.channels)) {
      _groups = groupSeriesEpisodes(widget.channels);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    if (groups.isEmpty) {
      final l = AppLocalizations.of(context);
      return EmptyState(
        icon:  Icons.video_library_outlined,
        title: l.seriesEmptyCategory,
      );
    }

    final entries = groups.entries.toList();

    return PosterGridView(
      itemCount:   entries.length,
      itemBuilder: (ctx, i) {
        final entry = entries[i];
        return _SeriesPosterCard(
          seriesName: entry.key,
          seasons:    entry.value,
        );
      },
    );
  }
}

/// Bolumleri dizi adi → sezon → bolum listesi olarak gruplar.
/// Sezon icinde siralama **sortOrder**: provider sirasi tek guvenilir izleme
/// sirasidir (bkz. ChannelRepository._orderFor v3.8.2 notu — title'dan
/// parse edilen episodeNumber yaniltici olabiliyor).
Map<String, Map<int, List<ChannelModel>>> groupSeriesEpisodes(
    List<ChannelModel> channels) {
  final result = <String, Map<int, List<ChannelModel>>>{};
  for (final ch in channels) {
    final key = ch.seriesName.isNotEmpty ? ch.seriesName : ch.name;
    result
        .putIfAbsent(key, () => <int, List<ChannelModel>>{})
        .putIfAbsent(ch.seasonNumber, () => <ChannelModel>[])
        .add(ch);
  }
  // Xtream container'ı, dizinin gerçek bölümleri varken "Özel" sezonu gibi
  // görünmesin — yalnız bölümsüz dizide (lazy) yer tutucu olarak kalır.
  for (final seasons in result.values) {
    final zero = seasons[0];
    if (zero == null || seasons.length == 1) continue;
    zero.removeWhere((c) => c.isSeriesContainer);
    if (zero.isEmpty) seasons.remove(0);
  }
  for (final seasons in result.values) {
    for (final eps in seasons.values) {
      eps.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
  }
  return result;
}

/// Dizi kartindan (Ana Sayfa, Yeni Diziler, arama) seri detay sheet'ini acar.
/// Bolumler DB'den seriesName + playlistId ile yuklenir — kartin temsil
/// ettigi rastgele bolum degil, dizinin tamami gosterilir. Dizi degilse
/// (veya seriesName bos) dogrudan oynatir.
Future<void> openSeries(
  BuildContext context,
  WidgetRef ref,
  ChannelModel channel,
) async {
  if (channel.streamType != 'series' || channel.seriesName.isEmpty) {
    return openChannelGuarded(context, ref, channel);
  }
  if (!await ensureCategoryUnlocked(context, ref, channel.category)) return;
  final repo = ref.read(channelRepoProvider);
  var episodes =
      await repo.getSeriesEpisodes(channel.playlistId, channel.seriesName);
  // Xtream: bölümler lazy — container varsa get_series_info ile çek
  // (Android XtreamLoader.loadSeriesEpisodes). Eski bölümler varsa hata
  // durumunda onlar gösterilir.
  final container = episodes.where((e) => e.isSeriesContainer).firstOrNull;
  if (container != null && context.mounted) {
    final l = AppLocalizations.of(context);
    String? error;
    final loaded = await _withProgress(context, () async {
      try {
        final p = await ref.read(playlistRepoProvider).getById(container.playlistId);
        if (p == null) return 0;
        return await XtreamService.loadSeriesContainer(p, container, repo);
      } catch (_) {
        error = l.loadErrSeriesInfo;
        return 0;
      }
    });
    if (loaded > 0) {
      episodes =
          await repo.getSeriesEpisodes(channel.playlistId, channel.seriesName);
      // Diziler sekmesindeki container kartı gerçek bölümlerle değişsin.
      unawaited(ref.read(homeProvider.notifier).reloadPreservingSelection());
    }
    final real = episodes.where((e) => !e.isSeriesContainer).toList();
    if (real.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? l.loadErrNoEpisodes)));
      }
      return;
    }
    episodes = real;
  }
  if (!context.mounted) return;
  final seasons = groupSeriesEpisodes(episodes)[channel.seriesName];
  if (seasons == null || seasons.isEmpty) {
    return openChannelGuarded(context, ref, channel);
  }
  _showSeriesSheet(context, channel.seriesName, seasons);
}

/// Kısa engelleyici ilerleme göstergesi (lazy bölüm yükleme).
Future<T> _withProgress<T>(
    BuildContext context, Future<T> Function() task) async {
  final nav = Navigator.of(context, rootNavigator: true);
  var shown = true;
  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  ).whenComplete(() => shown = false));
  try {
    return await task();
  } finally {
    if (shown) nav.pop();
  }
}

void _showSeriesSheet(
  BuildContext context,
  String seriesName,
  Map<int, List<ChannelModel>> seasons,
) {
  // Shape / drag handle / background come from bottomSheetTheme.
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SeriesDetailSheet(
      seriesName: seriesName,
      seasons:    seasons,
    ),
  );
}

/// Tek dizi kapagi — film poster card stilinde. Tap -> bottom sheet detay.
class _SeriesPosterCard extends ConsumerWidget {
  final String                       seriesName;
  final Map<int, List<ChannelModel>> seasons;

  const _SeriesPosterCard({
    required this.seriesName,
    required this.seasons,
  });

  /// Posterde gosterilecek logo URL'i — en yeni bolumun logo'su (fallback olarak
  /// ilk dolu logo).
  String? _coverUrl() {
    for (final eps in seasons.values) {
      for (final ep in eps) {
        if (ep.logoUrl.isNotEmpty) return ep.logoUrl;
      }
    }
    return null;
  }

  int _totalEpisodes() => seasons.values.fold(
      0, (sum, eps) => sum + eps.where((e) => !e.isSeriesContainer).length);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l  = AppLocalizations.of(context);
    final cover = _coverUrl();
    final epCount = _totalEpisodes();

    return TvFocusableScale(
      borderRadius: BorderRadius.circular(AppRadius.card + 3),
      onTap: () => _openDetail(context, ref),
      child: Semantics(
        label: epCount > 0
            ? '$seriesName, ${l.seriesEpisodeCount(epCount)}'
            : seriesName,
        button: true,
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: Dimens.posterAspect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: LayoutBuilder(
                  builder: (_, c) => PosterImage(
                    url:   cover,
                    seed:  seriesName,
                    width: c.maxWidth,
                  ),
                ),
              ),
            ),
            // Fixed caption block: name (1 line) + episode count.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seriesName,
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          height: 1.2),
                    ),
                    if (epCount > 0)
                      Text(
                        l.seriesEpisodeCount(epCount),
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: cs.onSurfaceVariant,
                            height: 1.2),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bölümler DB'den yüklenir (liste limitle kesilmiş olabilir; Xtream
  /// container'ı lazy çekilir) — bkz. [openSeries].
  Future<void> _openDetail(BuildContext context, WidgetRef ref) async {
    final first = seasons.values.expand((e) => e).firstOrNull;
    if (first == null) return;
    await openSeries(context, ref, first);
  }
}


/// Modal bottom-sheet: dizi basligi + sezon chip'leri + bolum listesi.
class _SeriesDetailSheet extends StatefulWidget {
  final String                       seriesName;
  final Map<int, List<ChannelModel>> seasons;

  const _SeriesDetailSheet({
    required this.seriesName,
    required this.seasons,
  });

  @override
  State<_SeriesDetailSheet> createState() => _SeriesDetailSheetState();
}

class _SeriesDetailSheetState extends State<_SeriesDetailSheet> {
  int? _selectedSeason;

  @override
  void initState() {
    super.initState();
    final keys = widget.seasons.keys.toList()..sort();
    _selectedSeason = keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final cs       = theme.colorScheme;
    final l        = AppLocalizations.of(context);
    final seasons  = widget.seasons.keys.toList()..sort();
    // Home indicator / gesture bar alani — son bolum altinda kalmasin.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final episodes = _selectedSeason != null
        ? (widget.seasons[_selectedSeason] ?? [])
        : <ChannelModel>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      expand:           false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Drag handle: bottomSheetTheme.showDragHandle.
          // Baslik
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, 0, Spacing.sm, Spacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      widget.seriesName,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: cs.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  l.seriesSeasonCount(seasons.length),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                _SeriesFavoriteButton(
                  playlistId: widget.seasons.values
                          .expand((e) => e)
                          .firstOrNull
                          ?.playlistId ??
                      '',
                  seriesName: widget.seriesName,
                  initial: widget.seasons.values
                      .expand((e) => e)
                      .any((e) => e.isFavorite),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sezon chip'leri
          SizedBox(
            height: 48,
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md, vertical: 6),
                children: seasons.map((s) {
                  final active = s == _selectedSeason;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TvFocusable(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      semanticLabel: s == 0
                          ? l.seriesSpecialSeason
                          : l.seriesSeasonNumber(s),
                      onTap: () {
                        if (s == _selectedSeason) return;
                        HapticFeedback.selectionClick();
                        setState(() => _selectedSeason = s);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? cs.primary
                              : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          s == 0
                              ? l.seriesSpecialSeason
                              : l.seriesSeasonNumber(s),
                          style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? cs.onPrimary
                                  : cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // Bolum listesi (scrollable)
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding:    EdgeInsets.only(bottom: bottomInset + Spacing.lg),
              itemCount:  episodes.length,
              itemBuilder: (ctx, i) => _EpisodeTile(
                episode: episodes[i],
                index:   i,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dizi favorisi (tüm bölümler) — Android toggleSeriesFavorite.
class _SeriesFavoriteButton extends ConsumerStatefulWidget {
  final String playlistId;
  final String seriesName;
  final bool initial;
  const _SeriesFavoriteButton({
    required this.playlistId,
    required this.seriesName,
    required this.initial,
  });

  @override
  ConsumerState<_SeriesFavoriteButton> createState() =>
      _SeriesFavoriteButtonState();
}

class _SeriesFavoriteButtonState extends ConsumerState<_SeriesFavoriteButton> {
  late bool _fav = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      tooltip: _fav ? l.playerFavoriteRemove : l.playerFavoriteAdd,
      isSelected: _fav,
      icon: Icon(_fav ? Icons.favorite : Icons.favorite_border,
          color: _fav ? AppPalette.of(context).accentText : null),
      onPressed: widget.playlistId.isEmpty
          ? null
          : () async {
              HapticFeedback.lightImpact();
              final next = await ref
                  .read(homeProvider.notifier)
                  .toggleSeriesFavorite(widget.playlistId, widget.seriesName);
              if (mounted) setState(() => _fav = next);
            },
    );
  }
}

/// Episode satiri — D-pad Enter/Select ile oynatilabilir, focus feedback var.
class _EpisodeTile extends StatefulWidget {
  final ChannelModel episode;
  final int index;

  const _EpisodeTile({required this.episode, required this.index});

  @override
  State<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<_EpisodeTile> {
  bool _focused = false;

  void _play() {
    final ep = widget.episode;
    // v1.3.5: Player basligi = provider title primary. Sezon listesindeki
    // kart ile ayni etiket kaynagi → stream label her zaman eslesir.
    final label = (ep.streamType == 'series' &&
                   ep.seriesName.isNotEmpty &&
                   !ep.name.toLowerCase().contains(ep.seriesName.toLowerCase()))
        ? '${ep.seriesName} · ${ep.name}'
        : ep.name;
    // 2026-05-25: Bottom sheet'i once kapat, sonra player'a git. Navigator
    // pop sonrasi context modal'a ait — GoRouter lookup defansif olarak
    // pop oncesi yakalanir (review warning #4).
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(
      AppRoutes.player,
      extra: {
        'channelId':       ep.id,
        'channelUrl':      ep.streamUrl,
        'title':           label,
        'initialPosition': ep.lastPosition,
        'streamType':      ep.streamType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ep = widget.episode;

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          _play();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _focused
            ? cs.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        child: ListTile(
          dense:     true,
          leading:   CircleAvatar(
            radius:          14,
            backgroundColor: _focused
                ? cs.primary.withValues(alpha: 0.3)
                : cs.surfaceContainerHigh,
            child: Text(
              ep.episodeNumber > 0 ? '${ep.episodeNumber}' : '${widget.index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: _focused ? cs.onSurface : cs.onSurfaceVariant),
            ),
          ),
          title: Text(
            ep.name,
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: _focused ? FontWeight.w600 : FontWeight.w400),
          ),
          trailing: ep.isWatched
              ? Icon(Icons.check_circle,
                  size: 18, color: AppPalette.of(context).success)
              : null,
          onTap: _play,
        ),
      ),
    );
  }
}
