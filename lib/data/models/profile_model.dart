/// Multi-profile (Phase 6) modeli. Free=1, Pro=sinirsiz.
class Profile {
  final String id;
  final String name;
  final String icon;        // material icon adi (ornek: 'person', 'child_care')
  final bool   isDefault;
  final int    createdAt;   // unix ms

  const Profile({
    required this.id,
    required this.name,
    this.icon      = 'person',
    this.isDefault = false,
    this.createdAt = 0,
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id:        m['id']        as String,
        name:      m['name']      as String,
        icon:      (m['icon']      as String?) ?? 'person',
        isDefault: ((m['isDefault'] as int?) ?? 0) == 1,
        createdAt: (m['createdAt'] as int?)    ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id':        id,
        'name':      name,
        'icon':      icon,
        'isDefault': isDefault ? 1 : 0,
        'createdAt': createdAt,
      };

  Profile copyWith({String? name, String? icon}) => Profile(
        id:        id,
        name:      name ?? this.name,
        icon:      icon ?? this.icon,
        isDefault: isDefault,
        createdAt: createdAt,
      );
}
