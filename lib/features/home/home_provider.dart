import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/cloud_sync_service.dart';
import 'home_state.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // ref.watch → activePlaylistProvider değişimi otomatik rebuild tetikler.
    // 2026-05-11: ref.read kullanılıyordu, add() sonrası invalidate çalışsa
    // bile snapshot zamanı state stale olabiliyordu. watch ile reactive.
    final activeId     = ref.watch(activePlaylistProvider);
    final playlistRepo = ref.read(playlistRepoProvider);
    final playlists    = await playlistRepo.getAll();

    final id = activeId.isNotEmpty
        ? activeId
        : playlists.firstOrNull?.id ?? '';

    HomeState state = HomeState(
      playlists:        playlists,
      activePlaylistId: id,
    );

    if (id.isNotEmpty) {
      state = await _loadHomeRows(state);
      state = state.copyWith(isLoading: false, clearError: true);
    }

    return state;
  }

  /// Ana Sayfa row'larını yeniden yükler — `build()` ve `selectTab('home')` /
  /// `refreshVisibility()` tek noktadan beslenir, copy-paste edilmiş fetch
  /// listesi yok. 7 paralel sorgu + Popüler dilim hesaplaması burada.
  Future<HomeState> _loadHomeRows(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final repo = ref.read(channelRepoProvider);
    final results = await Future.wait<dynamic>([
      repo.getRecentlyWatched(s.activePlaylistId),                         // 0
      repo.getContinueWatching(s.activePlaylistId),                         // 1
      repo.getLatestByType(s.activePlaylistId, 'movie',  limit: 20),        // 2
      repo.getLatestByType(s.activePlaylistId, 'series', limit: 20),        // 3
      repo.getLatestByType(s.activePlaylistId, 'live',   limit: 20),        // 4
      repo.getWatchedMovies(s.activePlaylistId),                            // 5
      repo.getWatchedSeriesEpisodes(s.activePlaylistId),                    // 6
    ]);
    final newMovies = results[2] as List<ChannelModel>;
    final newSeries = results[3] as List<ChannelModel>;
    final newLive   = results[4] as List<ChannelModel>;
    // Featured banner SADECE film+dizi — Android HomeViewModel paritesi.
    // (Adım 10'da live eklenmişti, kullanıcı "üst slider'da canlı görünmesin"
    // dedi; Adım 19'da live geri çıkarıldı.)
    final deduped = _dedupNew(newMovies, newSeries);
    return s.copyWith(
      recentlyWatched:        results[0] as List<ChannelModel>,
      continueWatching:       results[1] as List<ChannelModel>,
      newlyAddedMovies:       newMovies,
      newlyAddedSeries:       newSeries,
      latestLive:             newLive,
      watchedMovies:          results[5] as List<ChannelModel>,
      watchedSeriesEpisodes:  results[6] as List<ChannelModel>,
      featuredVodItems:       deduped.take(10).toList(),
      popularVodItems:        deduped.length > 10
          ? deduped.skip(10).take(10).toList()
          : const [],
    );
  }

  /// Yeni eklenen film + dizi karışımını dedup'lar (live BANNER DIŞINDA —
  /// kullanıcı geri bildirimi "üst slider'da canlı görünmesin").
  ///   - Dizi: `seriesName` doluysa `S:{name}`
  ///   - Film: `streamUrl` doluysa `U:{url}`
  ///   - Diğer: `id` fallback
  /// Featured banner ilk 10'u alır, Popüler satırı sonraki 10'u.
  static List<ChannelModel> _dedupNew(
    List<ChannelModel> newMovies,
    List<ChannelModel> newSeries,
  ) {
    final combined = <ChannelModel>[...newMovies, ...newSeries];
    final seen = <String>{};
    final deduped = <ChannelModel>[];
    for (final ch in combined) {
      // Defansif: M3U parser bazı canlı kanalları yanlış streamType ile
      // sınıflandırırsa banner'a sızmasın. SQL filter zaten live'ı dışarıda
      // tutuyor ama parser hatası olası — burada da kapı kapalı olsun.
      if (ch.streamType == 'live') continue;
      // URL bazlı ek defans: Xtream `/live/` path'i veya M3U live tipik
      // uzantıları (`.ts`, `.m3u8`) — film/dizi diye etiketlenmiş live
      // kanallar buradan elenir. M3U VOD da `.m3u8` kullanabilir ama Xtream
      // VOD `/movie/` / `/series/` path'i taşır, bu yüzden path-bazlı
      // negatif filtre öncelikli.
      if (_looksLikeLiveByUrl(ch.streamUrl)) continue;
      final key = ch.streamType == 'series' && ch.seriesName.isNotEmpty
          ? 'S:${ch.seriesName}'
          : ch.streamUrl.isNotEmpty
              ? 'U:${ch.streamUrl}'
              : 'I:${ch.id}';
      if (seen.add(key)) deduped.add(ch);
    }
    return deduped;
  }

  static bool _looksLikeLiveByUrl(String url) {
    if (url.isEmpty) return false;
    final u = url.toLowerCase();
    // Xtream live path — kesin sinyal.
    if (u.contains('/live/')) return true;
    // Xtream VOD/series path varsa kesinlikle live değil.
    if (u.contains('/movie/') || u.contains('/series/')) return false;
    // M3U/genel: `.ts` veya `.m3u8` ile bitiyor ve VOD yolları taşımıyorsa
    // büyük ihtimal canlı yayın.
    if (u.endsWith('.ts') || u.endsWith('.m3u8')) return true;
    return false;
  }

  // ── Public actions ──────────────────────────────────────────────────────────

  Future<void> selectTab(String tab) async {
    final current = state.value;
    if (current == null) return;
    // 'home' sekmesinde full-screen spinner agresif görünüyor — içerik kalır,
    // üstte ince background bar yeterli (Android paritesi). Diğer tab'larda
    // mevcut isLoading:true akışı: _ChannelList loader gösterir, flash engellenir.
    final useBgBar = tab == 'home';
    var next = current.copyWith(
      activeTab:           tab,
      selectedCategory:    '',
      favoritesTypeFilter: '',
      channels:            useBgBar ? current.channels : [],
      isLoading:           !useBgBar,
      isBackgroundLoading: useBgBar,
    );
    state = AsyncData(next);
    if (tab == 'home') {
      next = await _loadHomeRows(next);
      next = next.copyWith(
        categories: const [],
        isLoading: false,
        isBackgroundLoading: false,
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
    final current = state.value;
    if (current == null || current.activePlaylistId.isEmpty) return;
    // Recently/Watched/Continue rows'larını paralel re-fetch et — kullanıcı bir
    // bölümü bitirdikten sonra Home'a dönünce satırlar güncel olur.
    state = AsyncData(current.copyWith(isBackgroundLoading: true));
    final refreshed = await _loadHomeRows(current);
    state = AsyncData(refreshed.copyWith(isBackgroundLoading: false));
  }

  Future<void> toggleFavorite(ChannelModel channel) async {
    final current = state.value;
    if (current == null) return;
    final newFav = !channel.isFavorite;
    await ref.read(channelRepoProvider).toggleFavorite(channel.id, newFav);

    // Cloud sync (Pro + authenticated): fire-and-forget; başarısız olsa
    // local zaten güncel, kullanıcı akışı kesilmez.
    // ignore: unawaited_futures
    CloudSyncService.pushFavorite(
        channel.copyWith(isFavorite: newFav),
        added: newFav);

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
    try {
      final results = await ref
          .read(channelRepoProvider)
          .search(current.activePlaylistId, query);
      // En son state.value'dan başla; kullanıcı hızlı yazınca arada başka
      // bir search() döndüyse onun query'sini ezme. Eski snapshot'a
      // copyWith etmek searchQuery'i '' yapıyordu (bug).
      final latest = state.value ?? current;
      // Yarış: bu await sırasında query değişti mi? Eski sonucu bastırma.
      if (latest.searchQuery != query) return;
      state = AsyncData(latest.copyWith(
          searchResults: results, isSearching: false));
    } catch (e) {
      // search() başarısız olsa isSearching takılı kalmasın.
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(
          searchResults: [], isSearching: false));
    }
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
      // 2026-05-11 v4: Kategori adı bazlı tab filter (Dart-side, hızlı).
      // Provider yanlış metadata savunması — "Aksiyon Filmleri" kategorili
      // bir kanal Live tab'a düşemez.
      channels = channels
          .where((c) => ChannelRepository.isChannelAllowedForTab(c, type))
          .toList();
      // Live için Dart-side priority sort (SQL CASE spinner takılmasına
      // neden oluyordu, sort buraya taşındı).
      if (type == 'live') {
        channels = ChannelRepository.sortLiveChannels(channels);
      }
    }

    // Hidden categories filtresi uygula.
    // v6: trim'li set — junction'da TRIM ile yazılı, kontrol da eşleşmeli.
    final hiddenRaw = await _hiddenCategories();
    if (hiddenRaw.isNotEmpty) {
      final hidden = hiddenRaw.map((e) => e.trim()).toSet();
      channels = channels
          .where((c) => !hidden.contains(c.category.trim()))
          .toList();
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
