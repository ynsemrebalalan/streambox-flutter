class EpgChannelModel {
  final String tvgId;
  final String playlistId;
  final String displayName;
  final String icon;

  const EpgChannelModel({
    required this.tvgId,
    required this.playlistId,
    required this.displayName,
    this.icon = '',
  });

  factory EpgChannelModel.fromMap(Map<String, dynamic> map) => EpgChannelModel(
        tvgId:       map['tvgId'] as String,
        playlistId:  map['playlistId'] as String,
        displayName: map['displayName'] as String,
        icon:        map['icon'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'tvgId':       tvgId,
        'playlistId':  playlistId,
        'displayName': displayName,
        'icon':        icon,
      };
}

class EpgProgrammeModel {
  final String id; // "${channelId}_${startTime}"
  final String channelId;
  final String title;
  final String description;
  final int startTime; // Unix millis UTC
  final int stopTime;  // Unix millis UTC
  final String category;
  final String icon;

  const EpgProgrammeModel({
    required this.id,
    required this.channelId,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.stopTime,
    this.category = '',
    this.icon = '',
  });

  bool get isLive {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startTime && now < stopTime;
  }

  double get progress {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < startTime) return 0.0;
    if (now >= stopTime) return 1.0;
    return (now - startTime) / (stopTime - startTime);
  }

  factory EpgProgrammeModel.fromMap(Map<String, dynamic> map) =>
      EpgProgrammeModel(
        id:          map['id'] as String,
        channelId:   map['channelId'] as String,
        title:       map['title'] as String,
        description: map['description'] as String? ?? '',
        startTime:   map['startTime'] as int,
        stopTime:    map['stopTime'] as int,
        category:    map['category'] as String? ?? '',
        icon:        map['icon'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id':          id,
        'channelId':   channelId,
        'title':       title,
        'description': description,
        'startTime':   startTime,
        'stopTime':    stopTime,
        'category':    category,
        'icon':        icon,
      };
}
