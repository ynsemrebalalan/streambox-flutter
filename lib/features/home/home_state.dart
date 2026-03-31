import '../../data/models/channel_model.dart';
import '../../data/models/playlist_model.dart';

enum SortOrder { defaultOrder, nameAsc, nameDesc }

class HomeState {
  final List<PlaylistModel> playlists;
  final String              activePlaylistId;
  final String              activeTab;       // 'live' | 'movie' | 'series' | 'favorites'
  final List<String>        categories;
  final String              selectedCategory;
  final List<ChannelModel>  channels;
  final List<ChannelModel>  recentlyWatched;
  final bool                isLoading;
  final String?             error;
  final SortOrder           sortOrder;
  final String              searchQuery;
  final List<ChannelModel>  searchResults;
  final bool                isSearching;

  const HomeState({
    this.playlists          = const [],
    this.activePlaylistId   = '',
    this.activeTab          = 'live',
    this.categories         = const [],
    this.selectedCategory   = '',
    this.channels           = const [],
    this.recentlyWatched    = const [],
    this.isLoading          = false,
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
    List<ChannelModel>?  channels,
    List<ChannelModel>?  recentlyWatched,
    bool?                isLoading,
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
    channels:           channels         ?? this.channels,
    recentlyWatched:    recentlyWatched  ?? this.recentlyWatched,
    isLoading:          isLoading        ?? this.isLoading,
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
    'movie'     => 'Film',
    'series'    => 'Dizi',
    'favorites' => 'Favoriler',
    _           => 'Canlı',
  };
}
