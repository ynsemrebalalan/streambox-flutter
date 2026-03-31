class ChannelModel {
  final String id;
  final String playlistId;
  final String name;
  final String streamUrl;
  final String logoUrl;
  final String category;
  final String streamType; // 'live' | 'movie' | 'series'
  final bool isFavorite;
  final int lastWatched;
  final int lastPosition;
  final String seriesName;
  final int seasonNumber;
  final int episodeNumber;
  final int sortOrder;
  final String tvgId;
  final int addedAt;
  final bool isWatched;
  final int duration;

  const ChannelModel({
    required this.id,
    required this.playlistId,
    required this.name,
    required this.streamUrl,
    this.logoUrl = '',
    this.category = 'Genel',
    this.streamType = 'live',
    this.isFavorite = false,
    this.lastWatched = 0,
    this.lastPosition = 0,
    this.seriesName = '',
    this.seasonNumber = 0,
    this.episodeNumber = 0,
    this.sortOrder = 0,
    this.tvgId = '',
    int? addedAt,
    this.isWatched = false,
    this.duration = 0,
  }) : addedAt = addedAt ?? 0;

  factory ChannelModel.fromMap(Map<String, dynamic> map) => ChannelModel(
        id:            map['id'] as String,
        playlistId:    map['playlistId'] as String,
        name:          map['name'] as String,
        streamUrl:     map['streamUrl'] as String,
        logoUrl:       map['logoUrl'] as String? ?? '',
        category:      map['category'] as String? ?? 'Genel',
        streamType:    map['streamType'] as String? ?? 'live',
        isFavorite:    (map['isFavorite'] as int? ?? 0) == 1,
        lastWatched:   map['lastWatched'] as int? ?? 0,
        lastPosition:  map['lastPosition'] as int? ?? 0,
        seriesName:    map['seriesName'] as String? ?? '',
        seasonNumber:  map['seasonNumber'] as int? ?? 0,
        episodeNumber: map['episodeNumber'] as int? ?? 0,
        sortOrder:     map['sortOrder'] as int? ?? 0,
        tvgId:         map['tvgId'] as String? ?? '',
        addedAt:       map['addedAt'] as int? ?? 0,
        isWatched:     (map['isWatched'] as int? ?? 0) == 1,
        duration:      map['duration'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id':            id,
        'playlistId':    playlistId,
        'name':          name,
        'streamUrl':     streamUrl,
        'logoUrl':       logoUrl,
        'category':      category,
        'streamType':    streamType,
        'isFavorite':    isFavorite ? 1 : 0,
        'lastWatched':   lastWatched,
        'lastPosition':  lastPosition,
        'seriesName':    seriesName,
        'seasonNumber':  seasonNumber,
        'episodeNumber': episodeNumber,
        'sortOrder':     sortOrder,
        'tvgId':         tvgId,
        'addedAt':       addedAt,
        'isWatched':     isWatched ? 1 : 0,
        'duration':      duration,
      };

  ChannelModel copyWith({
    String? id,
    String? playlistId,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? category,
    String? streamType,
    bool? isFavorite,
    int? lastWatched,
    int? lastPosition,
    String? seriesName,
    int? seasonNumber,
    int? episodeNumber,
    int? sortOrder,
    String? tvgId,
    int? addedAt,
    bool? isWatched,
    int? duration,
  }) =>
      ChannelModel(
        id:            id            ?? this.id,
        playlistId:    playlistId    ?? this.playlistId,
        name:          name          ?? this.name,
        streamUrl:     streamUrl     ?? this.streamUrl,
        logoUrl:       logoUrl       ?? this.logoUrl,
        category:      category      ?? this.category,
        streamType:    streamType    ?? this.streamType,
        isFavorite:    isFavorite    ?? this.isFavorite,
        lastWatched:   lastWatched   ?? this.lastWatched,
        lastPosition:  lastPosition  ?? this.lastPosition,
        seriesName:    seriesName    ?? this.seriesName,
        seasonNumber:  seasonNumber  ?? this.seasonNumber,
        episodeNumber: episodeNumber ?? this.episodeNumber,
        sortOrder:     sortOrder     ?? this.sortOrder,
        tvgId:         tvgId         ?? this.tvgId,
        addedAt:       addedAt       ?? this.addedAt,
        isWatched:     isWatched     ?? this.isWatched,
        duration:      duration      ?? this.duration,
      );
}
