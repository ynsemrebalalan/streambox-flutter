/// mpv hata metni → kullanıcıya gösterilecek hata türü (Android
/// PlayerViewModel.userFacingError'ın sadeleştirilmiş karşılığı).
enum PlaybackErrorKind { unavailable, unsupportedFormat, corruptStream }

PlaybackErrorKind classifyPlaybackError(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('recognize file format') ||
      s.contains('unrecognized') ||
      s.contains('no video or audio') ||
      s.contains('codec') ||
      s.contains('unsupported')) {
    return PlaybackErrorKind.unsupportedFormat;
  }
  if (s.contains('invalid data') || s.contains('corrupt')) {
    return PlaybackErrorKind.corruptStream;
  }
  return PlaybackErrorKind.unavailable;
}
