import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import 'home_state.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final playlistRepo = ref.read(playlistRepoProvider);
    final playlists    = await playlistRepo.getAll();
    final activeId     = ref.read(activePlaylistProvider);

    final id = activeId.isNotEmpty
        ? activeId
        : playlists.firstOrNull?.id ?? '';

    HomeState state = HomeState(
      playlists:        playlists,
      activePlaylistId: id,
    );

    if (id.isNotEmpty) {
      // Paralel yukle: categories + channels + recentlyWatched ayni anda.
      // Sequential'dan ~3x hizli home ekran acilmasi.
      final type = _typeForTab(state.activeTab);
      final repo = ref.read(channelRepoProvider);
      final results = await Future.wait<dynamic>([
        if (type != null) repo.getCategories(id, type) else Future.value(<String>[]),
        if (type != null) repo.getByType(id, type) else Future.value(<ChannelModel>[]),
        repo.getRecentlyWatched(id),
      ]);
      final cats     = results[0] as List<String>;
      final channels = results[1] as List<ChannelModel>;
      final recent   = results[2] as List<ChannelModel>;
      final selected = cats.contains(state.selectedCategory)
          ? state.selectedCategory
          : (cats.firstOrNull ?? '');
      state = state.copyWith(
        categories:       cats,
        selectedCategory: selected,
        channels:         channels,
        recentlyWatched:  recent,
        isLoading:        false,
        clearError:       true,
      );
    }

    return state;
  }

  // ── Public actions ──────────────────────────────────────────────────────────

  Future<void> selectTab(String tab) async {
    final current = state.value;
    if (current == null) return;
    var next = current.copyWith(
      activeTab:        tab,
      selectedCategory: '',
      channels:         [],
    );
    state = AsyncData(next);
    next = await _loadCategories(next);
    next = await _loadChannels(next);
    state = AsyncData(next);
  }

  Future<void> selectCategory(String category) async {
    final current = state.value;
    if (current == null) return;
    var next = current.copyWith(selectedCategory: category, channels: []);
    state = AsyncData(next);
    next  = await _loadChannels(next);
    state = AsyncData(next);
  }

  void setSortOrder(SortOrder order) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(sortOrder: order));
  }

  Future<void> markWatched(String channelId, {int position = 0}) async {
    await ref.read(channelRepoProvider)
        .updateWatched(channelId, position: position);
    // Refresh recently watched list
    final current = state.value;
    if (current == null || current.activePlaylistId.isEmpty) return;
    final recent = await ref
        .read(channelRepoProvider)
        .getRecentlyWatched(current.activePlaylistId);
    state = AsyncData(current.copyWith(recentlyWatched: recent));
  }

  Future<void> toggleFavorite(ChannelModel channel) async {
    final current = state.value;
    if (current == null) return;
    final newFav = !channel.isFavorite;
    await ref.read(channelRepoProvider).toggleFavorite(channel.id, newFav);

    // channels listesini guncelle
    final updated = current.channels.map((c) =>
        c.id == channel.id ? c.copyWith(isFavorite: newFav) : c).toList();

    // searchResults listesini de guncelle (arama sonuclarinda favori)
    final updatedSearch = current.searchResults.map((c) =>
        c.id == channel.id ? c.copyWith(isFavorite: newFav) : c).toList();

    // Favoriler tabindaysa ve favori kaldiriliyorsa → kanalı listeden cikar
    if (current.activeTab == 'favorites' && !newFav) {
      final filtered = updated.where((c) => c.isFavorite).toList();
      state = AsyncData(current.copyWith(
          channels: filtered, searchResults: updatedSearch));
    } else {
      state = AsyncData(current.copyWith(
          channels: updated, searchResults: updatedSearch));
    }
  }

  Future<void> search(String query) async {
    final current = state.value;
    if (current == null) return;
    if (query.isEmpty) {
      state = AsyncData(current.copyWith(
          searchQuery: '', searchResults: [], isSearching: false));
      return;
    }
    state = AsyncData(current.copyWith(
        searchQuery: query, isSearching: true));
    final results = await ref
        .read(channelRepoProvider)
        .search(current.activePlaylistId, query);
    state = AsyncData(current.copyWith(
        searchResults: results, isSearching: false));
  }

  void clearSearch() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
        searchQuery: '', searchResults: [], isSearching: false));
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<HomeState> _loadCategories(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final type = _typeForTab(s.activeTab);
    if (type == null) return s.copyWith(categories: []);

    final cats = await ref
        .read(channelRepoProvider)
        .getCategories(s.activePlaylistId, type);
    final selected = cats.contains(s.selectedCategory)
        ? s.selectedCategory
        : (cats.firstOrNull ?? '');
    return s.copyWith(categories: cats, selectedCategory: selected);
  }

  Future<HomeState> _loadChannels(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;

    final repo = ref.read(channelRepoProvider);
    List<ChannelModel> channels;

    if (s.activeTab == 'favorites') {
      channels = await repo.getFavorites(s.activePlaylistId);
    } else {
      final type = _typeForTab(s.activeTab);
      if (type == null) return s;
      if (s.selectedCategory.isNotEmpty) {
        channels = await repo.getByCategory(
            s.activePlaylistId, type, s.selectedCategory);
      } else {
        channels = await repo.getByType(s.activePlaylistId, type);
      }
    }
    return s.copyWith(channels: channels, isLoading: false, clearError: true);
  }

  static String? _typeForTab(String tab) => switch (tab) {
    'live'   => 'live',
    'movie'  => 'movie',
    'series' => 'series',
    _        => null,
  };
}
