import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/http_client.dart';
import '../../core/utils/tv_focus.dart';
import '../../data/models/channel_model.dart';
import 'home_provider.dart';
import 'home_state.dart';
import 'widgets/channel_list_item.dart';
import 'widgets/series_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  bool  _showSearch = false;

  String _homeErrorMessage(Object e) {
    if (e is HttpStatusException) return e.userMessage;
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout')) {
      return 'Saglayici cevap veremedi. Birazdan tekrar deneyin.';
    }
    if (msg.contains('socket') || msg.contains('failed host lookup')) {
      return 'Internet baglantisi yok veya saglayiciya ulasilamiyor.';
    }
    return 'Bir hata olustu: $e';
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  _homeErrorMessage(e),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  autofocus: true,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  onPressed: () => ref.invalidate(homeProvider),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (state) => _buildMain(context, state),
    );
  }

  Widget _buildMain(BuildContext context, HomeState state) {
    final cs = Theme.of(context).colorScheme;

    if (state.playlists.isEmpty) {
      return _NoPlaylistView();
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _TopBar(
            state:       state,
            showSearch:  _showSearch,
            searchCtrl:  _searchCtrl,
            onSearchToggle: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                ref.read(homeProvider.notifier).clearSearch();
              }
            },
            onSearchChanged: (q) =>
                ref.read(homeProvider.notifier).search(q),
          ),
          if (!_showSearch) _TabBar(state: state),
          if (!_showSearch && state.categories.isNotEmpty)
            _CategoryBar(state: state),
          Expanded(
            child: _showSearch
                ? _SearchResults(state: state)
                : _ChannelList(state: state),
          ),
          _BottomBar(state: state),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

// ── No playlist placeholder ───────────────────────────────────────────────────

class _NoPlaylistView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 80, color: cs.onSurfaceVariant),
            const SizedBox(height: Spacing.xl),
            Text('IPTV AI Player',
                style: TextStyle(
                    fontSize: TextSize.titleLg,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
            const SizedBox(height: Spacing.sm),
            Text('Başlamak için bir playlist ekleyin',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: Spacing.xl),
            FilledButton.icon(
              icon:    const Icon(Icons.add),
              label:   const Text('Playlist Ekle'),
              onPressed: () => context.push(AppRoutes.playlists),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final HomeState         state;
  final bool              showSearch;
  final TextEditingController searchCtrl;
  final VoidCallback      onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  const _TopBar({
    required this.state,
    required this.showSearch,
    required this.searchCtrl,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height:     Dimens.topBarHeight,
      color:      cs.surface,
      padding:    const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          // Logo / title
          if (!showSearch)
            Row(
              children: [
                Icon(Icons.live_tv, color: AppColors.accent, size: 26),
                const SizedBox(width: Spacing.sm),
                Text('IPTV AI Player',
                    style: TextStyle(
                        fontSize:   TextSize.title,
                        fontWeight: FontWeight.bold,
                        color:      cs.onSurface)),
              ],
            ),
          if (showSearch)
            Expanded(
              child: TextField(
                controller:   searchCtrl,
                autofocus:    true,
                onChanged:    onSearchChanged,
                style: const TextStyle(fontSize: TextSize.body),
                decoration: InputDecoration(
                  hintText:      'Kanal, film, dizi ara...',
                  border:        InputBorder.none,
                  hintStyle:     TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon:    Icon(Icons.search, color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            const Spacer(),
          // Actions (TV-friendly: buyuk ikonlar)
          IconButton(
            iconSize: 28,
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchToggle,
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.playlist_play),
            tooltip: 'Playlist\'ler',
            onPressed: () => context.push(AppRoutes.playlists),
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends ConsumerWidget {
  final HomeState state;
  const _TabBar({required this.state});

  static const _tabs = [
    ('live',      'Canlı',     Icons.live_tv),
    ('movie',     'Film',      Icons.movie),
    ('series',    'Dizi',      Icons.video_library),
    ('favorites', 'Favoriler', Icons.star),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      color:  cs.surface,
      child: Row(
        children: _tabs.map((t) {
          final (tab, label, icon) = t;
          final active = state.activeTab == tab;
          return Expanded(
            child: _TabButton(
              tab: tab,
              label: label,
              icon: icon,
              active: active,
              onTap: () => ref.read(homeProvider.notifier).selectTab(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String tab;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({
    required this.tab,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = widget.active;
    final highlight = _focused || active;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter ||
            event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _focused
                ? AppColors.accent.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon,
                      size: 16,
                      color: highlight
                          ? AppColors.accent
                          : cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(widget.label,
                      style: TextStyle(
                          fontSize:   TextSize.label,
                          fontWeight: highlight
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color:      highlight
                              ? AppColors.accent
                              : cs.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: _focused ? 3 : 2,
                color: highlight ? AppColors.accent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category bar ──────────────────────────────────────────────────────────────

class _CategoryBar extends ConsumerWidget {
  final HomeState state;
  const _CategoryBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: 6),
          itemCount:       state.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            final cat    = state.categories[i];
            final active = cat == state.selectedCategory;
            return TvFocusable(
              borderRadius: BorderRadius.circular(Radius.badge + 8),
              onTap: () =>
                  ref.read(homeProvider.notifier).selectCategory(cat),
              semanticLabel: cat,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.accent
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Radius.badge + 5),
                ),
                child: Text(cat,
                    style: TextStyle(
                        fontSize: TextSize.label,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.normal,
                        color: active ? cs.onPrimary : cs.onSurfaceVariant)),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Channel list ──────────────────────────────────────────────────────────────

class _ChannelList extends ConsumerWidget {
  final HomeState state;
  const _ChannelList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = state.sortedChannels;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (channels.isEmpty) {
      return Center(
        child: Text(
          'Bu kategoride içerik yok',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    // Series: grouped view
    if (state.activeTab == 'series') {
      return SeriesSection(channels: channels);
    }

    // Movie: poster grid
    if (state.activeTab == 'movie') {
      return GridView.builder(
        padding:     const EdgeInsets.all(Spacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   3,
          childAspectRatio: 0.65,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing:  Spacing.sm,
        ),
        itemCount:   channels.length,
        itemBuilder: (ctx, i) => _PosterCard(channel: channels[i]),
      );
    }

    // Live / favorites: list with optional "recently watched" header
    final recent = state.recentlyWatched;
    final showRecent = state.activeTab == 'live' &&
        state.selectedCategory.isEmpty &&
        recent.isNotEmpty;

    if (showRecent) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _RecentlyWatchedStrip(channels: recent)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => ChannelListItem(channel: channels[i]),
              childCount: channels.length,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount:   channels.length,
      itemBuilder: (ctx, i) => ChannelListItem(channel: channels[i]),
    );
  }
}

// ── Recently watched strip ────────────────────────────────────────────────────

class _RecentlyWatchedStrip extends StatelessWidget {
  final List<ChannelModel> channels;
  const _RecentlyWatchedStrip({required this.channels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.channelItemHPad, Spacing.md, 0, Spacing.sm),
          child: Text(
            'SON İZLENENLER',
            style: TextStyle(
                fontSize:    TextSize.caption,
                fontWeight:  FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: channels.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
            itemBuilder: (ctx, i) {
              final ch = channels[i];
              return TvFocusable(
                borderRadius: BorderRadius.circular(Radius.cardSm + 3),
                onTap: () => context.push(
                  AppRoutes.player,
                  extra: {
                    'channelId':  ch.id,
                    'channelUrl': ch.streamUrl,
                    'title':      ch.name,
                  },
                ),
                semanticLabel: ch.name,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radius.cardSm),
                      child: SizedBox(
                        width:  52,
                        height: 52,
                        child: ch.logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ch.logoUrl,
                                fit:      BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(Icons.live_tv,
                                      color: cs.onSurfaceVariant),
                                ),
                              )
                            : Container(
                                color: cs.surfaceContainerHighest,
                                child: Icon(Icons.live_tv,
                                    color: cs.onSurfaceVariant)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 52,
                      child: Text(
                        ch.name,
                        maxLines:  1,
                        overflow:  TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style:     const TextStyle(fontSize: TextSize.micro),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

// ── Poster card (VOD) ─────────────────────────────────────────────────────────

class _PosterCard extends ConsumerWidget {
  final ChannelModel channel;
  const _PosterCard({required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return TvFocusableScale(
      borderRadius: BorderRadius.circular(Radius.card + 3),
      onTap: () => context.push(
        AppRoutes.player,
        extra: {
          'channelId':  channel.id,
          'channelUrl': channel.streamUrl,
          'title':      channel.name,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radius.card),
              child: channel.logoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl:   channel.logoUrl,
                      fit:        BoxFit.cover,
                      width:      double.infinity,
                      placeholder: (_, __) => Container(
                          color: cs.surfaceContainerHighest),
                      errorWidget: (_, __, ___) =>
                          _PosterPlaceholder(name: channel.name),
                    )
                  : _PosterPlaceholder(name: channel.name),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              channel.name,
              maxLines:  2,
              overflow:  TextOverflow.ellipsis,
              style:     const TextStyle(fontSize: TextSize.caption),
            ),
          ),
        ],
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

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  final HomeState state;
  const _SearchResults({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: Spacing.md),
            Text('Aramak için yazmaya başlayın',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }
    if (state.searchResults.isEmpty) {
      return Center(
          child: Text('"${state.searchQuery}" için sonuç bulunamadı',
              style: TextStyle(color: cs.onSurfaceVariant)));
    }

    return ListView.builder(
      itemCount:   state.searchResults.length,
      itemBuilder: (ctx, i) =>
          ChannelListItem(channel: state.searchResults[i]),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final HomeState state;
  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height:  Dimens.bottomBarHeight,
      color:   cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          Text('${state.channels.length} içerik',
              style: TextStyle(
                  fontSize: TextSize.caption,
                  color:    cs.onSurfaceVariant)),
          const Spacer(),
          // Sort (TV-friendly dialog)
          TextButton.icon(
            icon: Icon(Icons.sort, size: 18, color: cs.onSurfaceVariant),
            label: Text(_sortLabel(state.sortOrder),
                style: TextStyle(
                    fontSize: TextSize.label, color: cs.onSurfaceVariant)),
            onPressed: () => _showSortDialog(context, ref, state),
          ),
        ],
      ),
    );
  }

  Future<void> _showSortDialog(
      BuildContext context, WidgetRef ref, HomeState state) async {
    const options = [
      (SortOrder.defaultOrder, 'Varsayılan'),
      (SortOrder.nameAsc,      'A → Z'),
      (SortOrder.nameDesc,     'Z → A'),
    ];
    final result = await showDialog<SortOrder>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sıralama'),
        children: options.map((o) {
          final selected = state.sortOrder == o.$1;
          return _TvSortOption(
            selected: selected,
            label: o.$2,
            onTap: () => Navigator.pop(ctx, o.$1),
          );
        }).toList(),
      ),
    );
    if (result != null) {
      ref.read(homeProvider.notifier).setSortOrder(result);
    }
  }

  String _sortLabel(SortOrder o) => switch (o) {
    SortOrder.nameAsc  => 'A→Z',
    SortOrder.nameDesc => 'Z→A',
    _                  => 'Sıralama',
  };
}

// ── TV-friendly sort option (D-pad Enter/Select support) ─────────────────────

class _TvSortOption extends StatefulWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _TvSortOption({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TvSortOption> createState() => _TvSortOptionState();
}

class _TvSortOptionState extends State<_TvSortOption> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.selected,
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.gameButtonA) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _focused
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                  widget.selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: AppColors.accent),
              const SizedBox(width: 12),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: TextSize.body,
                      fontWeight:
                          _focused ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
