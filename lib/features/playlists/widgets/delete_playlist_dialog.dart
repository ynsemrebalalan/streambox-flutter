import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/playlist_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../playlists_provider.dart';

/// Android EditPlaylistScreen silme diyaloğu: "Cihazdan Sil" (bulut kaydı
/// durur) / "Buluttan Sil" (kalıcı, onaylı). Bulutta olmadığı biliniyorsa
/// yalnız cihaz seçeneği gösterilir. Dönüş: silindi mi.
Future<bool> showDeletePlaylistDialog(
  BuildContext context,
  WidgetRef ref,
  PlaylistModel p,
) async {
  final notifier = ref.read(playlistsProvider.notifier);
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => _DeleteDialog(
      playlist: p,
      inCloud: notifier.isInCloud(p.id),
    ),
  );
  if (choice == null || !context.mounted) return false;
  if (choice == 'cloud') {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deletePlaylistFromCloud),
        content: Text(l.deleteCloudExplain),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return false;
  }
  await notifier.delete(p.id, fromCloud: choice == 'cloud');
  return true;
}

class _DeleteDialog extends StatelessWidget {
  final PlaylistModel playlist;
  final Future<bool?> inCloud;
  const _DeleteDialog({required this.playlist, required this.inCloud});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    const warn = Color(0xFFFF9800);
    return AlertDialog(
      title: Text(l.deletePlaylistDialogTitle),
      content: FutureBuilder<bool?>(
        future: inCloud,
        builder: (ctx, snap) {
          // null = bilinmiyor → bulut seçeneği kalır (Android).
          final known = snap.connectionState == ConnectionState.done;
          final cloud = known ? snap.data : null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(playlist.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(l.deletePlaylistDialogQuestion),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: warn,
                  side: BorderSide(color: warn.withValues(alpha: 0.6)),
                ),
                onPressed: () => Navigator.pop(context, 'device'),
                child: Text(l.deletePlaylistFromDevice),
              ),
              const SizedBox(height: 4),
              Text(
                cloud == false ? l.deleteDeviceExplainLocal : l.deleteDeviceExplain,
                style: const TextStyle(fontSize: 12),
              ),
              if (cloud != false) ...[
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: cs.error),
                  onPressed: () => Navigator.pop(context, 'cloud'),
                  child: Text(l.deletePlaylistFromCloud),
                ),
                const SizedBox(height: 4),
                Text(l.deleteCloudExplain,
                    style: const TextStyle(fontSize: 12)),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
