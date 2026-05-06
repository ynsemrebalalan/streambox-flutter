class PlaylistModel {
  final String id;
  final String name;
  final String type; // 'm3u' | 'xtream' | 'stalker'
  final String url;
  final String username;
  final String password;
  final int addedAt;
  final String allowedTypes; // "live,movie,series"
  final String etag;
  final String lastModified;
  // v7 — CloudSync: ownerUid (multi-user izolasyon), updatedAt (LWW
  // conflict resolution), lastSyncedAt (push delta - dirty satir tespiti).
  final String? ownerUid;
  final int updatedAt;
  final int? lastSyncedAt;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.username = '',
    this.password = '',
    int? addedAt,
    this.allowedTypes = 'live,movie,series',
    this.etag = '',
    this.lastModified = '',
    this.ownerUid,
    int? updatedAt,
    this.lastSyncedAt,
  })  : addedAt = addedAt ?? 0,
        updatedAt = updatedAt ?? 0;

  factory PlaylistModel.fromMap(Map<String, dynamic> map) => PlaylistModel(
        id:           map['id'] as String,
        name:         map['name'] as String,
        type:         map['type'] as String,
        url:          map['url'] as String,
        username:     map['username'] as String? ?? '',
        password:     map['password'] as String? ?? '',
        addedAt:      map['addedAt'] as int? ?? 0,
        allowedTypes: map['allowedTypes'] as String? ?? 'live,movie,series',
        etag:         map['etag'] as String? ?? '',
        lastModified: map['lastModified'] as String? ?? '',
        ownerUid:     map['ownerUid'] as String?,
        updatedAt:    map['updatedAt'] as int? ?? 0,
        lastSyncedAt: map['lastSyncedAt'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'id':           id,
        'name':         name,
        'type':         type,
        'url':          url,
        'username':     username,
        'password':     password,
        'addedAt':      addedAt,
        'allowedTypes': allowedTypes,
        'etag':         etag,
        'lastModified': lastModified,
        'ownerUid':     ownerUid,
        'updatedAt':    updatedAt,
        'lastSyncedAt': lastSyncedAt,
      };

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? type,
    String? url,
    String? username,
    String? password,
    int? addedAt,
    String? allowedTypes,
    String? etag,
    String? lastModified,
    String? ownerUid,
    int? updatedAt,
    int? lastSyncedAt,
  }) =>
      PlaylistModel(
        id:           id           ?? this.id,
        name:         name         ?? this.name,
        type:         type         ?? this.type,
        url:          url          ?? this.url,
        username:     username     ?? this.username,
        password:     password     ?? this.password,
        addedAt:      addedAt      ?? this.addedAt,
        allowedTypes: allowedTypes ?? this.allowedTypes,
        etag:         etag         ?? this.etag,
        lastModified: lastModified ?? this.lastModified,
        ownerUid:     ownerUid     ?? this.ownerUid,
        updatedAt:    updatedAt    ?? this.updatedAt,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}
