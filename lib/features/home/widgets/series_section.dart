import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
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
    // Sort episodes within each season
    for (final seasons in result.values) {
      for (final eps in seasons.values) {
        eps.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
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
  int?     _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedSeason = widget.seasons.keys.first;
  }

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
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: Spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.seriesName,
                      style: const TextStyle(
                          fontSize:   TextSize.bodyLg,
                          fontWeight: FontWeight.w600),
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
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),

            // Season tabs
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md, vertical: 4),
                children: seasons.map((s) {
                  final active = s == _selectedSeason;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSeason = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin:   const EdgeInsets.only(right: 6),
                      padding:  const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color:        active
                            ? AppColors.accent
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s == 0 ? 'Özel' : 'Sezon $s',
                        style: TextStyle(
                            fontSize:   TextSize.label,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color:      active
                                ? cs.onPrimary
                                : cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Episodes
            ...episodes.asMap().entries.map((e) {
              final ep = e.value;
              return ListTile(
                dense:     true,
                leading:   CircleAvatar(
                  radius:          14,
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Text(
                    '${ep.episodeNumber > 0 ? ep.episodeNumber : e.key + 1}',
                    style: TextStyle(
                        fontSize: TextSize.caption,
                        color:    cs.onSurfaceVariant),
                  ),
                ),
                title: Text(
                  ep.name,
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                  style:     const TextStyle(fontSize: TextSize.body),
                ),
                trailing: ep.isWatched
                    ? Icon(Icons.check_circle,
                        size: 16, color: AppColors.success)
                    : null,
                onTap: () => context.push(
                  AppRoutes.player,
                  extra: {
                    'channelId':  ep.id,
                    'channelUrl': ep.streamUrl,
                    'title':      ep.name,
                  },
                ),
              );
            }),

            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}
