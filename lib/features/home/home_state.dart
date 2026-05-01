import '../../data/models/channel_model.dart';
import '../../data/models/playlist_model.dart';

enum SortOrder { defaultOrder, nameAsc, nameDesc }

class HomeState {
  final List<PlaylistModel> playlists;
  final String              activePlaylistId;
  final String              activeTab;       // 'home' | 'live' | 'movie' | 'series' | 'favorites'
  final List<String>        categories;
  final String              selectedCategory;
  /// Favoriler sekmesindeyken tip filtresi: '' (tümü) | 'live' | 'movie' | 'series'
  final String              favoritesTypeFilter;
  final List<ChannelModel>  channels;
  final List<ChannelModel>  recentlyWatched;
  // ── Ana Sayfa row'ları ───────────────────────────────────────────────────
  /// Dizi bölümleri için devam ettirilebilir olanlar
  final List<ChannelModel>  continueWatching;
  /// En son eklenen filmler (rowid DESC)
  final List<ChannelModel>  newlyAddedMovies;
  /// En son eklenen dizi bölümleri
  final List<ChannelModel>  newlyAddedSeries;
  /// En son eklenen canlı kanallar
  final List<ChannelModel>  latestLive;
  /// "Featured" cinematik banner — newlyAdded film+dizi karışımının ilk 10 dilimi (Android paritesi)
  final List<ChannelModel>  featuredVodItems;
  /// "Popüler" satırı — newlyAdded film+dizi karışımının 11-20 dilimi (Android paritesi)
  final List<ChannelModel>  popularVodItems;
  /// Sadece film tipi izlenmiş kanallar (lastWatched DESC)
  final List<ChannelModel>  watchedMovies;
  /// Sadece dizi bölümü tipi izlenmiş kayıtlar (lastWatched DESC)
  final List<ChannelModel>  watchedSeriesEpisodes;
  final bool                isLoading;
  /// Üstte ince bir progress + status text gösterilirken `true` — refresh/sync sırasında
  final bool                isBackgroundLoading;
  /// Background loader yanında gösterilecek kısa mesaj ("EPG indiriliyor...")
  final String?             loadingMessage;
  final String?             error;
  final SortOrder           sortOrder;
  final String              searchQuery;
  final List<ChannelModel>  searchResults;
  final bool                isSearching;

  const HomeState({
    this.playlists          = const [],
    this.activePlaylistId   = '',
    this.activeTab          = 'home',
    this.categories         = const [],
    this.selectedCategory   = '',
    this.favoritesTypeFilter = '',
    this.channels           = const [],
    this.recentlyWatched    = const [],
    this.continueWatching   = const [],
    this.newlyAddedMovies   = const [],
    this.newlyAddedSeries   = const [],
    this.latestLive         = const [],
    this.featuredVodItems      = const [],
    this.popularVodItems       = const [],
    this.watchedMovies         = const [],
    this.watchedSeriesEpisodes = const [],
    this.isLoading          = false,
    this.isBackgroundLoading = false,
    this.loadingMessage,
    this.error,
    this.sortOrder          = SortOrder.defaultOrder,
    this.searchQuery        = '',
    this.searchResults      = const [],
    this.isSearching        = false,
  });

  HomeState copyWith({
    List<PlaylistModel>? playlists,
    String?              activePlaylistId,
    String?              activeTab,
    List<String>?        categories,
    String?              selectedCategory,
    String?              favoritesTypeFilter,
    List<ChannelModel>?  channels,
    List<ChannelModel>?  recentlyWatched,
    List<ChannelModel>?  continueWatching,
    List<ChannelModel>?  newlyAddedMovies,
    List<ChannelModel>?  newlyAddedSeries,
    List<ChannelModel>?  latestLive,
    List<ChannelModel>?  featuredVodItems,
    List<ChannelModel>?  popularVodItems,
    List<ChannelModel>?  watchedMovies,
    List<ChannelModel>?  watchedSeriesEpisodes,
    bool?                isLoading,
    bool?                isBackgroundLoading,
    String?              loadingMessage,
    bool                 clearLoadingMessage = false,
    String?              error,
    bool                 clearError = false,
    SortOrder?           sortOrder,
    String?              searchQuery,
    List<ChannelModel>?  searchResults,
    bool?                isSearching,
  }) => HomeState(
    playlists:          playlists        ?? this.playlists,
    activePlaylistId:   activePlaylistId ?? this.activePlaylistId,
    activeTab:          activeTab        ?? this.activeTab,
    categories:         categories       ?? this.categories,
    selectedCategory:   selectedCategory ?? this.selectedCategory,
    favoritesTypeFilter: favoritesTypeFilter ?? this.favoritesTypeFilter,
    channels:           channels         ?? this.channels,
    recentlyWatched:    recentlyWatched  ?? this.recentlyWatched,
    continueWatching:   continueWatching ?? this.continueWatching,
    newlyAddedMovies:   newlyAddedMovies ?? this.newlyAddedMovies,
    newlyAddedSeries:   newlyAddedSeries ?? this.newlyAddedSeries,
    latestLive:         latestLive       ?? this.latestLive,
    featuredVodItems:      featuredVodItems      ?? this.featuredVodItems,
    popularVodItems:       popularVodItems       ?? this.popularVodItems,
    watchedMovies:         watchedMovies         ?? this.watchedMovies,
    watchedSeriesEpisodes: watchedSeriesEpisodes ?? this.watchedSeriesEpisodes,
    isLoading:          isLoading        ?? this.isLoading,
    isBackgroundLoading: isBackgroundLoading ?? this.isBackgroundLoading,
    loadingMessage:     clearLoadingMessage ? null : loadingMessage ?? this.loadingMessage,
    error:              clearError ? null : error ?? this.error,
    sortOrder:          sortOrder        ?? this.sortOrder,
    searchQuery:        searchQuery      ?? this.searchQuery,
    searchResults:      searchResults    ?? this.searchResults,
    isSearching:        isSearching      ?? this.isSearching,
  );

  List<ChannelModel> get sortedChannels => switch (sortOrder) {
    SortOrder.nameAsc  => [...channels]..sort((a, b) => a.name.compareTo(b.name)),
    SortOrder.nameDesc => [...channels]..sort((a, b) => b.name.compareTo(a.name)),
    SortOrder.defaultOrder => channels,
  };

  String get activeTabLabel => switch (activeTab) {
    'home'      => 'Ana Sayfa',
    'live'      => 'Canlı',
    'movie'     => 'Film',
    'series'    => 'Dizi',
    'favorites' => 'Favoriler',
    _           => '',
  };
}
