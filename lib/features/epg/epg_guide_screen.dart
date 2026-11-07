import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/channel_model.dart';
import '../../data/models/epg_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../parental/parental_guard.dart';
import 'epg_guide_layout.dart';

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
    if (!mounted) return;
    HapticFeedback.selectionClick();
    setState(() => _dayOffset = newOffset);
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
          child: _DateBar(selectedOffset: _dayOffset, onPick: _onPickDay),
        ),
      ),
      body:
          activeId.isEmpty
              ? EmptyState(
                icon: Icons.playlist_play_rounded,
                title: l.settingsSelectPlaylistFirst,
              )
              : _GuideBody(playlistId: activeId, dayStart: _selectedDay),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xs,
        ),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final offset = i - 3;
          final isLocked = !isPro && offset != 0;
          final isSelected = offset == selectedOffset;
          final label = _label(offset, l);
          return Semantics(
            button: true,
            selected: isSelected,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: () => onPick(offset),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.lock,
                        size: 12,
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _label(int offset, AppLocalizations l) {
    if (offset == 0) return l.epgToday;
    if (offset == -1) return l.epgYesterday;
    if (offset == 1) return l.epgTomorrow;
    final d = DateTime.now().add(Duration(days: offset));
    return '${d.day}/${d.month}';
  }
}

// ── Guide body ────────────────────────────────────────────────────────────────
//
// Android EpgGuideScreen paritesi: solda sabit kanal sütunu, sağda TEK yatay
// kaydırma alanı (zaman başlığı + tüm satırlar birlikte kayar → senkron),
// 30 dk tikli ortak zaman başlığı, "şimdi" çizgisi, süreyle orantılı bloklar.
// Kanal adına dokununca oynatır (ebeveyn kilidi kontrollü).

const double _rowHeight = 72;
const double _headerHeight = 32;
const double _channelColWidthPhone = 116;

/// Tablet / TV'de kanal adlari daha az kirpilsin.
double _channelColWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600
        ? Dimens.epgChannelColTablet
        : _channelColWidthPhone;

const _tabular = [FontFeature.tabularFigures()];

class _GuideBody extends ConsumerStatefulWidget {
  final String playlistId;
  final DateTime dayStart;
  const _GuideBody({required this.playlistId, required this.dayStart});

  @override
  ConsumerState<_GuideBody> createState() => _GuideBodyState();
}

class _GuideBodyState extends ConsumerState<_GuideBody> {
  final _hCtrl = ScrollController();
  final _vLeft = ScrollController();
  final _vRight = ScrollController();
  bool _syncing = false;
  bool _initialScrollDone = false;

  GuideLayout get _layout => GuideLayout(
    windowStartMs: widget.dayStart.millisecondsSinceEpoch,
    windowEndMs:
        widget.dayStart.add(const Duration(days: 1)).millisecondsSinceEpoch,
  );

  @override
  void initState() {
    super.initState();
    // İki dikey listeyi senkron tut (kanal sütunu ↔ program satırları).
    _vLeft.addListener(() => _mirror(_vLeft, _vRight));
    _vRight.addListener(() => _mirror(_vRight, _vLeft));
  }

  @override
  void didUpdateWidget(covariant _GuideBody old) {
    super.didUpdateWidget(old);
    if (old.dayStart != widget.dayStart) _initialScrollDone = false;
  }

  void _mirror(ScrollController from, ScrollController to) {
    if (_syncing || !to.hasClients || !from.hasClients) return;
    _syncing = true;
    to.jumpTo(from.offset.clamp(0.0, to.position.maxScrollExtent));
    _syncing = false;
  }

  void _scrollToNow() {
    if (_initialScrollDone || !_hCtrl.hasClients) return;
    _initialScrollDone = true;
    final now = DateTime.now().millisecondsSinceEpoch;
    final off = _layout.nowOffset(now);
    final target = off == null ? 0.0 : (off - 30 * _layout.pxPerMinute);
    _hCtrl.jumpTo(target.clamp(0.0, _hCtrl.position.maxScrollExtent));
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _vLeft.dispose();
    _vRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final asyncData = ref.watch(
      _epgGuideDataProvider(
        _GuideArgs(playlistId: widget.playlistId, dayStart: widget.dayStart),
      ),
    );

    final args = _GuideArgs(
      playlistId: widget.playlistId,
      dayStart: widget.dayStart,
    );
    return asyncData.when(
      loading: () => _GuideSkeleton(channelColWidth: _channelColWidth(context)),
      error:
          (e, _) => EmptyState.error(
            title: l.epgError('$e'),
            actionLabel: l.retry,
            onAction: () => ref.invalidate(_epgGuideDataProvider(args)),
          ),
      data: (data) {
        if (data.channels.isEmpty) {
          return EmptyState(
            icon: Icons.rss_feed_outlined,
            title: l.epgNoData,
            message: l.epgNoDataHint,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
        final layout = _layout;
        final nowOff = layout.nowOffset(DateTime.now().millisecondsSinceEpoch);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sabit kanal sütunu
            SizedBox(
              width: _channelColWidth(context),
              child: Column(
                children: [
                  const SizedBox(height: _headerHeight),
                  Expanded(
                    child: ListView.builder(
                      controller: _vLeft,
                      itemExtent: _rowHeight,
                      itemCount: data.channels.length,
                      itemBuilder:
                          (ctx, i) => _ChannelCell(channel: data.channels[i]),
                    ),
                  ),
                ],
              ),
            ),
            // Tek yatay kaydırma: başlık + satırlar birlikte
            Expanded(
              child: SingleChildScrollView(
                controller: _hCtrl,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: layout.totalWidth,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          _TimeHeader(layout: layout),
                          Expanded(
                            child: ListView.builder(
                              controller: _vRight,
                              itemExtent: _rowHeight,
                              itemCount: data.channels.length,
                              itemBuilder: (ctx, i) {
                                final ch = data.channels[i];
                                return _ProgrammeRow(
                                  layout: layout,
                                  programmes:
                                      data.programmesByTvgId[ch.tvgId] ??
                                      const [],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      if (nowOff != null)
                        Positioned(
                          left: nowOff,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Container(width: 2, color: cs.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimeHeader extends StatelessWidget {
  final GuideLayout layout;
  const _TimeHeader({required this.layout});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        children: [
          for (final t in layout.ticks())
            Positioned(
              left: layout.offsetOf(t),
              top: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: cs.outlineVariant)),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  _hm(t),
                  style: TextStyle(
                    fontSize: 11,
                    fontFeatures: _tabular,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _hm(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _ChannelCell extends ConsumerWidget {
  final ChannelModel channel;
  const _ChannelCell({required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => openChannelGuarded(context, ref, channel),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            right: BorderSide(color: cs.outline),
            bottom: BorderSide(color: cs.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            if (channel.logoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CachedNetworkImage(
                    imageUrl: channel.logoUrl,
                    fit: BoxFit.contain,
                    memCacheWidth:
                        (28 * MediaQuery.devicePixelRatioOf(context)).round(),
                    fadeInDuration: const Duration(milliseconds: 180),
                    errorWidget:
                        (_, __, ___) =>
                            Icon(Icons.live_tv, color: cs.onSurfaceVariant),
                  ),
                ),
              ),
            Expanded(
              child: Text(
                channel.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurface, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeRow extends StatelessWidget {
  final GuideLayout layout;
  final List<EpgProgrammeModel> programmes;
  const _ProgrammeRow({required this.layout, required this.programmes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now().millisecondsSinceEpoch;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child:
          programmes.isEmpty
              ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    AppLocalizations.of(context).epgRowEmpty,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              )
              : Stack(
                children: [
                  for (final p in programmes)
                    if (layout.block(p.startTime, p.stopTime) case (
                      final left,
                      final width,
                    ))
                      Positioned(
                        left: left,
                        width: width,
                        top: 4,
                        bottom: 4,
                        child: _ProgrammeBlock(
                          p: p,
                          live: now >= p.startTime && now < p.stopTime,
                        ),
                      ),
                ],
              ),
    );
  }
}

class _ProgrammeBlock extends StatelessWidget {
  final EpgProgrammeModel p;
  final bool live;
  const _ProgrammeBlock({required this.p, required this.live});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showProgrammeSheet(context, p),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color:
              live
                  ? cs.primary.withValues(alpha: 0.18)
                  : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: live ? cs.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hm(p.startTime),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 11,
                fontFeatures: _tabular,
              ),
            ),
            Expanded(
              child: Text(
                p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurface, fontSize: 12),
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
    useSafeArea: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      final start = DateTime.fromMillisecondsSinceEpoch(p.startTime);
      final stop = DateTime.fromMillisecondsSinceEpoch(p.stopTime);
      String fmt(DateTime d) =>
          '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lgx,
            0,
            Spacing.lgx,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(p.title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                '${fmt(start)} → ${fmt(stop)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFeatures: _tabular,
                ),
              ),
              if (p.category.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  p.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: Spacing.lg),
                Text(p.description, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// Rehber yuklenirken: kanal sutunu + program bloklari iskeleti.
class _GuideSkeleton extends StatelessWidget {
  final double channelColWidth;
  const _GuideSkeleton({required this.channelColWidth});

  @override
  Widget build(BuildContext context) => SkeletonPulse(
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: _headerHeight),
      itemExtent: _rowHeight,
      itemCount: 10,
      itemBuilder:
          (_, i) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: channelColWidth - Spacing.lg,
                  child: const Row(
                    children: [
                      SkeletonBox(width: 28, height: 28),
                      SizedBox(width: 6),
                      Expanded(child: SkeletonBox(height: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  flex: 2 + i % 3,
                  child: const SkeletonBox(radius: AppRadius.xs),
                ),
                const SizedBox(width: 2),
                const Expanded(
                  flex: 3,
                  child: SkeletonBox(radius: AppRadius.xs),
                ),
              ],
            ),
          ),
    ),
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class _GuideArgs {
  final String playlistId;
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
      final epgRepo = ref.read(epgRepoProvider);

      // Sadece live kanallar EPG'de gösterilir.
      final liveChannels = await channelRepo.getByType(args.playlistId, 'live');
      // tvgId boş olanlar EPG join'a katılmaz ama UI satırı yine basılır.
      final tvgIds =
          liveChannels
              .where((c) => c.tvgId.isNotEmpty)
              .map((c) => c.tvgId)
              .toSet()
              .toList();

      final dayEnd = args.dayStart.add(const Duration(days: 1));
      final progs = await epgRepo.getProgrammesForChannelsInWindow(
        tvgIds: tvgIds,
        startMs: args.dayStart.millisecondsSinceEpoch,
        endMs: dayEnd.millisecondsSinceEpoch,
      );

      return _GuideData(channels: liveChannels, programmesByTvgId: progs);
    });
