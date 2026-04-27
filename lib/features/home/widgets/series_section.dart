import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/tv_focus.dart';
import '../../../data/models/channel_model.dart';

/// Groups series episodes by seriesName → season → episodes.
class SeriesSection extends StatelessWidget {
  final List<ChannelModel> channels;

  const SeriesSection({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    final groups = _group(channels);
    if (groups.isEmpty) {
      return Center(
        child: Text(
          'Bu kategoride dizi yok',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      itemCount:   groups.length,
      itemBuilder: (ctx, i) {
        final name = groups.keys.elementAt(i);
        return _SeriesCard(
          seriesName: name,
          seasons:    groups[name]!,
        );
      },
    );
  }

  static Map<String, Map<int, List<ChannelModel>>> _group(
      List<ChannelModel> channels) {
    final result = <String, Map<int, List<ChannelModel>>>{};
    for (final ch in channels) {
      final key   = ch.seriesName.isNotEmpty ? ch.seriesName : ch.name;
      final season= ch.seasonNumber;
      result.putIfAbsent(key, () => {})[season] =
          [...(result[key]?[season] ?? []), ch];
    }
    // Sort episodes within each season.
    // Parse edilemeyen (episodeNumber=0) kayitlari sona at; aralarinda
    // sortOrder (playlist sirasi) ile dengele. Boylece "Bolum 10" < "Bolum 2"
    // bug'i yasanmaz, parse basarisiz olanlar da listeyi bozmaz.
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

class _SeriesCard extends StatefulWidget {
  final String                       seriesName;
  final Map<int, List<ChannelModel>> seasons;

  const _SeriesCard({required this.seriesName, required this.seasons});

  @override
  State<_SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<_SeriesCard> {
  bool     _expanded     = false;
  bool     _headerFocused = false;
  int?     _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedSeason = widget.seasons.keys.first;
  }

  void _toggleExpand() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final seasons = widget.seasons.keys.toList()..sort();
    final episodes= _selectedSeason != null
        ? (widget.seasons[_selectedSeason] ?? [])
        : <ChannelModel>[];

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm / 2),
      child: Column(
        children: [
          // Header — D-pad focusable + Enter/Select ile ac/kapa
          Focus(
            onFocusChange: (v) => setState(() => _headerFocused = v),
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.select ||
                  key == LogicalKeyboardKey.enter ||
                  key == LogicalKeyboardKey.numpadEnter ||
                  key == LogicalKeyboardKey.space ||
                  key == LogicalKeyboardKey.gameButtonA) {
                _toggleExpand();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: InkWell(
              onTap: _toggleExpand,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: _headerFocused
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  border: _headerFocused
                      ? const Border(
                          left: BorderSide(
                              color: AppColors.accent, width: 3))
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg, vertical: Spacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.seriesName,
                        style: TextStyle(
                            fontSize:   TextSize.bodyLg,
                            fontWeight: _headerFocused
                                ? FontWeight.w700
                                : FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${seasons.length} sezon',
                      style: TextStyle(
                          fontSize: TextSize.caption,
                          color:    cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _headerFocused
                          ? AppColors.accent
                          : cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),

            // Season tabs
            SizedBox(
              height: 36,
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md, vertical: 4),
                  children: seasons.map((s) {
                    final active = s == _selectedSeason;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TvFocusable(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => setState(() => _selectedSeason = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s == 0 ? 'Özel' : 'Sezon $s',
                            style: TextStyle(
                                fontSize: TextSize.label,
                                fontWeight: active
                                    ? FontWeight.w600
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

            // Episodes — TV-friendly, focusable, Enter ile oynat
            ...episodes.asMap().entries.map((e) {
              final ep = e.value;
              return _EpisodeTile(
                episode: ep,
                index: e.key,
              );
            }),

            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Episode ListTile — D-pad Enter/Select ile oynatilabilir, focus feedback var.
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
    context.push(
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
            // v1.3.5: Leading = provider episode numarası; yoksa API sıra fallback.
            // Kart label'ı (title) provider name olduğu için leading rakamı
            // label ile tutarlı göstergedir.
            child: Text(
              ep.episodeNumber > 0 ? '${ep.episodeNumber}' : '${widget.index + 1}',
              style: TextStyle(
                  fontSize: TextSize.caption,
                  color: _focused ? AppColors.accent : cs.onSurfaceVariant),
            ),
          ),
          // v1.3.5: Primary label = provider title (ch.name). Stream ile etiket
          // ayni kaynaktan → kullanici ne gorurse onu oynatir. IPTV Extreme
          // davranisi.
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
