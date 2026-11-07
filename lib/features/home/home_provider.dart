import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/hidden_categories_repository.dart';
import '../../data/services/cloud_sync_service.dart';
import 'home_rows.dart';
import 'home_state.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  // Seçim (tab / kategori / favori filtresi / reload) istek sayacı. Her yeni
  // istek artırır; await sonrası id eskiyse sonuç atılır — yavaş gelen eski
  // kategori sonucu yeni seçimi ezmesin. 2026-11-03.
  int _selectionReq = 0;

  // Arama debounce — her tuşta DB sorgusu atılmasın.
  static const _searchDebounce  = Duration(milliseconds: 300);
  static const _minSearchLength = 2;
  Timer? _searchTimer;

  @override
  Future<HomeState> build() async {
    // Rebuild (playlist değişimi) bekleyen eski seçim/arama sonuçlarını geçersiz kılar.
    _selectionReq++;
    ref.onDispose(() => _searchTimer?.cancel());
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
      // 2026-05-11 lazy load: önce kritik 3 satır (fast ~500ms),
      // detaylı satırlar background'da yüklenir (Future.microtask).
      state = await _loadHomeRowsFast(state);
      state = state.copyWith(isLoading: false, clearError: true);

      // Background yüklemesi — UI hemen ilk içeriği gösterir,
      // diğer satırlar 1-2sn sonra otomatik düşer.
      // 2026-05-25: Race fix — detailed task sonucu fast state'i degil,
      // o ANDA mevcut state'i (latest) baz alip sadece detailed alanlari
      // overwrite eder. Aksi takdirde clearWatched / markWatched gibi
      // kullanici aksiyonlari detailed tamamlandiginda eziliyordu.
      Future.microtask(() async {
        try {
          final base = state;
          final detailed = await _loadHomeRowsDetailed(base);
          final latest = this.state.value;
          if (latest == null) return;
          this.state = AsyncData(latest.copyWith(
            newlyAddedMovies:      detailed.newlyAddedMovies,
            newlyAddedSeries:      detailed.newlyAddedSeries,
            watchedMovies:         detailed.watchedMovies,
            watchedSeriesEpisodes: detailed.watchedSeriesEpisodes,
            featuredVodItems:      detailed.featuredVodItems,
            popularVodItems:       detailed.popularVodItems,
          ));
        } catch (_) {
          // Detailed yükleme hatası kritik değil, fast state korunur.
        }
      });
    }

    return state;
  }

  /// FAST: ilk render için kritik 3 satır.
  /// continueWatching (kullanıcı son izlediği), latestLive (canlı), recentlyWatched.
  /// ~500ms — Home anında görünür.
  Future<HomeState> _loadHomeRowsFast(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final repo = ref.read(channelRepoProvider);
    final results = await Future.wait<dynamic>([
      repo.getRecentlyWatched(s.activePlaylistId),
      repo.getWatchedSeriesEpisodes(s.activePlaylistId, limit: 50),
      repo.getLatestByType(s.activePlaylistId, 'live', limit: 20),
    ]);
    // Android "Nerede Kaldım": dizi başına son bölüm, bitmişse sonrakine
    // ilerletilir. Filmler "İzlediğin Filmler" satırında (aynı içerik iki
    // satırda görünmez).
    final watchedSeries = (results[1] as List<ChannelModel>)
        .where((c) => c.seasonNumber > 0 || c.seriesName.isEmpty)
        .toList();
    final continueRow = await resolveContinueWatching(
        watchedSeries, repo.getNextEpisode);
    return s.copyWith(
      recentlyWatched:  results[0] as List<ChannelModel>,
      continueWatching: continueRow,
      latestLive:       results[2] as List<ChannelModel>,
    );
  }

  /// DETAILED: alt satırlar background'da. movie/series/watched/popular.
  /// ~1-2sn — kullanıcı zaten Home'da scroll etmeden tetiklenir.
  Future<HomeState> _loadHomeRowsDetailed(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final repo = ref.read(channelRepoProvider);
    final results = await Future.wait<dynamic>([
      repo.getLatestByType(s.activePlaylistId, 'movie',  limit: 20),
      repo.getLatestByType(s.activePlaylistId, 'series', limit: 20),
      repo.getWatchedMovies(s.activePlaylistId),
      repo.getWatchedSeriesEpisodes(s.activePlaylistId),
    ]);
    final newMovies = results[0] as List<ChannelModel>;
    final newSeries = results[1] as List<ChannelModel>;
    final deduped = _dedupNew(newMovies, newSeries);
    return s.copyWith(
      newlyAddedMovies:       newMovies,
      newlyAddedSeries:       newSeries,
      watchedMovies:          results[2] as List<ChannelModel>,
      watchedSeriesEpisodes:  results[3] as List<ChannelModel>,
      featuredVodItems:       deduped.take(10).toList(),
      popularVodItems:        deduped.length > 10
          ? deduped.skip(10).take(10).toList()
          : const [],
    );
  }

  /// Geriye uyumluluk wrapper — selectTab('home'), refreshVisibility, markWatched
  /// gibi yerler tek seferlik tam reload bekliyor. Fast + detailed sırayla.
  Future<HomeState> _loadHomeRows(HomeState s) async {
    final fast = await _loadHomeRowsFast(s);
    final detailed = await _loadHomeRowsDetailed(fast);
    return detailed;
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
    final req = ++_selectionReq;
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
    var rowsLoaded = false;
    if (tab == 'home') {
      next = await _loadHomeRows(next);
      rowsLoaded = true;
      next = next.copyWith(categories: const []);
    } else {
      // 2026-05-25: Movie/Series tab'inda "Son Eklenenler" seridi
      // newlyAddedMovies/newlyAddedSeries state'ine bagli — kullanici
      // direkt bu tab'a girerse henuz dolmamis olabilir. Bos ise detailed
      // load tetikle (UI bos serit yerine pas geçer).
      if ((tab == 'movie' && next.newlyAddedMovies.isEmpty) ||
          (tab == 'series' && next.newlyAddedSeries.isEmpty)) {
        next = await _loadHomeRowsDetailed(next);
        rowsLoaded = true;
      }
      next = await _loadCategories(next);
      next = await _loadChannels(next);
    }
    if (req != _selectionReq) return;
    final latest = state.value;
    if (latest == null) return;
    final base = rowsLoaded ? _mergeRows(latest, next) : latest;
    state = AsyncData(_mergeSelection(base, next));
  }

  Future<void> selectCategory(String category) async {
    final current = state.value;
    if (current == null) return;
    final req = ++_selectionReq;
    var next = current.copyWith(
      selectedCategory: category,
      channels:         [],
      isLoading:        true,
    );
    state = AsyncData(next);
    next  = await _loadChannels(next);
    _applySelection(req, next);
  }

  /// Favoriler sekmesinde tip filtresini değiştirir ('', 'live', 'movie', 'series')
  Future<void> setFavoritesTypeFilter(String filter) async {
    final current = state.value;
    if (current == null) return;
    final req = ++_selectionReq;
    var next = current.copyWith(
      favoritesTypeFilter: filter,
      channels:            [],
      isLoading:           true,
    );
    state = AsyncData(next);
    next  = await _loadChannels(next);
    _applySelection(req, next);
  }

  /// CategoryFilterScreen'den dönüşte çağır: gizli kategori listesi değişmiş
  /// olabilir, mevcut tab'ı re-load et. reload()'dan farkı: tüm state'i
  /// sıfırdan kurmak yerine sadece liste fetch'i.
  Future<void> refreshVisibility() async {
    final current = state.value;
    if (current == null) return;
    final req = ++_selectionReq;
    var next = current.copyWith(isLoading: true);
    state = AsyncData(next);
    if (current.activeTab == 'home') {
      next = await _loadHomeRows(next);
      if (req != _selectionReq) return;
      final latest = state.value ?? next;
      state = AsyncData(_mergeRows(latest, next)
          .copyWith(isLoading: false, clearError: true));
      return;
    }
    next = await _loadCategories(next);
    next = await _loadChannels(next);
    _applySelection(req, next);
  }

  /// Sync / başka ekrandaki değişiklik sonrası veriyi yeniden yükler; aktif
  /// tab, kategori, favori filtresi ve arama KORUNUR. `ref.invalidate` tüm
  /// state'i 'home'a sıfırlıyordu (kullanıcı raporu 2026-11-03).
  Future<void> reloadPreservingSelection() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    final req = ++_selectionReq;
    state = AsyncData(current.copyWith(isBackgroundLoading: true));
    try {
      final playlists = await ref.read(playlistRepoProvider).getAll();
      // Aktif playlist yoksa/silindiyse seçim anlamsız — sıfırdan kur.
      if (!playlists.any((p) => p.id == current.activePlaylistId)) {
        ref.invalidateSelf();
        return;
      }
      var loaded = current.copyWith(playlists: playlists);
      loaded = await _loadHomeRows(loaded);
      if (loaded.activeTab != 'home') {
        loaded = await _loadCategories(loaded);
        loaded = await _loadChannels(loaded);
      }
      final query = current.searchQuery;
      final results = query.length >= _minSearchLength
          ? await _searchVisible(loaded.activePlaylistId, query)
          : null;

      final latest = state.value ?? loaded;
      var merged = _mergeRows(latest, loaded)
          .copyWith(playlists: playlists, isBackgroundLoading: false);
      if (req == _selectionReq) merged = _mergeSelection(merged, loaded);
      if (results != null && latest.searchQuery == query) {
        merged = merged.copyWith(searchResults: results);
      }
      state = AsyncData(merged);
    } catch (_) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(isBackgroundLoading: false));
      }
    }
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
    // Await sırasında tab/kategori değişmiş olabilir — yalnız satırları uygula.
    final latest = state.value ?? refreshed;
    state = AsyncData(
        _mergeRows(latest, refreshed).copyWith(isBackgroundLoading: false));
  }

  /// Kanali izleme gecmisinden cikar — Son Izlenenler / Nerede Kaldim
  /// satirlarinda gozukmemesi icin. Optimistic update: ilgili satirlardan
  /// hemen kaldir, sonra arka planda DB re-fetch yap.
  Future<void> clearWatched(ChannelModel channel) async {
    final current = state.value;
    if (current == null) return;

    // 1) Optimistic UI guncelle.
    bool removeIf(ChannelModel c) => c.id == channel.id;
    final next = current.copyWith(
      recentlyWatched:       current.recentlyWatched.where((c) => !removeIf(c)).toList(),
      continueWatching:      current.continueWatching.where((c) => !removeIf(c)).toList(),
      watchedMovies:         current.watchedMovies.where((c) => !removeIf(c)).toList(),
      watchedSeriesEpisodes: current.watchedSeriesEpisodes.where((c) => !removeIf(c)).toList(),
    );
    state = AsyncData(next);

    // 2) DB + cloud sync.
    await ref.read(channelRepoProvider).clearWatched(channel.id);

    // 3) Sessiz arka plan re-fetch — diger satirlar tutarli kalsin.
    final refreshed = await _loadHomeRows(next);
    final latest = state.value ?? refreshed;
    state = AsyncData(_mergeRows(latest, refreshed));
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

    await applyFavoriteChange(channel.id, newFav);
  }

  /// Favori durumu değişti (bu notifier veya player'dan) — state yerinde
  /// güncellenir, tab/kategori/arama korunur. DB yazımı caller'dadır.
  Future<void> applyFavoriteChange(String channelId, bool isFavorite) async {
    final current = state.value;
    if (current == null) return;
    List<ChannelModel> upd(List<ChannelModel> list) => list
        .map((c) => c.id == channelId ? c.copyWith(isFavorite: isFavorite) : c)
        .toList();
    var next = current.copyWith(
      channels:              upd(current.channels),
      searchResults:         upd(current.searchResults),
      recentlyWatched:       upd(current.recentlyWatched),
      continueWatching:      upd(current.continueWatching),
      newlyAddedMovies:      upd(current.newlyAddedMovies),
      newlyAddedSeries:      upd(current.newlyAddedSeries),
      latestLive:            upd(current.latestLive),
      featuredVodItems:      upd(current.featuredVodItems),
      popularVodItems:       upd(current.popularVodItems),
      watchedMovies:         upd(current.watchedMovies),
      watchedSeriesEpisodes: upd(current.watchedSeriesEpisodes),
    );
    if (current.activeTab != 'favorites') {
      state = AsyncData(next);
      return;
    }
    // Favoriler tabindaysa ve favori kaldiriliyorsa → kanalı listeden cikar
    if (!isFavorite) {
      state = AsyncData(next.copyWith(
          channels: next.channels.where((c) => c.isFavorite).toList()));
      return;
    }
    state = AsyncData(next);
    // Yeni favori listede yoksa (player'dan eklendi) listeyi yeniden çek.
    if (next.channels.any((c) => c.id == channelId)) return;
    final req = ++_selectionReq;
    final loaded = await _loadChannels(next);
    _applySelection(req, loaded);
  }

  /// Arama: trim, en az 2 karakter (altı → sonuçlar temizlenir), 300ms
  /// debounce. Sonuç geldiğinde sorgu değişmişse bastırılmaz (race guard).
  Future<void> search(String query) async {
    final current = state.value;
    if (current == null) return;
    _searchTimer?.cancel();
    final q = query.trim();
    if (q.length < _minSearchLength) {
      state = AsyncData(current.copyWith(
          searchQuery: '', searchResults: [], isSearching: false));
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: q, isSearching: true));
    _searchTimer = Timer(_searchDebounce, () => _runSearch(q));
  }

  Future<void> _runSearch(String query) async {
    final current = state.value;
    if (current == null) return;
    try {
      final results = await _searchVisible(current.activePlaylistId, query);
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
      if (latest.searchQuery != query) return;
      state = AsyncData(latest.copyWith(
          searchResults: [], isSearching: false));
    }
  }

  /// Repo araması + listelerle aynı görünürlük kuralları (tab kategori
  /// filtresi + gizli kategoriler).
  Future<List<ChannelModel>> _searchVisible(
      String playlistId, String query) async {
    // Android: arama aktif sekmenin türünde (Tümü/Favoriler → hepsi).
    final tab = state.value?.activeTab ?? 'home';
    final results = await ref.read(channelRepoProvider).search(
        playlistId, query, streamType: searchStreamTypeForTab(tab));
    final hidden = await _hiddenCategories(playlistId);
    return results
        .where((c) => ChannelRepository.isChannelVisibleInSearch(c, hidden))
        .toList();
  }

  void clearSearch() {
    _searchTimer?.cancel();
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

  /// Seçim isteği hâlâ güncelse sonucu EN GÜNCEL state'e uygular.
  void _applySelection(int req, HomeState loaded) {
    if (req != _selectionReq) return;
    final latest = state.value;
    if (latest == null) return;
    state = AsyncData(_mergeSelection(latest, loaded));
  }

  /// Yalnız seçimle ilgili alanlar — arama, satırlar vs. latest'ten kalır.
  static HomeState _mergeSelection(HomeState latest, HomeState loaded) =>
      latest.copyWith(
        activeTab:           loaded.activeTab,
        selectedCategory:    loaded.selectedCategory,
        favoritesTypeFilter: loaded.favoritesTypeFilter,
        categories:          loaded.categories,
        channels:            loaded.channels,
        isLoading:           false,
        isBackgroundLoading: false,
        clearError:          true,
      );

  /// Yalnız ana sayfa satırları — seçim/arama latest'ten kalır.
  static HomeState _mergeRows(HomeState latest, HomeState loaded) =>
      latest.copyWith(
        recentlyWatched:       loaded.recentlyWatched,
        continueWatching:      loaded.continueWatching,
        latestLive:            loaded.latestLive,
        newlyAddedMovies:      loaded.newlyAddedMovies,
        newlyAddedSeries:      loaded.newlyAddedSeries,
        watchedMovies:         loaded.watchedMovies,
        watchedSeriesEpisodes: loaded.watchedSeriesEpisodes,
        featuredVodItems:      loaded.featuredVodItems,
        popularVodItems:       loaded.popularVodItems,
      );

  Future<HomeState> _loadCategories(HomeState s) async {
    if (s.activePlaylistId.isEmpty) return s;
    final type = _typeForTab(s.activeTab);
    if (type == null) return s.copyWith(categories: []);

    final repo = ref.read(channelRepoProvider);
    var cats = await repo.getCategories(s.activePlaylistId, type);

    // 2026-05-25: Movie tab kategori chip bar — tek-bolumlu "dizilerin"
    // kategorilerini de ekle (kullanici raporu: "1 bolumlu dizi olmaz,
    // bunlar film"). Distinct + sirali tut.
    if (type == 'movie') {
      final orphanCats = await repo.getOrphanSeriesCategories(s.activePlaylistId);
      if (orphanCats.isNotEmpty) {
        // Sağlayıcı sırası korunur (getCategories MIN(sortOrder) ile sıralı);
        // orphan kategoriler sona eklenir. Alfabetik sort kaldırıldı —
        // 2026-07-07 "TR en altta" şikayetinin aynısını yaratıyordu.
        cats = <String>{...cats, ...orphanCats}.toList();
      }
    }

    // Hidden categories'i filtrele.
    final hidden = await _hiddenCategories(s.activePlaylistId);
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
      // 2026-05-25: M3U providers bazi filmleri yanlislikla streamType=series
      // etiketliyor. Kural: ayni seriesName altinda yalniz 1 bolum varsa
      // bu aslinda bir film. Hicbir icerik kaybi olmasin diye:
      //   - Series tab: 2+ bolumlu diziler kalir
      //   - Movie tab: gercek movie + tek-bolumlu "dizi"ler birlikte gosterilir
      // seriesName'i bos olanlar zaten "tek baslarina" sayilir.
      if (type == 'series') {
        final epCount = <String, int>{};
        final hasContainer = <String>{};
        for (final c in channels) {
          final key = c.seriesName.isNotEmpty ? c.seriesName : c.id;
          epCount[key] = (epCount[key] ?? 0) + 1;
          if (c.isSeriesContainer) hasContainer.add(key);
        }
        // Xtream container'ı (bölümler lazy) tek satır olsa da dizidir.
        channels = channels.where((c) {
          final key = c.seriesName.isNotEmpty ? c.seriesName : c.id;
          return (epCount[key] ?? 0) >= 2 || hasContainer.contains(key);
        }).toList();
      } else if (type == 'movie') {
        // Movie tab'ina ek olarak tek-bolumlu "dizi"leri de ekle.
        final orphans = s.selectedCategory.isNotEmpty
            ? await repo.getOrphanSeriesAsMovies(
                s.activePlaylistId, category: s.selectedCategory)
            : await repo.getOrphanSeriesAsMovies(s.activePlaylistId);
        if (orphans.isNotEmpty) {
          // Dublicate koruma — ayni id varsa atlayalim (saglam DB integrity
          // varsa olmaz ama defansif).
          final seen = channels.map((c) => c.id).toSet();
          for (final o in orphans) {
            if (seen.add(o.id)) channels.add(o);
          }
        }
      }
      // Live için Dart-side priority sort (SQL CASE spinner takılmasına
      // neden oluyordu, sort buraya taşındı).
      if (type == 'live') {
        channels = ChannelRepository.sortLiveChannels(channels);
      }
    }

    // Hidden categories filtresi uygula.
    // v6: trim'li set — junction'da TRIM ile yazılı, kontrol da eşleşmeli.
    final hiddenRaw = await _hiddenCategories(s.activePlaylistId);
    if (hiddenRaw.isNotEmpty) {
      final hidden = hiddenRaw.map((e) => e.trim()).toSet();
      channels = channels
          .where((c) => !hidden.contains(c.category.trim()))
          .toList();
    }

    return s.copyWith(channels: channels, isLoading: false, clearError: true);
  }

  /// Aktif playlist'in gizli kategorileri (v9: playlist başına).
  Future<Set<String>> _hiddenCategories(String pid) async {
    try {
      return await HiddenCategoriesRepository(ref.read(settingsRepoProvider))
          .get(pid);
    } catch (_) {
      return {};
    }
  }

  /// Tüm izleme geçmişini temizler (Android Ayarlar → Geçmişi Temizle).
  /// Settings dalgası: onay diyaloğundan sonra bunu çağırır. Dönüş: satır sayısı.
  Future<int> clearAllWatchHistory() async {
    final n = await ref.read(channelRepoProvider).clearAllWatchHistory();
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(
        recentlyWatched: const [],
        continueWatching: const [],
        watchedMovies: const [],
        watchedSeriesEpisodes: const [],
      ));
    }
    await reloadPreservingSelection();
    return n;
  }

  /// Dizinin tamamını favorile / kaldır (Android toggleSeriesFavorite).
  /// Dönüş: yeni durum.
  Future<bool> toggleSeriesFavorite(String playlistId, String seriesName) async {
    final repo = ref.read(channelRepoProvider);
    final next = !await repo.isSeriesFavorite(playlistId, seriesName);
    await repo.setSeriesFavorite(playlistId, seriesName, next);
    final current = state.value;
    if (current != null) {
      List<ChannelModel> upd(List<ChannelModel> l) => l
          .map((c) => c.playlistId == playlistId && c.seriesName == seriesName
              ? c.copyWith(isFavorite: next)
              : c)
          .toList();
      state = AsyncData(current.copyWith(
        channels: upd(current.channels),
        searchResults: upd(current.searchResults),
        continueWatching: upd(current.continueWatching),
        newlyAddedSeries: upd(current.newlyAddedSeries),
        watchedSeriesEpisodes: upd(current.watchedSeriesEpisodes),
      ));
      if (current.activeTab == 'favorites') {
        await reloadPreservingSelection();
      }
    }
    return next;
  }

  static String? _typeForTab(String tab) => switch (tab) {
    'live'   => 'live',
    'movie'  => 'movie',
    'series' => 'series',
    _        => null,
  };
}
