import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/category_icons.dart';
import '../../core/utils/http_client.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/tv_focus.dart';
import '../../data/models/channel_model.dart';
import '../../l10n/generated/app_localizations.dart';
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

  String _homeErrorMessage(Object e, AppLocalizations l) {
    if (e is HttpStatusException) return e.userMessage;
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout')) {
      return l.errorTimeoutProvider;
    }
    if (msg.contains('socket') || msg.contains('failed host lookup')) {
      return l.errorNoConnection;
    }
    if (msg.contains('database') ||
        msg.contains('sqlite') ||
        msg.contains('sqfliteexception')) {
      return l.errorDatabaseTemporary;
    }
    return l.errorGenericRetry;
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final l = AppLocalizations.of(context);

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
                  _homeErrorMessage(e, l),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  autofocus: true,
                  icon: const Icon(Icons.refresh),
                  label: Text(l.retry),
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
      // SafeArea: iPhone Dynamic Island / notch + home indicator alanlarini
      // koru. bottom: false → BottomBar kendi padding'ini iceride yapiyor,
      // double-padding olmasin.
      body: SafeArea(
        bottom: false,
        child: Column(
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
          // Background refresh bar — full-screen spinner yerine içerik üzerinde
          // ince ilerleyen progress + opsiyonel status mesajı.
          if (state.isBackgroundLoading)
            _BackgroundLoadingBar(message: state.loadingMessage),
          if (!_showSearch) _TabBar(state: state),
          if (!_showSearch && state.activeTab == 'favorites')
            _FavoritesTypeBar(state: state),
          if (!_showSearch &&
              state.activeTab != 'favorites' &&
              state.categories.isNotEmpty)
            _CategoryBar(state: state),
          Expanded(
            child: _showSearch
                ? _SearchResults(state: state)
                : _ChannelList(state: state),
          ),
          _BottomBar(state: state),
        ],
        ),
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.live_tv, size: 80, color: cs.onSurfaceVariant),
              const SizedBox(height: Spacing.xl),
              Text(l.homeAppTitle,
                  style: TextStyle(
                      fontSize: TextSize.titleLg,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface)),
              const SizedBox(height: Spacing.sm),
              Text(l.homeNoPlaylistMessage,
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: Spacing.xl),
              FilledButton.icon(
                icon:    const Icon(Icons.add),
                label:   Text(l.homeAddPlaylist),
                onPressed: () => context.push(AppRoutes.playlists),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

/// Üç nokta menü için ortak satır widget'ı — icon + 8dp gap + label.
PopupMenuItem<String> _menuItem(String value, IconData icon, String label) =>
    PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: Spacing.sm),
          Text(label),
        ],
      ),
    );

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
    final l = AppLocalizations.of(context);

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
                Text(l.homeAppTitle,
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
                  hintText:      l.homeSearchHint,
                  border:        InputBorder.none,
                  hintStyle:     TextStyle(color: cs.onSurfaceVariant),
                  prefixIcon:    Icon(Icons.search, color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            const Spacer(),
          // Top bar minimalize — sadece arama icon + üç nokta menü.
          // Android paritesi (HomeScreen.kt:1043+): playlist/settings/feedback
          // gibi tüm ikincil eylemler tek menüde toplanır, üst bar yorulmaz.
          IconButton(
            iconSize: 28,
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchToggle,
          ),
          PopupMenuButton<String>(
            iconSize: 28,
            tooltip: l.homeMore,
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'playlists':
                  context.push(AppRoutes.playlists);
                  break;
                case 'category':
                  context.push(AppRoutes.categoryFilter);
                  break;
                case 'epg':
                case 'settings':
                  context.push(AppRoutes.settings);
                  break;
              }
            },
            // Son İzlenenler / Yeni Eklenenler / Nerede Kaldım menü item'ları
            // kaldırıldı — Home tab'ında zaten ayrı satır olarak görünüyor,
            // menüden tekrar listelemek redundant idi (kullanıcı geri bildirimi).
            itemBuilder: (ctx) => [
              _menuItem('playlists', Icons.playlist_play,     l.menuMyPlaylists),
              _menuItem('category',  Icons.filter_list,       l.homeCategoryManagement),
              _menuItem('epg',       Icons.rss_feed,          l.menuEpgSettings),
              const PopupMenuDivider(),
              _menuItem('settings',  Icons.settings_outlined, l.settingsTitle),
            ],
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    final tabs = <(String, String, IconData)>[
      ('home',      l.homeTabHome,      Icons.home),
      ('live',      l.homeTabLive,      Icons.live_tv),
      ('movie',     l.homeTabMovie,     Icons.movie),
      ('series',    l.homeTabSeries,    Icons.video_library),
      ('favorites', l.homeTabFavorites, Icons.star),
    ];

    return Container(
      height: 44,
      color:  cs.surface,
      child: Row(
        children: tabs.map((t) {
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

/// Sabit "comfortable" görünüm — modern streaming app pattern'i (Netflix,
/// AppleTV+, Spotify): horizontal scroll, 56 dp yüksekliğinde, kategori-özel
/// ikon + text yan yana. iOS HIG ve Material 3 her ikisinin de normuna uyar.
///
/// Density toggle (compact/comfortable/spacious) v3.9.0 (Adım 6 redesign)
/// sırasında kaldırıldı — kullanıcı geri bildirimi: "tek görünüm yeterli, en
/// uygun olanı seç". Profile yapısı dolayısıyla geri eklenmesi kolay.
class _CategoryBar extends ConsumerWidget {
  final HomeState state;
  const _CategoryBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 56,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: 8),
          itemCount:        state.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final cat    = state.categories[i];
            final active = cat == state.selectedCategory;
            final type   = _typeForTab(state.activeTab);
            final icon   = mapCategoryToIcon(cat, streamType: type);
            return _CategoryChip(
              label:   cat,
              icon:    icon,
              active:  active,
              onTap:   () =>
                  ref.read(homeProvider.notifier).selectCategory(cat),
            );
          },
        ),
      ),
    );
  }

  static String? _typeForTab(String tab) => switch (tab) {
        'live'   => 'live',
        'movie'  => 'movie',
        'series' => 'series',
        _        => null,
      };
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool   active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = active ? cs.onPrimary : cs.onSurfaceVariant;
    final bg = active ? AppColors.accent : cs.surfaceContainerHighest;

    return TvFocusable(
      borderRadius: BorderRadius.circular(Radius.badge + 8),
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(Radius.badge + 5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:   TextSize.label,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color:      fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Favorites type filter bar ─────────────────────────────────────────────────
//
// Favoriler sekmesinde "Tümü / Canlı / Filmler / Diziler" chip'leri. Tek listede
// üç içerik tipi karıştığı için kullanıcı şikayeti vardı (v3.5.3 öncesi).

class _FavoritesTypeBar extends ConsumerWidget {
  final HomeState state;
  const _FavoritesTypeBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    final filters = <(String, String, IconData)>[
      ('',       l.homeFavoritesAll,    Icons.star),
      ('live',   l.homeFavoritesLive,   Icons.live_tv),
      ('movie',  l.homeFavoritesMovie,  Icons.movie),
      ('series', l.homeFavoritesSeries, Icons.video_library),
    ];

    return SizedBox(
      height: 48,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: 6),
          itemCount:       filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            final (value, label, icon) = filters[i];
            final active = value == state.favoritesTypeFilter;
            return TvFocusable(
              borderRadius: BorderRadius.circular(Radius.badge + 8),
              onTap: () => ref
                  .read(homeProvider.notifier)
                  .setFavoritesTypeFilter(value),
              semanticLabel: label,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.accent
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Radius.badge + 5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 16,
                        color: active ? cs.onPrimary : cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(label,
                        style: TextStyle(
                            fontSize: TextSize.label,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: active
                                ? cs.onPrimary
                                : cs.onSurfaceVariant)),
                  ],
                ),
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

    // Ana Sayfa: channels yerine row'lar gösterilir, boş empty state olmamalı
    if (state.activeTab == 'home') {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _HomeRowsLayout(state: state);
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (channels.isEmpty) {
      final l = AppLocalizations.of(context);
      final msg = state.activeTab == 'favorites'
          ? (state.favoritesTypeFilter.isEmpty
              ? l.homeEmptyFavorites
              : l.homeEmptyFavoritesType)
          : l.homeEmptyCategory;
      return Center(
        child: Text(
          msg,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    // Series: grouped view
    if (state.activeTab == 'series') {
      return SeriesSection(channels: channels);
    }

    // Movie: poster grid (responsive columns for iPad)
    if (state.activeTab == 'movie') {
      final columns = Responsive.posterGridColumns(context);
      return GridView.builder(
        padding:     const EdgeInsets.all(Spacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   columns,
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

// ── Home rows layout (Ana Sayfa sekmesi) ──────────────────────────────────────
//
// Netflix tarzı yatay row'lar. Tek dikey ListView içinde her row bir bölüm.
// Boş row'lar gizlenir. TV D-pad: dikey ListView dikey geçişi yönetir,
// her horizontal row FocusTraversalGroup ile soldan sağa sıralı.

class _HomeRowsLayout extends StatelessWidget {
  final HomeState state;
  const _HomeRowsLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Android paritesi (HomeOverviewLayout): Devam Et → İzlediğin Filmler →
    // İzlediğin Diziler → Yeni Filmler → Yeni Diziler → Popüler → Yeni Kanallar.
    // Eski "homeRowRecentlyWatched" satırı kaldırıldı çünkü watchedMovies +
    // watchedSeriesEpisodes kombinasyonu aynı içeriği daha temiz tipte gösteriyor.
    final sections = <(String, List<ChannelModel>, _HomeCardStyle)>[
      if (state.continueWatching.isNotEmpty)
        (l.homeRowContinueWatching,   state.continueWatching,       _HomeCardStyle.poster),
      if (state.watchedMovies.isNotEmpty)
        (l.homeRowWatchedMovies,      state.watchedMovies,          _HomeCardStyle.poster),
      if (state.watchedSeriesEpisodes.isNotEmpty)
        (l.homeRowWatchedSeries,      state.watchedSeriesEpisodes,  _HomeCardStyle.poster),
      if (state.newlyAddedMovies.isNotEmpty)
        (l.homeRowNewMovies,          state.newlyAddedMovies,       _HomeCardStyle.poster),
      if (state.newlyAddedSeries.isNotEmpty)
        (l.homeRowNewSeries,          state.newlyAddedSeries,       _HomeCardStyle.poster),
      if (state.popularVodItems.isNotEmpty)
        (l.homeRowPopular,            state.popularVodItems,        _HomeCardStyle.poster),
      if (state.latestLive.isNotEmpty)
        (l.homeRowNewChannels,        state.latestLive,             _HomeCardStyle.logo),
    ];

    if (sections.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined,
                  size: 56, color: cs.onSurfaceVariant),
              const SizedBox(height: Spacing.md),
              Text(
                l.homeEmptyContent,
                style: TextStyle(
                    fontSize: TextSize.title,
                    color: cs.onSurface),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l.homeEmptyContentHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final hasBanner = state.featuredVodItems.isNotEmpty;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      itemCount: sections.length + (hasBanner ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
      itemBuilder: (ctx, i) {
        if (hasBanner && i == 0) {
          return _FeaturedBanner(items: state.featuredVodItems);
        }
        final (title, items, style) = sections[hasBanner ? i - 1 : i];
        return _HomeRow(title: title, items: items, style: style);
      },
    );
  }
}

// ── Featured banner (auto-advancing carousel) ────────────────────────────────
//
// Android paritesi (FeaturedBanner.kt): 15 sn'de otomatik geçen 16:9 cinematik
// kart. Üstünde gradient + tip badge (FİLM/DİZİ) + büyük başlık.
// Tap → mevcut player route'una yönlendirir (logo card ile aynı pattern).

class _FeaturedBanner extends StatefulWidget {
  final List<ChannelModel> items;
  const _FeaturedBanner({required this.items});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  static const _autoAdvance = Duration(seconds: 15);

  late final PageController _ctrl;
  Timer? _timer;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.92);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_ctrl.hasClients) return;
      final next = (_idx + 1) % widget.items.length;
      _ctrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve:    Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _FeaturedBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      // Item sayısı değişti — index'i sıfırla, timer'ı yeniden başlat.
      _idx = 0;
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller:    _ctrl,
            itemCount:     widget.items.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder:   (ctx, i) => _FeaturedCard(channel: widget.items[i]),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin:   const EdgeInsets.symmetric(horizontal: 3),
                width:    i == _idx ? 16 : 6,
                height:   6,
                decoration: BoxDecoration(
                  color: i == _idx
                      ? cs.primary
                      : cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ChannelModel channel;
  const _FeaturedCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l  = AppLocalizations.of(context);
    // 3 tip: movie (amber), series (mor), live (kırmızı)
    final (badge, badgeColor) = switch (channel.streamType) {
      'movie'  => (l.badgeMovieUppercase,  Colors.amber.shade700),
      'series' => (l.badgeSeriesUppercase, Colors.deepPurple.shade400),
      _        => (l.playerLiveLabel,       Colors.red.shade600),
    };
    // Dizi için seriesName, film/canlı için kanal adı
    final title = (channel.streamType == 'series' && channel.seriesName.isNotEmpty)
        ? channel.seriesName
        : channel.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: TvFocusableScale(
        borderRadius: BorderRadius.circular(Radius.card + 4),
        onTap: () => context.push(
          AppRoutes.player,
          extra: {
            'channelId':       channel.id,
            'channelUrl':      channel.streamUrl,
            'title':           channel.name,
            'initialPosition': channel.lastPosition,
            'streamType':      channel.streamType,
          },
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radius.card + 4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background poster — yoksa solid fallback rengi.
              if (channel.logoUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl:    channel.logoUrl,
                  fit:         BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: cs.surfaceContainerHighest),
                  errorWidget: (_, __, ___) =>
                      Container(color: cs.surfaceContainerHighest),
                )
              else
                Container(color: cs.surfaceContainerHighest),
              // Soldan-alt köşeye dramatik gradient — başlık okunabilirliği için.
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end:   Alignment.topRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.10),
                    ],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
              // Sol-alt: badge + başlık
              PositionedDirectional(
                start:  16,
                end:    16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize:   10,
                          fontWeight: FontWeight.bold,
                          color:      Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                        color:      Colors.white,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HomeCardStyle { poster, logo }

class _HomeRow extends StatelessWidget {
  final String             title;
  final List<ChannelModel> items;
  final _HomeCardStyle     style;

  const _HomeRow({
    required this.title,
    required this.items,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Poster: 120x180 (2/3 aspect), Logo: 140x80 (landscape)
    final itemWidth  = style == _HomeCardStyle.poster ? 120.0 : 140.0;
    final itemHeight = style == _HomeCardStyle.poster ? 200.0 : 110.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            title,
            style: TextStyle(
                fontSize:   TextSize.title,
                fontWeight: FontWeight.w600,
                color:      cs.onSurface),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: itemHeight,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount:       items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: Spacing.sm),
              itemBuilder: (ctx, i) => SizedBox(
                width: itemWidth,
                child: style == _HomeCardStyle.poster
                    ? _PosterCard(channel: items[i])
                    : _LogoCard(channel: items[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Canlı TV kanalları için landscape kart (logo + isim).
class _LogoCard extends StatelessWidget {
  final ChannelModel channel;
  const _LogoCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TvFocusableScale(
      borderRadius: BorderRadius.circular(Radius.card + 3),
      onTap: () => context.push(
        AppRoutes.player,
        extra: {
          'channelId':       channel.id,
          'channelUrl':      channel.streamUrl,
          'title':           channel.name,
          'initialPosition': channel.lastPosition,
          'streamType':      channel.streamType,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Radius.card),
            ),
            padding: const EdgeInsets.all(8),
            child: channel.logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl:    channel.logoUrl,
                    fit:         BoxFit.contain,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => Icon(Icons.live_tv,
                        color: cs.onSurfaceVariant, size: 28),
                  )
                : Icon(Icons.live_tv,
                    color: cs.onSurfaceVariant, size: 28),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: TextSize.caption),
            ),
          ),
        ],
      ),
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
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.channelItemHPad, Spacing.md, 0, Spacing.sm),
          child: Text(
            l.homeRecentlyWatchedHeader,
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
                    'channelId':       ch.id,
                    'channelUrl':      ch.streamUrl,
                    'title':           ch.name,
                    'initialPosition': ch.lastPosition,
                    'streamType':      ch.streamType,
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
          'channelId':       channel.id,
          'channelUrl':      channel.streamUrl,
          'title':           channel.name,
          'initialPosition': channel.lastPosition,
          'streamType':      channel.streamType,
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
    final l = AppLocalizations.of(context);

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
            Text(l.homeSearchEmpty,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }
    if (state.searchResults.isEmpty) {
      return Center(
          child: Text(l.homeSearchNoResults(state.searchQuery),
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
    final l = AppLocalizations.of(context);

    return Container(
      height:  Dimens.bottomBarHeight,
      color:   cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          Text(l.homeContentCount(state.channels.length),
              style: TextStyle(
                  fontSize: TextSize.caption,
                  color:    cs.onSurfaceVariant)),
          const Spacer(),
          // Sort (TV-friendly dialog)
          TextButton.icon(
            icon: Icon(Icons.sort, size: 18, color: cs.onSurfaceVariant),
            label: Text(_sortLabel(l, state.sortOrder),
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
    final l = AppLocalizations.of(context);
    final options = <(SortOrder, String)>[
      (SortOrder.defaultOrder, l.sortLabelDefault),
      (SortOrder.nameAsc,      l.sortLabelAZ),
      (SortOrder.nameDesc,     l.sortLabelZA),
    ];
    final result = await showDialog<SortOrder>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.sortDialogTitle),
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

  String _sortLabel(AppLocalizations l, SortOrder o) => switch (o) {
    SortOrder.nameAsc  => l.sortLabelShortAZ,
    SortOrder.nameDesc => l.sortLabelShortZA,
    _                  => l.sortLabelShort,
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

// ── Background loading bar ────────────────────────────────────────────────────
//
// _TopBar altında, _TabBar üstünde sadece state.isBackgroundLoading=true iken
// gözükür. İçerik altta korunur (full-screen spinner yerine non-blocking).

class _BackgroundLoadingBar extends StatelessWidget {
  final String? message;
  const _BackgroundLoadingBar({this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          if (message != null && message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: Text(
                      message!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: TextSize.caption,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
