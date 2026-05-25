import 'dart:ui' as ui show Radius;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/tv_focus.dart';
import '../../../data/models/channel_model.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Diziler tab'i — Kotlin paritesi (VodSeriesPosterGrid):
/// Ust seviye poster grid (her dizi tek kart). Karta tiklayinca alttan
/// bottom-sheet acilir; sezon chip'leri + bolum listesi orada.
///
/// 2026-05-25: Eskiden tum diziler dikey list halinde expand edilen Card'lar
/// olarak gosteriliyordu — film tab'i poster grid kullanirken dizi tab'i
/// farkli gorunum sergiliyordu (kullanici raporu).
class SeriesSection extends StatelessWidget {
  final List<ChannelModel> channels;

  const SeriesSection({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    final groups = _group(channels);
    if (groups.isEmpty) {
      final l = AppLocalizations.of(context);
      return Center(
        child: Text(
          l.seriesEmptyCategory,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final entries = groups.entries.toList();
    final columns = Responsive.posterGridColumns(context);

    return GridView.builder(
      padding:     const EdgeInsets.all(Spacing.md),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   columns,
        childAspectRatio: 0.62,
        crossAxisSpacing: Spacing.sm,
        mainAxisSpacing:  Spacing.sm,
      ),
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

  static Map<String, Map<int, List<ChannelModel>>> _group(
      List<ChannelModel> channels) {
    final result = <String, Map<int, List<ChannelModel>>>{};
    for (final ch in channels) {
      final key    = ch.seriesName.isNotEmpty ? ch.seriesName : ch.name;
      final season = ch.seasonNumber;
      result.putIfAbsent(key, () => {})[season] =
          [...(result[key]?[season] ?? []), ch];
    }
    // Parse edilemeyen (episodeNumber=0) kayitlari sona at; aralarinda
    // sortOrder (playlist sirasi) ile dengele. "Bolum 10" < "Bolum 2" bug'i
    // yasanmasin, parse basarisiz olanlar da listeyi bozmasin.
    int rank(int n) => n == 0 ? 1 << 30 : n;
    for (final seasons in result.values) {
      for (final eps in seasons.values) {
        eps.sort((a, b) {
          final byEp = rank(a.episodeNumber).compareTo(rank(b.episodeNumber));
          if (byEp != 0) return byEp;
          return a.sortOrder.compareTo(b.sortOrder);
        });
      }
    }
    return result;
  }
}

/// Tek dizi kapagi — film poster card stilinde. Tap -> bottom sheet detay.
class _SeriesPosterCard extends StatelessWidget {
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

  int _totalEpisodes() =>
      seasons.values.fold(0, (sum, eps) => sum + eps.length);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l  = AppLocalizations.of(context);
    final cover = _coverUrl();
    final epCount = _totalEpisodes();

    return TvFocusableScale(
      borderRadius: BorderRadius.circular(Radius.card + 3),
      onTap: () => _openDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radius.card),
              child: cover != null
                  ? CachedNetworkImage(
                      imageUrl:    cover,
                      fit:         BoxFit.cover,
                      width:       double.infinity,
                      placeholder: (_, __) => Container(
                          color: cs.surfaceContainerHighest),
                      errorWidget: (_, __, ___) =>
                          _PosterPlaceholder(name: seriesName),
                    )
                  : _PosterPlaceholder(name: seriesName),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              seriesName,
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              style:     const TextStyle(
                  fontSize:   TextSize.caption,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l.seriesEpisodeCount(epCount),
              maxLines:  1,
              overflow:  TextOverflow.ellipsis,
              style:     TextStyle(
                  fontSize: TextSize.micro,
                  color:    cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: ui.Radius.circular(20)),
      ),
      builder: (ctx) => _SeriesDetailSheet(
        seriesName: seriesName,
        seasons:    seasons,
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  final String name;
  const _PosterPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
              fontSize: TextSize.titleLg * 1.5,
              color:    cs.onSurfaceVariant),
        ),
      ),
    );
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
    final cs       = Theme.of(context).colorScheme;
    final l        = AppLocalizations.of(context);
    final seasons  = widget.seasons.keys.toList()..sort();
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
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Baslik
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg, vertical: Spacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.seriesName,
                    style: TextStyle(
                        fontSize:   TextSize.titleLg,
                        fontWeight: FontWeight.w700,
                        color:      cs.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  l.seriesSeasonCount(seasons.length),
                  style: TextStyle(
                      fontSize: TextSize.caption,
                      color:    cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sezon chip'leri
          SizedBox(
            height: 44,
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
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => setState(() => _selectedSeason = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          s == 0
                              ? l.seriesSpecialSeason
                              : l.seriesSeasonNumber(s),
                          style: TextStyle(
                              fontSize:   TextSize.label,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.normal,
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
    final cs = Theme.of(context).colorScheme;
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
            ? AppColors.accent.withValues(alpha: 0.12)
            : Colors.transparent,
        child: ListTile(
          dense:     true,
          leading:   CircleAvatar(
            radius:          14,
            backgroundColor: _focused
                ? AppColors.accent.withValues(alpha: 0.3)
                : cs.surfaceContainerHighest,
            child: Text(
              ep.episodeNumber > 0 ? '${ep.episodeNumber}' : '${widget.index + 1}',
              style: TextStyle(
                  fontSize: TextSize.caption,
                  color: _focused ? AppColors.accent : cs.onSurfaceVariant),
            ),
          ),
          title: Text(
            ep.name,
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
            style:     TextStyle(
                fontSize: TextSize.body,
                fontWeight: _focused ? FontWeight.w600 : FontWeight.normal),
          ),
          trailing: ep.isWatched
              ? Icon(Icons.check_circle,
                  size: 16, color: AppColors.success)
              : null,
          onTap: _play,
        ),
      ),
    );
  }
}
