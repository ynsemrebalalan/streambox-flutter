import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);

    return homeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Hata: $e')),
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
            Text('StreamBox',
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
                Text('StreamBox',
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
          // Actions
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchToggle,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            tooltip: 'Playlist\'ler',
            onPressed: () => context.push(AppRoutes.playlists),
          ),
          IconButton(
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
            child: InkWell(
              onTap: () => ref.read(homeProvider.notifier).selectTab(tab),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          size: 16,
                          color: active
                              ? AppColors.accent
                              : cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(label,
                          style: TextStyle(
                              fontSize:   TextSize.label,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color:      active
                                  ? AppColors.accent
                                  : cs.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    color: active ? AppColors.accent : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: 6),
        itemCount:       state.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final cat    = state.categories[i];
          final active = cat == state.selectedCategory;
          return GestureDetector(
            onTap: () =>
                ref.read(homeProvider.notifier).selectCategory(cat),
            child: AnimatedContainer(
              duration:   const Duration(milliseconds: 150),
              padding:    const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color:        active
                    ? AppColors.accent
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Radius.badge + 8),
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
              return GestureDetector(
                onTap: () => context.push(
                  AppRoutes.player,
                  extra: {
                    'channelId':  ch.id,
                    'channelUrl': ch.streamUrl,
                    'title':      ch.name,
                  },
                ),
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

    return GestureDetector(
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
          Text(
            channel.name,
            maxLines:  2,
            overflow:  TextOverflow.ellipsis,
            style:     const TextStyle(fontSize: TextSize.caption),
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
    final cs      = Theme.of(context).colorScheme;
    final overlay = GlobalKey();

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
          // Sort
          PopupMenuButton<SortOrder>(
            key:         overlay,
            tooltip:     'Sıralama',
            initialValue: state.sortOrder,
            onSelected:  (o) =>
                ref.read(homeProvider.notifier).setSortOrder(o),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: SortOrder.defaultOrder,
                child: Row(children: [
                  if (state.sortOrder == SortOrder.defaultOrder)
                    const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  const Text('Varsayılan'),
                ]),
              ),
              PopupMenuItem(
                value: SortOrder.nameAsc,
                child: Row(children: [
                  if (state.sortOrder == SortOrder.nameAsc)
                    const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  const Text('A → Z'),
                ]),
              ),
              PopupMenuItem(
                value: SortOrder.nameDesc,
                child: Row(children: [
                  if (state.sortOrder == SortOrder.nameDesc)
                    const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  const Text('Z → A'),
                ]),
              ),
            ],
            child: Row(
              children: [
                Icon(Icons.sort, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(_sortLabel(state.sortOrder),
                    style: TextStyle(
                        fontSize: TextSize.label,
                        color:    cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(SortOrder o) => switch (o) {
    SortOrder.nameAsc  => 'A→Z',
    SortOrder.nameDesc => 'Z→A',
    _                  => 'Sıralama',
  };
}
