import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/http_client.dart';
import '../../data/models/playlist_model.dart';
import '../../data/services/m3u_parser.dart';
import '../../data/services/xtream_service.dart';
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
  Future<String?> sync(PlaylistModel p) async {
    if (_syncing.contains(p.id)) return null;
    _syncing.add(p.id);
    _lastError.remove(p.id);
    // Rebuild so UI shows spinner on this row
    if (state.value != null) state = AsyncData(List.of(state.value!));
    String? errorMessage;
    try {
      await _doSync(p);
    } catch (e) {
      errorMessage = _errorToUserMessage(e, p);
      _lastError[p.id] = errorMessage;
    } finally {
      _syncing.remove(p.id);
      await reload();
    }
    return errorMessage;
  }

  String _errorToUserMessage(Object e, PlaylistModel p) {
    if (e is HttpStatusException) {
      return e.userMessage;
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('handshake') ||
        msg.contains('tls') ||
        msg.contains('certificate') ||
        msg.contains('ssl')) {
      return 'Guvenli baglanti kurulamadi (TLS hatasi). '
          'URL\'yi http:// ile deneyin veya saglayici adresini kontrol edin.';
    }
    if (msg.contains('timeout') || msg.contains('timedout')) {
      return 'Saglayici cevap veremedi (timeout). Birazdan tekrar deneyin.';
    }
    if (msg.contains('socket') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection')) {
      return 'Internet baglantisi yok veya saglayiciya ulasilamiyor.';
    }
    return 'Playlist guncellenemedi: $e';
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
    if (channels.isEmpty) {
      throw Exception('Saglayici bos playlist dondu. Eski veri korundu.');
    }

    // Fetch basarili → atomik olarak eski kanallari sil + yenilerini yaz.
    // Transaction icinde, crash'te yarim veri olusmaz.
    final repo = ref.read(channelRepoProvider);
    await repo.replaceAllForPlaylist(p.id, channels);
  }
}

// ── screen ────────────────────────────────────────────────────────────────────

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final active    = ref.watch(activePlaylistProvider);
    final cs        = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist\'ler'),
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
        error:   (e, _) => Center(child: Text('Hata: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: Spacing.lg),
                  Text('Henüz playlist yok',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: Spacing.md),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Playlist Ekle'),
                    onPressed: () => _showAddDialog(context, ref),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
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
                                tooltip: 'Yenile',
                                onPressed: () async {
                                  final err = await ref
                                      .read(playlistsProvider.notifier)
                                      .sync(p);
                                  if (!context.mounted) return;
                                  if (err != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err),
                                        backgroundColor: cs.error,
                                        duration: const Duration(seconds: 4),
                                        action: SnackBarAction(
                                          label: 'TEKRAR',
                                          textColor: Colors.white,
                                          onPressed: () => ref
                                              .read(playlistsProvider.notifier)
                                              .sync(p),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Playlist guncellendi.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              );
                      }),
                      IconButton(
                        iconSize: 28,
                        icon: Icon(Icons.delete_outline, color: cs.error),
                        tooltip: 'Sil',
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
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Playlist Sil'),
        content: Text('"${p.name}" silinsin mi?'),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(playlistsProvider.notifier).delete(p.id);
            },
            child: const Text('Sil'),
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

    return AlertDialog(
      title: const Text('Playlist Ekle'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'm3u',    label: Text('M3U URL')),
                  ButtonSegment(value: 'xtream', label: Text('Xtream')),
                ],
                selected:  {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: Spacing.md),

              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Playlist Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.md),

              if (_type == 'm3u') ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'M3U URL',
                    hintText:  'http://...',
                    border:    OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ] else ...[
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sunucu URL',
                    hintText:  'http://server.com:8080',
                    border:    OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border:    OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border:    OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('İçerik Tipleri',
                      style: TextStyle(fontSize: TextSize.label,
                          fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title:   const Text('Canlı', style: TextStyle(fontSize: TextSize.label)),
                        value:   _allowLive,
                        dense:   true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _allowLive = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title:   const Text('Film', style: TextStyle(fontSize: TextSize.label)),
                        value:   _allowMovie,
                        dense:   true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _allowMovie = v ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title:   const Text('Dizi', style: TextStyle(fontSize: TextSize.label)),
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
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Ekle'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final url  = _urlCtrl.text.trim();
    if (name.isEmpty || url.isEmpty) {
      setState(() => _error = 'Ad ve URL zorunlu');
      return;
    }
    if (_type == 'xtream' &&
        (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty)) {
      setState(() => _error = 'Xtream için kullanıcı adı ve şifre gerekli');
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _loading = false; _error = 'Hata: $e'; });
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
