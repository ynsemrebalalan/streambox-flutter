import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/playlist_model.dart';
import '../../data/services/m3u_parser.dart';
import '../../data/services/stalker/stalker_protocol.dart';
import '../../l10n/generated/app_localizations.dart';
import 'playlists_provider.dart';
import 'widgets/delete_playlist_dialog.dart';
import 'widgets/stalker_fields.dart';

/// Playlist düzenleme — Android EditPlaylistScreen paritesi: ad, URL,
/// Xtream kullanıcı/şifre, M3U `exp=` son kullanma tarihi, kaydet,
/// "Kanalları Yenile", sil.
class EditPlaylistScreen extends ConsumerStatefulWidget {
  final String playlistId;
  const EditPlaylistScreen({super.key, required this.playlistId});

  @override
  ConsumerState<EditPlaylistScreen> createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends ConsumerState<EditPlaylistScreen> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  PlaylistModel? _playlist;
  bool _loading = true;
  bool _saving = false;
  bool _passVisible = false;

  @override
  void initState() {
    super.initState();
    _url.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(playlistRepoProvider).getById(widget.playlistId);
    if (!mounted) return;
    setState(() {
      _playlist = p;
      _loading = false;
      if (p != null) {
        _name.text = p.name;
        _url.text = p.url;
        _user.text = p.username;
        _pass.text = p.password;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  static String _fmt(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ));
  }

  Future<void> _save(AppLocalizations l) async {
    final p = _playlist;
    if (p == null) return;
    final name = _name.text.trim();
    final url = _url.text.trim();
    if (name.isEmpty || url.isEmpty) {
      _snack(l.playlistsValidationNameUrl, error: true);
      return;
    }
    if (p.type == 'xtream' &&
        (_user.text.trim().isEmpty || _pass.text.trim().isEmpty)) {
      _snack(l.playlistsValidationXtreamCreds, error: true);
      return;
    }
    final isStalker = p.type == 'stalker';
    final mac = isStalker ? StalkerMac.normalize(_user.text) : null;
    if (isStalker && mac == null) {
      _snack(l.playlistsValidationStalkerMac, error: true);
      return;
    }
    setState(() => _saving = true);
    final err = await ref.read(playlistsProvider.notifier).updatePlaylist(
          p.copyWith(
            name: name,
            url: isStalker ? StalkerUrls.clean(url) : url,
            username: mac ?? _user.text.trim(),
            // Stalker: password alani (Android token'i) korunur.
            password: isStalker ? p.password : _pass.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      _snack(err, error: true);
      return;
    }
    // Arka plan yenilemesi sürüyordu: değişiklik kaydedildi, liste o bitince
    // yeniden indirilecek (sessizce yok sayılmaz).
    if (ref.read(playlistsProvider.notifier).isSyncing(widget.playlistId)) {
      _snack(l.playlistSyncQueued);
    }
    Navigator.of(context).pop();
  }

  Future<void> _refresh(AppLocalizations l) async {
    final p = await ref.read(playlistRepoProvider).getById(widget.playlistId);
    if (p == null) return;
    final err = await ref.read(playlistsProvider.notifier).sync(p, l);
    if (!mounted) return;
    _snack(err ?? l.playlistsUpdated, error: err != null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final p = _playlist;
    ref.watch(playlistsProvider); // sync durumunda yeniden çiz
    final syncing =
        ref.read(playlistsProvider.notifier).isSyncing(widget.playlistId);

    return Scaffold(
      appBar: AppBar(title: Text(l.editPlaylistTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? Center(child: Text(l.editPlaylistNotFound))
              : ResponsiveCenter(
                  maxWidth: Responsive.formMaxWidth(context),
                  child: ListView(
                    padding: const EdgeInsets.all(Spacing.lg),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(switch (p.type) {
                            'xtream'  => l.editPlaylistXtreamBadge,
                            'stalker' => l.editPlaylistStalkerBadge,
                            _         => l.editPlaylistM3uBadge,
                          }),
                        ),
                      ),
                      if (p.addedAt > 0)
                        _InfoRow(label: l.editPlaylistAddedAt,
                            value: _fmt(p.addedAt)),
                      ..._expiry(l),
                      const SizedBox(height: Spacing.md),
                      TextField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l.playlistsNameLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      if (p.type == 'stalker')
                        StalkerFields(
                            urlCtrl: _url, macCtrl: _user, showInfoCard: false)
                      else
                      TextField(
                        controller: _url,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: p.type == 'xtream'
                              ? l.editPlaylistUrlLabel
                              : l.playlistsM3uUrlLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (p.type == 'xtream') ...[
                        const SizedBox(height: Spacing.md),
                        TextField(
                          controller: _user,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: l.playlistsUsernameLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        TextField(
                          controller: _pass,
                          obscureText: !_passVisible,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: l.playlistsPasswordLabel,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_passVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _passVisible = !_passVisible),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.lg),
                      FilledButton(
                        onPressed: _saving || syncing ? null : () => _save(l),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(l.save),
                      ),
                      const SizedBox(height: Spacing.sm),
                      OutlinedButton.icon(
                        onPressed: syncing ? null : () => _refresh(l),
                        icon: syncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.sync),
                        label: syncing
                            ? ValueListenableBuilder<String>(
                                valueListenable: ref
                                    .read(playlistsProvider.notifier)
                                    .progressMessage,
                                builder: (_, msg, __) =>
                                    Text(msg.isEmpty ? l.loading : msg),
                              )
                            : Text(l.editPlaylistRefreshButton),
                      ),
                      const SizedBox(height: Spacing.sm),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: cs.error),
                        onPressed: syncing
                            ? null
                            : () async {
                                final deleted = await showDeletePlaylistDialog(
                                    context, ref, p);
                                if (deleted && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l.editPlaylistDeleteButton),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _expiry(AppLocalizations l) {
    final ms = parseM3uExpiry(_url.text);
    if (ms == null) return const [];
    final expired = ms < DateTime.now().millisecondsSinceEpoch;
    final color = expired ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
    return [
      _InfoRow(
        label: l.editPlaylistExpiry,
        value: _fmt(ms),
        valueColor: color,
        badge: expired ? l.editPlaylistExpiredLabel : l.editPlaylistValidLabel,
      ),
    ];
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? badge;
  const _InfoRow(
      {required this.label, required this.value, this.valueColor, this.badge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: TextSize.caption)),
          ),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? cs.onSurface,
                  fontWeight: FontWeight.w500)),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (valueColor ?? cs.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      color: valueColor ?? cs.primary, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}
