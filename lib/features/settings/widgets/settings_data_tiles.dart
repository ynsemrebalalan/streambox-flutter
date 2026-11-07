import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/services/epg_presets.dart';
import '../../../data/services/epg_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/home_provider.dart';
import '../../playlists/playlist_auto_refresh.dart';
import '../../playlists/playlists_provider.dart';

/// Playlist otomatik yenileme araligi (Android SettingsScreen secenekleri).
class PlaylistAutoRefreshTile extends ConsumerWidget {
  const PlaylistAutoRefreshTile({super.key});

  static String label(AppLocalizations l, RefreshInterval v) => switch (v) {
        RefreshInterval.off => l.settingsRefreshOff,
        RefreshInterval.onLaunch => l.settingsRefreshOnOpen,
        RefreshInterval.day => l.settingsRefresh1Day,
        RefreshInterval.week => l.settingsRefresh1Week,
        RefreshInterval.month => l.settingsRefresh1Month,
        RefreshInterval.year => l.settingsRefresh1Year,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final current = RefreshInterval.fromHours(ref.watch(playlistAutoRefreshProvider));
    return ListTile(
      leading: Icon(Icons.update, size: 22, color: cs.primary),
      title: Text(l.settingsPlaylistAutoRefreshTitle),
      trailing: DropdownButton<RefreshInterval>(
        value: current,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.arrow_drop_down, color: cs.onSurfaceVariant),
        items: [
          for (final v in RefreshInterval.values)
            DropdownMenuItem(value: v, child: Text(label(l, v))),
        ],
        onChanged: (v) {
          if (v == null) return;
          ref.read(playlistAutoRefreshProvider.notifier).setInterval(v.hours);
        },
      ),
    );
  }
}

/// Tum izleme gecmisini temizle (onay dialog'u ile). Favoriler korunur.
class ClearWatchHistoryTile extends ConsumerWidget {
  const ClearWatchHistoryTile({super.key});

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(l.settingsClearHistoryDialogTitle),
          content: Text(l.settingsClearHistoryDialogMessage),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: cs.error, foregroundColor: cs.onError),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.settingsClearHistoryAction),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    try {
      await ref.read(homeProvider.notifier).clearAllWatchHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.settingsClearHistoryDone)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.errorWithDetails('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.history_toggle_off, size: 22, color: cs.primary),
      title: Text(l.settingsClearHistoryTitle),
      subtitle: Text(l.settingsClearHistorySubtitle),
      onTap: () => _confirm(context, ref),
    );
  }
}

/// EPG URL — aktif playlist'e ozel (v9). Global `SettingsKeys.epgUrl` artik
/// yazilmiyor; okuma `epgUrlFor` (playlist → eski global fallback).
class EpgUrlEditor extends ConsumerStatefulWidget {
  const EpgUrlEditor({super.key});

  @override
  ConsumerState<EpgUrlEditor> createState() => _EpgUrlEditorState();
}

class _EpgUrlEditorState extends ConsumerState<EpgUrlEditor> {
  final _ctrl = TextEditingController();
  String _loadedFor = '';
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadFor(String pid) async {
    _loadedFor = pid;
    if (pid.isEmpty) {
      _ctrl.text = '';
      return;
    }
    final url = await ref.read(epgServiceProvider).epgUrlFor(pid);
    if (mounted && _loadedFor == pid) setState(() => _ctrl.text = url);
  }

  Future<bool> _save(AppLocalizations l, {bool silent = false}) async {
    final pid = ref.read(activePlaylistProvider);
    if (pid.isEmpty) {
      _snack(l.settingsSelectPlaylistFirst);
      return false;
    }
    await ref.read(epgServiceProvider).setEpgUrl(pid, _ctrl.text.trim());
    if (!silent) _snack(l.settingsSaved);
    return true;
  }

  Future<void> _refreshNow(AppLocalizations l) async {
    if (_busy) return;
    if (!await _save(l, silent: true)) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(epgServiceProvider)
          .syncEpg(ref.read(activePlaylistProvider));
      _snack(l.settingsEpgUpdated);
    } catch (e) {
      _snack(l.settingsEpgError('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final pid = ref.watch(activePlaylistProvider);
    if (pid != _loadedFor) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFor(pid));
    }
    final playlists = ref.watch(playlistsProvider).valueOrNull ?? const [];
    final activeName =
        playlists.where((p) => p.id == pid).map((p) => p.name).firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            enabled: pid.isNotEmpty,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l.settingsEpgUrlLabel,
              hintText: 'https://epg.example.com/epg.xml.gz',
              helperText: activeName == null
                  ? l.settingsSelectPlaylistFirst
                  : l.settingsEpgUrlForPlaylist(activeName),
              isDense: true,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.rss_feed, size: 20),
            ),
            onSubmitted: (_) => _save(l),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final p in kTurkishEpgPresets)
                ChoiceChip(
                  label: Text(p.label),
                  selected: _ctrl.text.trim() == p.url,
                  onSelected: pid.isEmpty
                      ? null
                      : (_) {
                          setState(() => _ctrl.text = p.url);
                          _save(l);
                        },
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _busy
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.sync, size: 18, color: cs.primary),
              label: Text(l.settingsEpgRefreshNow),
              onPressed: pid.isEmpty || _busy ? null : () => _refreshNow(l),
            ),
          ),
        ],
      ),
    );
  }
}
