import '../../../core/utils/device_tier.dart';

/// Maksimum playlist sayisi — Android `HomeViewModel.maxPlaylistCount` paritesi.
/// Cihaz RAM katmani (OOM korumasi) VE Pro durumuna gore:
///   Free:  low 1, mid 2, high 5
///   Pro:   low 2, mid 5, high 20
int playlistLimitFor({required bool isPro, required DeviceTier tier}) =>
    switch (tier) {
      DeviceTier.low  => isPro ? 2 : 1,
      DeviceTier.mid  => isPro ? 5 : 2,
      DeviceTier.high => isPro ? 20 : 5,
    };

enum PlaylistAddDecision {
  /// Limit altinda — ekle.
  allowed,

  /// Free limitte; Pro bu cihazda daha fazlasina izin veriyor → paywall.
  needsPro,

  /// Cihaz limiti (Pro olsa bile) doldu → bilgi mesaji.
  deviceLimit,
}

PlaylistAddDecision decidePlaylistAdd({
  required int existingCount,
  required bool isPro,
  required DeviceTier tier,
}) {
  if (existingCount < playlistLimitFor(isPro: isPro, tier: tier)) {
    return PlaylistAddDecision.allowed;
  }
  if (!isPro && existingCount < playlistLimitFor(isPro: true, tier: tier)) {
    return PlaylistAddDecision.needsPro;
  }
  return PlaylistAddDecision.deviceLimit;
}

bool canAddPlaylist({
  required int existingCount,
  required bool isPro,
  required DeviceTier tier,
}) =>
    decidePlaylistAdd(existingCount: existingCount, isPro: isPro, tier: tier) ==
    PlaylistAddDecision.allowed;

/// Provider seviyesinde emniyet agi — UI gate'i atlanirsa `add` bunu firlatir.
class PlaylistLimitReachedException implements Exception {
  final int limit;
  const PlaylistLimitReachedException(this.limit);
  @override
  String toString() => 'PlaylistLimitReachedException(limit: $limit)';
}
