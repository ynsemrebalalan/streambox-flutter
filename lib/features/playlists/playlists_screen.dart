import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/analytics/analytics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/http_client.dart';
import '../../data/models/playlist_model.dart';
import '../../data/services/m3u_parser.dart';
import '../../data/services/xtream_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/widgets/paywall_trigger.dart';
import '../home/home_provider.dart';

// ── provider ─────────────────────────────────────────────────────────────────

final playlistsProvider =
    AsyncNotifierProvider<PlaylistsNotifier, List<PlaylistModel>>(
  PlaylistsNotifier.new,
);

class PlaylistsNotifier extends AsyncNotifier<List<PlaylistModel>> {
  final _syncing = <String>{};
  final _lastError = <String, String>{};

  bool isSyncing(String id) => _syncing.contains(id);
  String? lastError(String id) => _lastError[id];

  @override
  Future<List<PlaylistModel>> build() =>
      ref.read(playlistRepoProvider).getAll();

  Future<void> reload() async {
    final current = state.value;
    state = current != null
        ? AsyncData(current)   // keep list visible while refreshing
        : const AsyncLoading();
    final fresh = await ref.read(playlistRepoProvider).getAll();
    state = AsyncData(fresh);
  }

  Future<void> add(PlaylistModel p) async {
    final repo  = ref.read(playlistRepoProvider);
    final saved = await repo.insert(p);
    state = AsyncData([...?state.value, saved]);

    // If first playlist → set active and sync
    final active = ref.read(activePlaylistProvider);
    if (active.isEmpty) {
      ref.read(activePlaylistProvider.notifier).set(saved.id);
      await _doSync(saved);
    }
  }

  /// Returns: null on success, user-facing error message on failure.
  Future<String?> sync(PlaylistModel p, AppLocalizations l) async {
    if (_syncing.contains(p.id)) return null;
    _syncing.add(p.id);
    _lastError.remove(p.id);
    // Rebuild so UI shows spinner on this row
    if (state.value != null) state = AsyncData(List.of(state.value!));
    String? errorMessage;
    try {
      await _doSync(p);
    } catch (e) {
      errorMessage = _errorToUserMessage(e, p, l);
      _lastError[p.id] = errorMessage;
    } finally {
      _syncing.remove(p.id);
      await reload();
    }
    return errorMessage;
  }

  String _errorToUserMessage(Object e, PlaylistModel p, AppLocalizations l) {
    if (e is _EmptyPlaylistException) {
      return l.playlistsErrorEmptyResponse;
    }
    if (e is HttpStatusException) {
      return e.userMessage;
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('handshake') ||
        msg.contains('tls') ||
        msg.contains('certificate') ||
        msg.contains('ssl')) {
      return l.playlistsErrorTlsHandshake;
    }
    if (msg.contains('timeout') || msg.contains('timedout')) {
      return l.playlistsErrorTimeout;
    }
    if (msg.contains('socket') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection')) {
      return l.playlistsErrorConnection;
    }
    return l.playlistsErrorUpdateGeneric('$e');
  }

  Future<void> delete(String id) async {
    final repo = ref.read(playlistRepoProvider);
    await repo.delete(id);
    await ref.read(channelRepoProvider).deleteByPlaylist(id);
    final active = ref.read(activePlaylistProvider);
    if (active == id) {
      final all = await repo.getAll();
      ref.read(activePlaylistProvider.notifier).set(all.firstOrNull?.id ?? '');
    }
    await reload();
  }

  Future<void> _doSync(PlaylistModel p) async {
    // Once fetch+parse yap. Basarisiz olursa throw eder ve DB'ye dokunulmaz,
    // yani eski kanallar olduğu gibi kalır (stale-but-usable cache).
    final channels = p.type == 'xtream'
        ? await XtreamService.fetchAll(p)
        : await M3uParser.fetchAndParse(p);

    // Bos cevap geldiyse (provider kismi hata) eski veriyi koruma.
    // Bu mesaj _errorToUserMessage'a dusup playlistsErrorUpdateGeneric'e cevrilir.
    if (channels.isEmpty) {
      throw const _EmptyPlaylistException();
    }

    // Fetch basarili → atomik olarak eski kanallari sil + yenilerini yaz.
    // Transaction icinde, crash'te yarim veri olusmaz.
    final repo = ref.read(channelRepoProvider);
    await repo.replaceAllForPlaylist(p.id, channels);
  }
}

class _EmptyPlaylistException implements Exception {
  const _EmptyPlaylistException();
}

// ── screen ────────────────────────────────────────────────────────────────────

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final active    = ref.watch(activePlaylistProvider);
    final cs        = Theme.of(context).colorScheme;
    final l         = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.playlistsTitle),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        actions: [
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: playlists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text(l.errorWithDetails('$e'))),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: Spacing.lg),
                  Text(l.playlistsEmpty,
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: Spacing.md),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(l.homeAddPlaylist),
                    onPressed: () => _showAddDialog(context, ref),
                  ),
                ],
              ),
            );
          }
          return ResponsiveCenter(
            maxWidth: Responsive.formMaxWidth(context),
            child: ListView.separated(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
            itemBuilder: (ctx, i) {
              final p = list[i];
              final isActive = p.id == active;
              return Card(
                color: isActive
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : cs.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isActive ? AppColors.accent : cs.surfaceContainerHighest,
                    child: Icon(
                      Icons.list_alt,
                      color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                  title: Text(p.name,
                      style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal)),
                  subtitle: Text(p.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: TextSize.caption,
                          color: cs.onSurfaceVariant)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        Icon(Icons.check_circle,
                            color: AppColors.accent, size: 20),
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
                        iconSize: 28,
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        tooltip: l.delete,
                        onPressed: () => _confirmDelete(context, ref, p),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(activePlaylistProvider.notifier).set(p.id);
                    // Reload home
                    ref.invalidate(homeProvider);
                    context.go(AppRoutes.home);
                  },
                ),
              );
            },
          ),
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    // Adim 22 Phase D: 2. playlist gate. Mevcut listede 1+ varsa Pro
    // gerekli — anon ise once login akisi, sonra paywall.
    final existing = ref.read(playlistsProvider).valueOrNull ?? const [];
    if (existing.isNotEmpty) {
      final allowed = await requirePro(
        context,
        ref,
        PaywallTrigger.secondPlaylist,
      );
      if (!allowed || !context.mounted) return;
    }
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: _AddPlaylistDialog(
          onAdd: (p) => ref.read(playlistsProvider.notifier).add(p),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PlaylistModel p) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.playlistsDeleteTitle),
        content: Text(l.playlistsDeleteConfirm(p.name)),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playlistsProvider.notifier).delete(p.id);
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
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

  // Xtream allowed content types
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
    setState(() { _loading = true; _error = null; });
    try {
      final p = PlaylistModel(
        id:           const Uuid().v4(),
        name:         name,
        type:         _type,
        url:          url,
        username:     _userCtrl.text.trim(),
        password:     _passCtrl.text.trim(),
        allowedTypes: _type == 'xtream' ? _allowedTypes : 'live,movie,series',
      );
      await widget.onAdd(p);
      Analytics.playlistAdded(type: _type, channelCount: 0);
      if (mounted) Navigator.pop(context);
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
