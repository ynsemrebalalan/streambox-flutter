import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/large_title_scaffold.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/playlist_model.dart';
import '../../data/services/stalker/stalker_protocol.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../home/home_provider.dart';
import 'edit_playlist_screen.dart';
import 'playlist_auto_refresh.dart';
import 'playlists_provider.dart';
import 'widgets/delete_playlist_dialog.dart';
import 'widgets/stalker_fields.dart';

export 'playlists_provider.dart';

// ── screen ────────────────────────────────────────────────────────────────────

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final active    = ref.watch(activePlaylistProvider);
    final cs        = Theme.of(context).colorScheme;
    final l         = AppLocalizations.of(context);

    final theme     = Theme.of(context);
    // Tablet: icerik formMaxWidth'e ortalanir (eski ResponsiveCenter).
    final maxW   = Responsive.formMaxWidth(context);
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad   = screenW > maxW ? (screenW - maxW) / 2 + Spacing.lg : Spacing.lg;

    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);

    return LargeTitleScaffold(
      title: l.playlistsTitle,
      leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      actions: [
        IconButton(
          iconSize: 28,
          tooltip: l.homeAddPlaylist,
          icon: const Icon(Icons.add),
          onPressed: () => _showAddDialog(context, ref),
        ),
      ],
      slivers: playlists.when(
        loading: () => [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad - Spacing.lg),
            sliver: SliverToBoxAdapter(
              child: SkeletonPulse(
                child: Column(
                  children: List.generate(4, (_) => const ChannelRowSkeleton()),
                ),
              ),
            ),
          ),
        ],
        error: (e, _) => [
          fill(EmptyState.error(
            title:       l.errorWithDetails('$e'),
            actionLabel: l.retry,
            onAction:    () => ref.invalidate(playlistsProvider),
          )),
        ],
        data: (list) {
          if (list.isEmpty) {
            return [
              fill(EmptyState(
                icon:        Icons.playlist_add,
                title:       l.playlistsEmpty,
                actionLabel: l.homeAddPlaylist,
                actionIcon:  Icons.add,
                autofocusAction: true,
                onAction:    () => _showAddDialog(context, ref),
              )),
            ];
          }
          return [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, Spacing.sm, hPad, Spacing.lg),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                itemBuilder: (ctx, i) {
              final p = list[i];
              final isActive = p.id == active;
              return Card(
                color: isActive
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: isActive
                      ? BorderSide(color: cs.primary.withValues(alpha: 0.5))
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isActive ? cs.primary : cs.surfaceContainerHigh,
                    child: Icon(
                      Icons.list_alt,
                      color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                  title: Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500)),
                  subtitle: Text(p.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        Icon(Icons.check_circle,
                            color: cs.primary, size: 20,
                            semanticLabel: l.playlistsActiveLabel),
                      Builder(builder: (_) {
                        final syncing = ref
                            .read(playlistsProvider.notifier)
                            .isSyncing(p.id);
                        return syncing
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                iconSize: 28,
                                icon: const Icon(Icons.sync),
                                tooltip: l.playlistsRefreshTooltip,
                                onPressed: () async {
                                  final err = await ref
                                      .read(playlistsProvider.notifier)
                                      .sync(p, l);
                                  if (!context.mounted) return;
                                  if (err != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: cs.error,
                                        duration: const Duration(seconds: 4),
                                        action: SnackBarAction(
                                          label: l.playlistsRetryAction,
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            if (!context.mounted) return;
                                            await ref
                                                .read(playlistsProvider.notifier)
                                                .sync(p, l);
                                          },
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l.playlistsUpdated),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              );
                      }),
                      IconButton(
                        iconSize: 26,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: l.editPlaylistTitle,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EditPlaylistScreen(playlistId: p.id),
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 28,
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        tooltip: l.delete,
                        onPressed: () => _confirmDelete(context, ref, p),
                      ),
                    ],
                  ),
                  selected: isActive,
                  onTap: () {
                    if (!isActive) HapticFeedback.selectionClick();
                    ref.read(activePlaylistProvider.notifier).set(p.id);
                    // Reload home
                    ref.invalidate(homeProvider);
                    // Android selectPlaylist: aralık dolduysa arka planda yenile.
                    ref
                        .read(playlistAutoRefreshProvider.notifier)
                        .onPlaylistSelected(p.id);
                    context.go(AppRoutes.home);
                  },
                ),
              );
                },
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    // Playlist limiti (Android maxPlaylistCount: Free/Pro x cihaz katmani):
    // limit altiysa gecer, Pro gerekiyorsa paywall, cihaz limiti doluysa
    // snackbar.
    final allowed = await ensurePlaylistAddAllowed(context, ref);
    if (!allowed || !context.mounted) return;
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: _AddPlaylistDialog(
          onAdd: (p) => ref.read(playlistsProvider.notifier).add(p),
        ),
      ),
    );
    // Playlist eklendi → Home'a yönlendir; kanallar arka planda akışlı dolar
    // (üstteki ilerleme çubuğu "X kanal kaydedildi" gösterir).
    if (added == true && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, PlaylistModel p) async {
    final deleted = await showDeletePlaylistDialog(context, ref, p);
    // Son playlist silindiyse boş Home'a yönlendir.
    if (!deleted || !context.mounted) return;
    final remaining = ref.read(playlistsProvider).valueOrNull ?? const [];
    if (remaining.isEmpty) context.go(AppRoutes.home);
  }
}

// ── add dialog ────────────────────────────────────────────────────────────────

class _AddPlaylistDialog extends StatefulWidget {
  final Future<void> Function(PlaylistModel) onAdd;

  const _AddPlaylistDialog({required this.onAdd});

  @override
  State<_AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<_AddPlaylistDialog> {
  final _nameCtrl = TextEditingController();
  final _urlCtrl  = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String  _type    = 'm3u';
  bool    _loading = false;
  String? _error;

  // İçerik türleri (M3U + Xtream — Android paritesi)
  bool _allowLive   = true;
  bool _allowMovie  = true;
  bool _allowSeries = true;

  String get _allowedTypes {
    final types = <String>[];
    if (_allowLive)   types.add('live');
    if (_allowMovie)  types.add('movie');
    if (_allowSeries) types.add('series');
    return types.isEmpty ? 'live' : types.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.playlistsAddTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type selector
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'm3u',    label: Text(l.playlistsTypeM3u)),
                  ButtonSegment(value: 'xtream', label: Text(l.playlistsTypeXtream)),
                  ButtonSegment(value: 'stalker', label: Text(l.playlistsTypeStalker)),
                ],
                selected:  {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: Spacing.md),

              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l.playlistsNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.md),

              if (_type == 'm3u') ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    labelText: l.playlistsM3uUrlLabel,
                    hintText:  l.playlistsM3uUrlHint,
                    border:    const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                ),
                const SizedBox(height: Spacing.xs),
                // Panodan yapistir kisayolu — kullanici email/Notes/Mesajlar
                // uygulamasindan kopyaladigi M3U URL'ini tek dokunusla
                // alaninin icine alabilsin.
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.content_paste, size: 16),
                    label: Text(l.playlistsPasteFromClipboard,
                        style: const TextStyle(fontSize: TextSize.label)),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      final text = data?.text?.trim() ?? '';
                      if (!mounted) return;
                      if (text.isEmpty) {
                        setState(() => _error = l.playlistsClipboardEmpty);
                        return;
                      }
                      setState(() {
                        _urlCtrl.text = text;
                        _error = null;
                      });
                    },
                  ),
                ),
              ] else if (_type == 'stalker') ...[
                StalkerFields(urlCtrl: _urlCtrl, macCtrl: _userCtrl),
              ] else ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    labelText: l.playlistsServerUrlLabel,
                    hintText:  l.playlistsServerUrlHint,
                    border:    const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _userCtrl,
                  decoration: InputDecoration(
                    labelText: l.playlistsUsernameLabel,
                    border:    const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l.playlistsPasswordLabel,
                    border:    const OutlineInputBorder(),
                  ),
                ),
              ],
              // Stalker yalniz canli kanal (Android: icerik turu secimi yok).
              if (_type != 'stalker') ...[
              const SizedBox(height: Spacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l.playlistsContentTypes,
                    style: const TextStyle(fontSize: TextSize.label,
                        fontWeight: FontWeight.w600)),
              ),
              Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title:   Text(l.playlistsContentLive, style: const TextStyle(fontSize: TextSize.label)),
                        value:   _allowLive,
                        dense:   true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _allowLive = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title:   Text(l.playlistsContentMovie, style: const TextStyle(fontSize: TextSize.label)),
                        value:   _allowMovie,
                        dense:   true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _allowMovie = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title:   Text(l.playlistsContentSeries, style: const TextStyle(fontSize: TextSize.label)),
                        value:   _allowSeries,
                        dense:   true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _allowSeries = v ?? true),
                      ),
                    ),
                  ],
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: Spacing.sm),
                Text(_error!,
                    style: TextStyle(
                        color:    cs.error,
                        fontSize: TextSize.label)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        // Progress message — sync sırasında "X kanal işleniyor..." gösterir
        if (_loading)
          Consumer(
            builder: (ctx, ref, _) {
              final notifier = ref.read(playlistsProvider.notifier);
              return ValueListenableBuilder<String>(
                valueListenable: notifier.progressMessage,
                builder: (_, msg, __) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    msg.isEmpty ? '...' : msg,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        FilledButton(
          onPressed: _loading ? null : () => _submit(l),
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.commonAdd),
        ),
      ],
    );
  }

  Future<void> _submit(AppLocalizations l) async {
    final name = _nameCtrl.text.trim();
    final url  = _urlCtrl.text.trim();
    if (name.isEmpty || url.isEmpty) {
      setState(() => _error = l.playlistsValidationNameUrl);
      return;
    }
    if (_type == 'xtream' &&
        (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty)) {
      setState(() => _error = l.playlistsValidationXtreamCreds);
      return;
    }
    final isStalker = _type == 'stalker';
    final mac = isStalker ? StalkerMac.normalize(_userCtrl.text) : null;
    if (isStalker && mac == null) {
      setState(() => _error = l.playlistsValidationStalkerMac);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final p = PlaylistModel(
        id:           const Uuid().v4(),
        name:         name,
        type:         _type,
        url:          isStalker ? StalkerUrls.clean(url) : url,
        username:     mac ?? _userCtrl.text.trim(),
        password:     isStalker ? '' : _passCtrl.text.trim(),
        allowedTypes: isStalker ? 'live,movie,series' : _allowedTypes,
      );
      await widget.onAdd(p);
      // pop(context, true) → _showAddDialog awaiter true alır, Home'a yönlendirir.
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _loading = false; _error = l.errorWithDetails('$e'); });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
