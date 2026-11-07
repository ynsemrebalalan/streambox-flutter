import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/category_icons.dart';
import '../../core/utils/http_client.dart';
import '../../core/utils/tv_focus.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/poster_grid.dart';
import '../../core/widgets/poster_image.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/channel_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../parental/parental_guard.dart';
import '../playlists/playlists_screen.dart';
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
        body: SafeArea(child: ChannelListSkeleton()),
      ),
      error: (e, _) => Scaffold(
        body: SafeArea(
          child: EmptyState.error(
            title:       _homeErrorMessage(e, l),
            actionLabel: l.retry,
            onAction:    () => ref.invalidate(homeProvider),
          ),
        ),
      ),
      data: (state) => _buildMain(context, state),
    );
  }

  Widget _buildMain(BuildContext context, HomeState state) {
    final l = AppLocalizations.of(context);
    if (state.playlists.isEmpty) {
      return _NoPlaylistView();
    }

    // Arka plan = scaffoldBackgroundColor (diger ekranlarla ayni zemin).
    return Scaffold(
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
          // Playlist arka plan sync bilgi banner'ı (2026-05-11):
          // add() background sync yapıyor, kullanıcı dialog beklemiyor.
          // Active playlist'in sync durumunu bildiri olarak göster.
          Consumer(
            builder: (ctx, ref, _) {
              final notifier = ref.read(playlistsProvider.notifier);
              final activeId = state.activePlaylistId;
              if (activeId.isEmpty) return const SizedBox.shrink();
              final syncing = notifier.isSyncing(activeId);
              if (!syncing) return const SizedBox.shrink();
              return ValueListenableBuilder<String>(
                valueListenable: notifier.progressMessage,
                builder: (_, msg, __) {
                  if (msg.isEmpty && !syncing) return const SizedBox.shrink();
                  return _BackgroundLoadingBar(
                    message: msg.isEmpty ? l.homePlaylistSyncing : msg,
                  );
                },
              );
            },
          ),
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
          // Phase 5: Free user banner reklam — Pro user'da SizedBox.shrink().
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.live_tv, size: 80, color: cs.onSurfaceVariant),
                const SizedBox(height: Spacing.xl),
                Text(l.homeAppTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: Spacing.sm),
                Text(l.homeNoPlaylistMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant)),
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
          const SizedBox(width: Spacing.md),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );

bool get _isCupertino =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context);

    return Container(
      height:     Dimens.topBarHeight,
      padding:    const EdgeInsets.only(left: Spacing.lg, right: Spacing.xs),
      child: Row(
        children: [
          // Logo / title
          if (!showSearch)
            Flexible(
              fit: FlexFit.loose,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(Icons.live_tv,
                        color: AppPalette.of(context).accentText, size: 26),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(l.homeAppTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          if (showSearch)
            Expanded(
              child: TextField(
                controller:   searchCtrl,
                autofocus:    true,
                // Kanal adlarinda autocorrect/oneri yanlis kelimeye cevirir.
                autocorrect:        false,
                enableSuggestions:  false,
                textInputAction:    TextInputAction.search,
                onChanged:    onSearchChanged,
                style: theme.textTheme.bodyMedium,
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
            tooltip: showSearch ? l.close : l.homeSearchTooltip,
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchToggle,
          ),
          PopupMenuButton<String>(
            iconSize: 28,
            tooltip: l.homeMore,
            icon: Icon(_isCupertino ? CupertinoIcons.ellipsis : Icons.more_vert),
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
    final l = AppLocalizations.of(context);

    final tabs = <(String, String, IconData)>[
      ('home',      l.homeTabHome,      Icons.home),
      ('live',      l.homeTabLive,      Icons.live_tv),
      ('movie',     l.homeTabMovie,     Icons.movie),
      ('series',    l.homeTabSeries,    Icons.video_library),
      ('favorites', l.homeTabFavorites, Icons.star),
    ];

    return SizedBox(
      height: 44,
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
              onTap: () {
                if (!active) HapticFeedback.selectionClick();
                ref.read(homeProvider.notifier).selectTab(tab);
              },
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
      child: Semantics(
        selected: active,
        button: true,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _focused
                  ? cs.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon,
                          size: 16,
                          color: highlight
                              ? cs.primary
                              : cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: highlight
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: highlight
                                    ? cs.primary
                                    : cs.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: _focused ? 3 : 2,
                  color: highlight ? cs.primary : Colors.transparent,
                ),
              ],
            ),
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
              horizontal: Spacing.lg, vertical: 8),
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
              onTap:   () async {
                if (await ensureCategoryUnlocked(ctx, ref, cat)) {
                  if (!active) HapticFeedback.selectionClick();
                  ref.read(homeProvider.notifier).selectCategory(cat);
                }
              },
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = active ? cs.onPrimary : cs.onSurfaceVariant;
    final bg = active ? cs.primary : cs.surfaceContainerHigh;

    return TvFocusable(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
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
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
              horizontal: Spacing.lg, vertical: 6),
          itemCount:       filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            final (value, label, icon) = filters[i];
            final active = value == state.favoritesTypeFilter;
            return TvFocusable(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: () {
                if (!active) HapticFeedback.selectionClick();
                ref.read(homeProvider.notifier).setFavoritesTypeFilter(value);
              },
              semanticLabel: label,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? cs.primary : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 16,
                        color: active ? cs.onPrimary : cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(label,
                        style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w500,
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
      if (state.isLoading) return const _HomeRowsSkeleton();
      return _HomeRowsLayout(state: state);
    }

    if (state.isLoading) {
      return state.activeTab == 'movie' || state.activeTab == 'series'
          ? const PosterGridSkeleton()
          : const ChannelListSkeleton();
    }
    if (channels.isEmpty) {
      final l = AppLocalizations.of(context);
      final isFav = state.activeTab == 'favorites';
      final msg = isFav
          ? (state.favoritesTypeFilter.isEmpty
              ? l.homeEmptyFavorites
              : l.homeEmptyFavoritesType)
          : l.homeEmptyCategory;
      return EmptyState(
        icon:  isFav ? Icons.star_border_rounded : Icons.inbox_outlined,
        title: msg,
      );
    }

    final l = AppLocalizations.of(context);

    // Series: grouped view + üstte "Son Eklenenler" şeridi (Android paritesi)
    if (state.activeTab == 'series') {
      final newSeries = state.newlyAddedSeries;
      if (newSeries.isEmpty) {
        return SeriesSection(channels: channels);
      }
      return Column(
        children: [
          _NewlyAddedStrip(channels: newSeries, title: l.homeRowNewSeries),
          Expanded(child: SeriesSection(channels: channels)),
        ],
      );
    }

    // Movie: poster grid + üstte "Son Eklenenler" şeridi (Android paritesi)
    if (state.activeTab == 'movie') {
      final newMovies = state.newlyAddedMovies;
      final grid = PosterGridView(
        itemCount:   channels.length,
        itemBuilder: (ctx, i) => _PosterCard(channel: channels[i]),
      );
      if (newMovies.isEmpty) return grid;
      return Column(
        children: [
          _NewlyAddedStrip(channels: newMovies, title: l.homeRowNewMovies),
          Expanded(child: grid),
        ],
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
    //
    // `isHistory` flag: long-press uzun bas davranisini degistirir. History
    // satirlarinda (Devam Et, Izlediklerin) confirm dialog ile "Bu icerigi
    // silmek istiyor musun?" sorulur. Diger satirlarda eski favori toggle.
    final sections = <(String, List<ChannelModel>, _HomeCardStyle, bool)>[
      if (state.continueWatching.isNotEmpty)
        (l.homeRowContinueWatching,   state.continueWatching,       _HomeCardStyle.poster, true),
      if (state.watchedMovies.isNotEmpty)
        (l.homeRowWatchedMovies,      state.watchedMovies,          _HomeCardStyle.poster, true),
      // Dizi bölümleri "Nerede Kaldım"da (dizi başına tek kart, sonraki
      // bölüme ilerletilmiş) — ayrı "İzlediğin Diziler" satırı aynı diziyi
      // ikinci kez gösteriyordu (Android HomeOverviewLayout paritesi).
      if (state.newlyAddedMovies.isNotEmpty)
        (l.homeRowNewMovies,          state.newlyAddedMovies,       _HomeCardStyle.poster, false),
      if (state.newlyAddedSeries.isNotEmpty)
        (l.homeRowNewSeries,          state.newlyAddedSeries,       _HomeCardStyle.poster, false),
      if (state.popularVodItems.isNotEmpty)
        (l.homeRowPopular,            state.popularVodItems,        _HomeCardStyle.poster, false),
      if (state.latestLive.isNotEmpty)
        (l.homeRowNewChannels,        state.latestLive,             _HomeCardStyle.logo,   false),
    ];

    if (sections.isEmpty) {
      return EmptyState(
        icon:    Icons.home_outlined,
        title:   l.homeEmptyContent,
        message: l.homeEmptyContentHint,
      );
    }

    final hasBanner = state.featuredVodItems.isNotEmpty;
    return ListView.separated(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.lg),
      itemCount: sections.length + (hasBanner ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.xl),
      itemBuilder: (ctx, i) {
        if (hasBanner && i == 0) {
          return _FeaturedBanner(items: state.featuredVodItems);
        }
        final (title, items, style, isHistory) = sections[hasBanner ? i - 1 : i];
        return _HomeRow(
          title:     title,
          items:     items,
          style:     style,
          isHistory: isHistory,
        );
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

class _FeaturedCard extends ConsumerWidget {
  final ChannelModel channel;
  const _FeaturedCard({required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme   = Theme.of(context);
    final palette = AppPalette.of(context);
    final l  = AppLocalizations.of(context);
    // 3 tip: movie (amber), series (mor), live (kırmızı). Metin rengi her
    // zemin icin AA: amber+siyah 10.4:1 (eski beyaz 2.0:1), mor+beyaz 5.1:1.
    final (badge, badgeColor, badgeFg) = switch (channel.streamType) {
      'movie'  => (l.badgeMovieUppercase,  palette.proBadgeBg, palette.proBadgeFg),
      'series' => (l.badgeSeriesUppercase, const Color(0xFF6A45B8), Colors.white),
      _        => (l.playerLiveLabel,      palette.live,       palette.onLive),
    };
    // Dizi için seriesName, film/canlı için kanal adı
    final title = (channel.streamType == 'series' && channel.seriesName.isNotEmpty)
        ? channel.seriesName
        : channel.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: TvFocusableScale(
        borderRadius: BorderRadius.circular(AppRadius.card + 4),
        // Dizi → seri detay sheet'i (rastgele bolum degil); digerleri oynat.
        onTap: () => openSeries(context, ref, channel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card + 4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background poster — yoksa hash-gradient placeholder.
              PosterImage(
                url:   channel.logoUrl,
                seed:  title,
                width: MediaQuery.sizeOf(context).width,
              ),
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
                start:  Spacing.lg,
                end:    Spacing.lg,
                bottom: Spacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(AppRadius.badge),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:      badgeFg,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:      Colors.white,
                        shadows: const [
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

/// Long press ile favori toggle + SnackBar feedback. _LogoCard ve
/// _PosterCard'tan çağrılır. 2026-05-11 kullanıcı isteği.
void _toggleFavoriteWithFeedback(
    BuildContext context, WidgetRef ref, ChannelModel channel) {
  final l = AppLocalizations.of(context);
  final newFav = !channel.isFavorite;
  HapticFeedback.mediumImpact();
  ref.read(homeProvider.notifier).toggleFavorite(channel);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(newFav
          ? l.homeFavoriteAdded(channel.name)
          : l.homeFavoriteRemoved(channel.name)),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// "Son Izlenenler" / "Nerede Kaldim" / "Izlediklerin" satirlarinda uzun
/// basma -> onay dialog -> izleme gecmisinden cikar. 2026-05-25.
Future<void> _confirmClearWatched(
    BuildContext context, WidgetRef ref, ChannelModel channel) async {
  final l = AppLocalizations.of(context);
  HapticFeedback.mediumImpact();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.homeRemoveFromHistoryTitle),
      content: Text(l.homeRemoveFromHistoryMessage(channel.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.homeRemoveFromHistoryAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(homeProvider.notifier).clearWatched(channel);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.homeRemoveFromHistorySnack(channel.name)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HomeRow extends StatelessWidget {
  final String             title;
  final List<ChannelModel> items;
  final _HomeCardStyle     style;
  /// True ise long-press "izleme gecmisinden cikar" davranisi,
  /// false ise "favori toggle".
  final bool               isHistory;

  const _HomeRow({
    required this.title,
    required this.items,
    required this.style,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    // Poster: posterW (2:3 gorsel + sabit caption), Logo: 140 landscape.
    final posterW = Dimens.posterWidthFor(MediaQuery.sizeOf(context).shortestSide);
    final itemWidth  = style == _HomeCardStyle.poster ? posterW : 140.0;
    final itemHeight = style == _HomeCardStyle.poster
        ? Dimens.posterTileHeight(posterW, textScale: scale)
        : 72 + 4 + 20 * scale.clamp(1.0, 1.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: itemHeight,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              itemCount:       items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: Spacing.sm),
              itemBuilder: (ctx, i) => SizedBox(
                width: itemWidth,
                child: style == _HomeCardStyle.poster
                    ? _PosterCard(channel: items[i], isHistory: isHistory)
                    : _LogoCard(channel: items[i], isHistory: isHistory),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Canlı TV kanalları için landscape kart (logo + isim).
class _LogoCard extends ConsumerWidget {
  final ChannelModel channel;
  final bool         isHistory;
  const _LogoCard({required this.channel, this.isHistory = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return TvFocusableScale(
      borderRadius: BorderRadius.circular(AppRadius.card + 3),
      onTap: () => openChannelGuarded(context, ref, channel),
      onLongPress: () => isHistory
          ? _confirmClearWatched(context, ref, channel)
          : _toggleFavoriteWithFeedback(context, ref, channel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            padding: const EdgeInsets.all(8),
            child: channel.logoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl:       channel.logoUrl,
                    fit:            BoxFit.contain,
                    memCacheWidth:  (140 * dpr).round(),
                    fadeInDuration: const Duration(milliseconds: 180),
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
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recently watched strip ────────────────────────────────────────────────────

class _RecentlyWatchedStrip extends ConsumerWidget {
  final List<ChannelModel> channels;
  const _RecentlyWatchedStrip({required this.channels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.channelItemHPad, Spacing.md, 0, Spacing.sm),
          child: Semantics(
            header: true,
            child: Text(
              l.homeRecentlyWatchedHeader,
              style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight:  FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurfaceVariant),
            ),
          ),
        ),
        SizedBox(
          height: 52 + 4 + 18 * scale + 4,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            itemCount: channels.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
            itemBuilder: (ctx, i) {
              final ch = channels[i];
              return TvFocusable(
                borderRadius: BorderRadius.circular(AppRadius.cardSm + 3),
                onTap: () => openChannelGuarded(context, ref, ch),
                onLongPress: () => _confirmClearWatched(context, ref, ch),
                semanticLabel: ch.name,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.cardSm),
                      child: SizedBox(
                        width:  52,
                        height: 52,
                        child: ch.logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ch.logoUrl,
                                fit:      BoxFit.cover,
                                memCacheWidth: (52 *
                                        MediaQuery.devicePixelRatioOf(context))
                                    .round(),
                                fadeInDuration:
                                    const Duration(milliseconds: 180),
                                errorWidget: (_, __, ___) => Container(
                                  color: cs.surfaceContainerHigh,
                                  child: Icon(Icons.live_tv,
                                      color: cs.onSurfaceVariant),
                                ),
                              )
                            : Container(
                                color: cs.surfaceContainerHigh,
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
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w400),
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

// ── Newly added strip (Film/Dizi tab başlığı) ────────────────────────────────
//
// 2026-05-25: Android paritesi (VodHorizontalRow) — Movie ve Series tab'larında
// kategori chip bar'ın altında "Son Eklenenler" başlıklı yatay poster şeridi.
// Kullanıcı kategori seçse bile şerit kalır (kategoriden bağımsız bir alan).

class _NewlyAddedStrip extends StatelessWidget {
  final List<ChannelModel> channels;
  /// Başlık türü: 'movie' → "Yeni Filmler", 'series' → "Yeni Diziler".
  final String title;
  const _NewlyAddedStrip({required this.channels, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final posterW = Dimens.posterWidthFor(MediaQuery.sizeOf(context).shortestSide);
    // Maks 20 öğe — şerit asırı uzun olmasın; tam liste zaten alttaki grid'de.
    final items = channels.take(20).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight:  FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppPalette.of(context).accentText),
            ),
          ),
        ),
        SizedBox(
          height: Dimens.posterTileHeight(posterW, textScale: scale),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
              itemBuilder: (ctx, i) => SizedBox(
                width: posterW,
                child: _PosterCard(channel: items[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        const Divider(height: 1),
      ],
    );
  }
}

// ── Poster card (VOD) ─────────────────────────────────────────────────────────

class _PosterCard extends ConsumerWidget {
  final ChannelModel channel;
  final bool         isHistory;
  const _PosterCard({required this.channel, this.isHistory = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // History satirlari (Devam Et, Izlediklerin) bolumu dogrudan acar;
    // diger satirlarda dizi karti seri sheet'ini acar ve dizi adini gosterir.
    final asSeries = !isHistory &&
        channel.streamType == 'series' &&
        channel.seriesName.isNotEmpty;
    final title = asSeries ? channel.seriesName : channel.name;

    return TvFocusableScale(
      borderRadius: BorderRadius.circular(AppRadius.card + 3),
      onTap: () => asSeries
          ? openSeries(context, ref, channel)
          : openChannelGuarded(context, ref, channel),
      onLongPress: () => isHistory
          ? _confirmClearWatched(context, ref, channel)
          : _toggleFavoriteWithFeedback(context, ref, channel),
      // Gorsel her yerde 2:3, caption sabit yukseklik — grid/row/strip ayni.
      child: Semantics(
        label: title,
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
                    url:   channel.logoUrl,
                    seed:  title,
                    width: c.maxWidth,
                  ),
                ),
              ),
            ),
            Expanded(child: PosterCaption(title)),
          ],
        ),
      ),
    );
  }
}

/// Ana Sayfa yuklenirken: bir poster seridi + kanal satirlari iskeleti.
class _HomeRowsSkeleton extends StatelessWidget {
  const _HomeRowsSkeleton();

  @override
  Widget build(BuildContext context) {
    final posterW =
        Dimens.posterWidthFor(MediaQuery.sizeOf(context).shortestSide);
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: SkeletonBox(height: 180, radius: AppRadius.lg),
          ),
          for (var row = 0; row < 2; row++) ...[
            const SizedBox(height: Spacing.xl),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 140, height: 16),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            SizedBox(
              height: Dimens.posterTileHeight(posterW),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                itemBuilder: (_, __) => PosterSkeleton(width: posterW),
              ),
            ),
          ],
        ],
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
    final l = AppLocalizations.of(context);

    if (state.isSearching) {
      return const ChannelListSkeleton(rows: 6);
    }
    if (state.searchQuery.isEmpty) {
      return EmptyState(icon: Icons.search, title: l.homeSearchEmpty);
    }
    if (state.searchResults.isEmpty) {
      return EmptyState(
        icon:  Icons.search_off_rounded,
        title: l.homeSearchNoResults(state.searchQuery),
      );
    }

    return ListView.builder(
      // Kaydirinca klavye kapansin — sonuclar klavyenin altinda kalmasin.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount:   state.searchResults.length,
      // Dizi sonuclari seriesName basina tek satir → seri sheet'i acar.
      itemBuilder: (ctx, i) => ChannelListItem(
        channel:          state.searchResults[i],
        openSeriesDetail: true,
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final HomeState state;
  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context);

    // Home indicator alani: SafeArea(bottom:false) ust seviyede; bar kendi
    // alt boslugunu ekler, icerik gesture cubugunun altinda kalmaz.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      height:  Dimens.bottomBarHeight + bottomInset,
      padding: EdgeInsets.only(
          left: Spacing.lg, right: Spacing.sm, bottom: bottomInset),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(l.homeContentCount(state.channels.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: cs.onSurfaceVariant)),
          ),
          const Spacer(),
          // Sort (TV-friendly dialog)
          TextButton.icon(
            icon: Icon(Icons.sort, size: 18, color: cs.onSurfaceVariant),
            label: Text(_sortLabel(l, state.sortOrder),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
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
      if (result != state.sortOrder) HapticFeedback.selectionClick();
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
    final cs = Theme.of(context).colorScheme;
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
              ? cs.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(
                  widget.selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: cs.primary),
              const SizedBox(width: 12),
              Flexible(
                child: Text(widget.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            _focused ? FontWeight.w600 : FontWeight.w400)),
              ),
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
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
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
