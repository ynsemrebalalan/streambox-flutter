import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import '../../data/repositories/settings_repository.dart';
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
      // İlk açılışta Ana Sayfa sekmesi default: recentlyWatched + continueWatching
      // + yeni eklenen film/dizi/canlı row'larını paralel yükle.
      final repo = ref.read(channelRepoProvider);
      final results = await Future.wait<dynamic>([
        repo.getRecentlyWatched(id),
        repo.getContinueWatching(id),
        repo.getLatestByType(id, 'movie',  limit: 20),
        repo.getLatestByType(id, 'series', limit: 20),
        repo.getLatestByType(id, 'live',   limit: 20),
      ]);
      state = state.copyWith(
        recentlyWatched:  results[0] as List<ChannelModel>,
        continueWatching: results[1] as List<ChannelModel>,
        newlyAddedMovies: results[2] as List<ChannelModel>,
        newlyAddedSeries: results[3] as List<ChannelModel>,
        latestLive:       results[4] as List<ChannelModel>,
        isLoading:        false,
        clearError:       true,
      );
    }

    return state;
  }

  /// Ana Sayfa row'larını yeniden yükler (örn. yeni içerik eklenince).
  Future<HomeState> _loadHomeRows(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final repo = ref.read(channelRepoProvider);
    final results = await Future.wait<dynamic>([
      repo.getRecentlyWatched(s.activePlaylistId),
      repo.getContinueWatching(s.activePlaylistId),
      repo.getLatestByType(s.activePlaylistId, 'movie',  limit: 20),
      repo.getLatestByType(s.activePlaylistId, 'series', limit: 20),
      repo.getLatestByType(s.activePlaylistId, 'live',   limit: 20),
    ]);
    return s.copyWith(
      recentlyWatched:  results[0] as List<ChannelModel>,
      continueWatching: results[1] as List<ChannelModel>,
      newlyAddedMovies: results[2] as List<ChannelModel>,
      newlyAddedSeries: results[3] as List<ChannelModel>,
      latestLive:       results[4] as List<ChannelModel>,
    );
  }

  // ── Public actions ──────────────────────────────────────────────────────────

  Future<void> selectTab(String tab) async {
    final current = state.value;
    if (current == null) return;
    // isLoading:true → _ChannelList loader gösterir, "içerik yok" flash engellenir
    var next = current.copyWith(
      activeTab:           tab,
      selectedCategory:    '',
      favoritesTypeFilter: '',
      channels:            [],
      isLoading:           true,
    );
    state = AsyncData(next);
    if (tab == 'home') {
      // Ana Sayfa: kategori/channels yerine row'ları güncelle
      next = await _loadHomeRows(next);
      next = next.copyWith(
        categories: const [],
        isLoading: false,
        clearError: true,
      );
    } else {
      next = await _loadCategories(next);
      next = await _loadChannels(next);
    }
    state = AsyncData(next);
  }

  Future<void> selectCategory(String category) async {
    final current = state.value;
    if (current == null) return;
    var next = current.copyWith(
      selectedCategory: category,
      channels:         [],
      isLoading:        true,
    );
    state = AsyncData(next);
    next  = await _loadChannels(next);
    state = AsyncData(next);
  }

  /// Favoriler sekmesinde tip filtresini değiştirir ('', 'live', 'movie', 'series')
  Future<void> setFavoritesTypeFilter(String filter) async {
    final current = state.value;
    if (current == null) return;
    var next = current.copyWith(
      favoritesTypeFilter: filter,
      channels:            [],
      isLoading:           true,
    );
    state = AsyncData(next);
    next  = await _loadChannels(next);
    state = AsyncData(next);
  }

  /// CategoryFilterScreen'den dönüşte çağır: gizli kategori listesi değişmiş
  /// olabilir, mevcut tab'ı re-load et. reload()'dan farkı: tüm state'i
  /// sıfırdan kurmak yerine sadece liste fetch'i.
  Future<void> refreshVisibility() async {
    final current = state.value;
    if (current == null) return;
    var next = current.copyWith(isLoading: true);
    state = AsyncData(next);
    if (current.activeTab == 'home') {
      next = await _loadHomeRows(next);
      next = next.copyWith(isLoading: false, clearError: true);
    } else {
      next = await _loadCategories(next);
      next = await _loadChannels(next);
    }
    state = AsyncData(next);
  }

  void setSortOrder(SortOrder order) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(sortOrder: order));
  }

  Future<void> markWatched(String channelId, {int position = 0, int duration = 0}) async {
    await ref.read(channelRepoProvider)
        .updateWatched(channelId, position: position, duration: duration);
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

    var cats = await ref
        .read(channelRepoProvider)
        .getCategories(s.activePlaylistId, type);

    // Hidden categories'i filtrele.
    final hidden = await _hiddenCategories();
    if (hidden.isNotEmpty) {
      cats = cats.where((c) => !hidden.contains(c)).toList();
    }

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
      // Tip filtresi uygula (canlı/film/dizi ayrımı)
      if (s.favoritesTypeFilter.isNotEmpty) {
        channels = channels
            .where((c) => c.streamType == s.favoritesTypeFilter)
            .toList();
      }
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

    // Hidden categories filtresi uygula.
    final hidden = await _hiddenCategories();
    if (hidden.isNotEmpty) {
      channels = channels.where((c) => !hidden.contains(c.category)).toList();
    }

    return s.copyWith(channels: channels, isLoading: false, clearError: true);
  }

  Future<Set<String>> _hiddenCategories() async {
    try {
      final raw = await ref
          .read(settingsRepoProvider)
          .get(SettingsKeys.hiddenCategories);
      if (raw == null || raw.isEmpty) return {};
      return (jsonDecode(raw) as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  static String? _typeForTab(String tab) => switch (tab) {
    'live'   => 'live',
    'movie'  => 'movie',
    'series' => 'series',
    _        => null,
  };
}
