import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/epg_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';

/// EPG TV Rehberi — kanal × zaman grid'i.
/// Free: bugün. Pro: ±3 gün.
class EpgGuideScreen extends ConsumerStatefulWidget {
  const EpgGuideScreen({super.key});

  @override
  ConsumerState<EpgGuideScreen> createState() => _EpgGuideScreenState();
}

class _EpgGuideScreenState extends ConsumerState<EpgGuideScreen> {
  /// Bugünün midnight'ı baz alınır; offset gün cinsinden (-3..+3).
  int _dayOffset = 0;

  DateTime get _selectedDay {
    final n = DateTime.now();
    final base = DateTime(n.year, n.month, n.day);
    return base.add(Duration(days: _dayOffset));
  }

  Future<void> _onPickDay(int newOffset) async {
    if (newOffset == _dayOffset) return;
    final isPro = ref.read(isProProvider);
    if (!isPro && newOffset != 0) {
      final ok = await requirePro(context, ref, PaywallTrigger.epg);
      if (!ok) return;
    }
    if (mounted) setState(() => _dayOffset = newOffset);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final activeId = ref.watch(activePlaylistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.epgGuideTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _DateBar(
            selectedOffset: _dayOffset,
            onPick: _onPickDay,
          ),
        ),
      ),
      body: activeId.isEmpty
          ? Center(child: Text(l.settingsSelectPlaylistFirst))
          : _GuideBody(
              playlistId: activeId,
              dayStart: _selectedDay,
            ),
    );
  }
}

// ── Date bar ─────────────────────────────────────────────────────────────────

class _DateBar extends ConsumerWidget {
  final int selectedOffset;
  final ValueChanged<int> onPick;
  const _DateBar({required this.selectedOffset, required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isPro = ref.watch(isProProvider);
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final offset = i - 3;
          final isLocked = !isPro && offset != 0;
          final isSelected = offset == selectedOffset;
          final label = _label(offset, l);
          return GestureDetector(
            onTap: () => onPick(offset),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: isSelected
                              ? cs.onPrimary
                              : cs.onSurface)),
                  if (isLocked) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.lock,
                        size: 12,
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _label(int offset, AppLocalizations l) {
    if (offset == 0)  return l.epgToday;
    if (offset == -1) return l.epgYesterday;
    if (offset == 1)  return l.epgTomorrow;
    final d = DateTime.now().add(Duration(days: offset));
    return '${d.day}/${d.month}';
  }
}

// ── Guide body ────────────────────────────────────────────────────────────────
//
// Layout: Vertical channel list. Her satırda channel logo + name (sticky left)
// ve horizontal scroll'da o gün için programlar (zaman bloğu olarak).

class _GuideBody extends ConsumerWidget {
  final String   playlistId;
  final DateTime dayStart;
  const _GuideBody({required this.playlistId, required this.dayStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final asyncData = ref.watch(_epgGuideDataProvider(_GuideArgs(
      playlistId: playlistId,
      dayStart:   dayStart,
    )));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.epgError('$e'),
              style: TextStyle(color: cs.error)),
        ),
      ),
      data: (data) {
        if (data.channels.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rss_feed_outlined,
                      size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(l.epgNoData,
                      style: TextStyle(color: cs.onSurface, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(l.epgNoDataHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: data.channels.length,
          itemBuilder: (ctx, i) {
            final ch = data.channels[i];
            final progs = data.programmesByTvgId[ch.tvgId] ?? const [];
            return _ChannelRow(channel: ch, programmes: progs);
          },
        );
      },
    );
  }
}

class _ChannelRow extends StatelessWidget {
  final ChannelModel       channel;
  final List<EpgProgrammeModel> programmes;
  const _ChannelRow({required this.channel, required this.programmes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sticky left: logo + name (channel)
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(right: BorderSide(color: cs.outline)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (channel.logoUrl.isNotEmpty)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CachedNetworkImage(
                      imageUrl: channel.logoUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.live_tv, color: cs.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: cs.onSurface, fontSize: 12)),
              ],
            ),
          ),
          // Horizontal scroll: programmes
          Expanded(
            child: programmes.isEmpty
                ? Container(
                    color: cs.surface,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppLocalizations.of(context).epgRowEmpty,
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: programmes.length,
                    itemBuilder: (ctx, i) =>
                        _ProgrammeBlock(p: programmes[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProgrammeBlock extends StatelessWidget {
  final EpgProgrammeModel p;
  const _ProgrammeBlock({required this.p});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isLive = now >= p.startTime && now < p.stopTime;

    final start = DateTime.fromMillisecondsSinceEpoch(p.startTime);
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    final mins = ((p.stopTime - p.startTime) / 60000).round();
    final width = (mins * 2.0).clamp(60.0, 280.0); // 1 min = 2 px

    return GestureDetector(
      onTap: () => _showProgrammeSheet(context, p),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLive
              ? cs.primary.withValues(alpha: 0.18)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isLive ? cs.primary : Colors.transparent, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 11)),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: cs.onSurface, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showProgrammeSheet(BuildContext context, EpgProgrammeModel p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final start = DateTime.fromMillisecondsSinceEpoch(p.startTime);
      final stop  = DateTime.fromMillisecondsSinceEpoch(p.stopTime);
      String fmt(DateTime d) =>
          '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.title,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${fmt(start)} → ${fmt(stop)}',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              if (p.category.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(p.category,
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ],
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(p.description,
                    style: TextStyle(color: cs.onSurface)),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class _GuideArgs {
  final String   playlistId;
  final DateTime dayStart;
  const _GuideArgs({required this.playlistId, required this.dayStart});

  @override
  bool operator ==(Object other) =>
      other is _GuideArgs &&
      other.playlistId == playlistId &&
      other.dayStart == dayStart;
  @override
  int get hashCode => Object.hash(playlistId, dayStart);
}

class _GuideData {
  final List<ChannelModel> channels;
  final Map<String, List<EpgProgrammeModel>> programmesByTvgId;
  const _GuideData({required this.channels, required this.programmesByTvgId});
}

final _epgGuideDataProvider = FutureProvider.autoDispose
    .family<_GuideData, _GuideArgs>((ref, args) async {
  final channelRepo = ref.read(channelRepoProvider);
  final epgRepo     = ref.read(epgRepoProvider);

  // Sadece live kanallar EPG'de gösterilir.
  final liveChannels =
      await channelRepo.getByType(args.playlistId, 'live');
  // tvgId boş olanlar EPG join'a katılmaz ama UI satırı yine basılır.
  final tvgIds = liveChannels
      .where((c) => c.tvgId.isNotEmpty)
      .map((c) => c.tvgId)
      .toSet()
      .toList();

  final dayEnd = args.dayStart.add(const Duration(days: 1));
  final progs = await epgRepo.getProgrammesForChannelsInWindow(
    tvgIds: tvgIds,
    startMs: args.dayStart.millisecondsSinceEpoch,
    endMs:   dayEnd.millisecondsSinceEpoch,
  );

  return _GuideData(
    channels: liveChannels,
    programmesByTvgId: progs,
  );
});
