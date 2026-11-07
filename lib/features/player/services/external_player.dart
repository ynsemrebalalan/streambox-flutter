import 'package:url_launcher/url_launcher.dart';

enum ExternalPlayerResult { opened, storeOpened, failed }

/// Yayını harici oynatıcıda aç (Android openInExternalPlayer paritesi):
///   1) VLC (x-callback-url şeması), 2) `vlc://` kısa şema,
///   3) hiçbiri yoksa App Store'da VLC sayfası.
///
/// `launchUrl` iOS'ta doğrudan openURL çağırır; LSApplicationQueriesSchemes
/// gerektiren `canLaunchUrl` kullanılmaz.
Future<ExternalPlayerResult> openInExternalPlayer(String streamUrl) async {
  final encoded = Uri.encodeComponent(streamUrl);
  final candidates = [
    Uri.parse('vlc-x-callback://x-callback-url/stream?url=$encoded'),
    Uri.parse('vlc://$streamUrl'),
  ];
  for (final uri in candidates) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return ExternalPlayerResult.opened;
      }
    } catch (_) {}
  }
  try {
    final store = Uri.parse('https://apps.apple.com/app/vlc-media-player/id650377962');
    if (await launchUrl(store, mode: LaunchMode.externalApplication)) {
      return ExternalPlayerResult.storeOpened;
    }
  } catch (_) {}
  return ExternalPlayerResult.failed;
}
