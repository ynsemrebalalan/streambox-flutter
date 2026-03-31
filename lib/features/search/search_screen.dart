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
              icon:      const Icon(Icons.close),
              onPressed: () { _ctrl.clear(); setState(() {}); },
            ),
        ],
      ),
      body: _ctrl.text.trim().length < 2
          ? _EmptyState()
          : _Results(playlistId: widget.playlistId, query: _ctrl.text.trim()),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
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
