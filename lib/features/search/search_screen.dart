import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/channel_model.dart';
import '../home/widgets/channel_list_item.dart';

// Provider keyed by (playlistId, query)
final _searchProvider = FutureProvider.autoDispose
    .family<List<ChannelModel>, ({String playlistId, String query})>(
  (ref, args) => ref
      .read(channelRepoProvider)
      .search(args.playlistId, args.query),
);

class SearchScreen extends ConsumerStatefulWidget {
  final String playlistId;
  const SearchScreen({super.key, required this.playlistId});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: TextField(
          controller: _ctrl,
          autofocus:  true,
          decoration: InputDecoration(
            hintText:  'Kanal, film, dizi ara...',
            border:    InputBorder.none,
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              iconSize: 28,
              icon:      const Icon(Icons.close),
              onPressed: () { _ctrl.clear(); setState(() {}); },
            ),
        ],
      ),
      body: Column(
        children: [
          // TV-friendly hızlı filtreler: kumanda ile klavye yazmaktan kurtarir
          if (_ctrl.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md, vertical: Spacing.sm),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickFilter(label: 'A', onTap: () => _setQuery('a')),
                  _QuickFilter(label: 'B', onTap: () => _setQuery('b')),
                  _QuickFilter(label: 'C', onTap: () => _setQuery('c')),
                  _QuickFilter(label: 'D', onTap: () => _setQuery('d')),
                  _QuickFilter(label: 'E', onTap: () => _setQuery('e')),
                  _QuickFilter(label: 'F', onTap: () => _setQuery('f')),
                  _QuickFilter(label: 'G', onTap: () => _setQuery('g')),
                  _QuickFilter(label: 'H', onTap: () => _setQuery('h')),
                  _QuickFilter(label: 'I', onTap: () => _setQuery('i')),
                  _QuickFilter(label: 'K', onTap: () => _setQuery('k')),
                  _QuickFilter(label: 'M', onTap: () => _setQuery('m')),
                  _QuickFilter(label: 'N', onTap: () => _setQuery('n')),
                  _QuickFilter(label: 'O', onTap: () => _setQuery('o')),
                  _QuickFilter(label: 'S', onTap: () => _setQuery('s')),
                  _QuickFilter(label: 'T', onTap: () => _setQuery('t')),
                ],
              ),
            ),
          Expanded(
            child: _ctrl.text.trim().length < 2
                ? _EmptyState()
                : _Results(
                    playlistId: widget.playlistId,
                    query: _ctrl.text.trim()),
          ),
        ],
      ),
    );
  }

  void _setQuery(String q) {
    _ctrl.text = q;
    setState(() {});
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

// ── Quick filter chip (TV-friendly harf shortcut) ─────────────────────────────

class _QuickFilter extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickFilter({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: cs.onSurfaceVariant),
          const SizedBox(height: Spacing.lg),
          Text('En az 2 karakter girin',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Results ───────────────────────────────────────────────────────────────────

class _Results extends ConsumerWidget {
  final String playlistId;
  final String query;
  const _Results({required this.playlistId, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
        _searchProvider((playlistId: playlistId, query: query)));
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Hata: $e')),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text('"$query" için sonuç bulunamadı',
                style: TextStyle(color: cs.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          itemCount:   list.length,
          itemBuilder: (ctx, i) => ChannelListItem(channel: list[i]),
        );
      },
    );
  }
}
