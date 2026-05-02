import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/models/channel_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/widgets/channel_list_item.dart';

/// Pro: "İzleme Listem" — kullanıcının "sonra izle" diyerek eklediği
/// kanallar. Watchlist tablosundan join ile gelir; kanal silinince
/// otomatik düşer.
final watchlistProvider = FutureProvider.autoDispose<List<ChannelModel>>(
  (ref) async {
    final pid = ref.watch(activePlaylistProvider);
    if (pid.isEmpty) return [];
    return ref.read(watchlistRepoProvider).getAll(pid);
  },
);

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final list = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.watchlistTitle)),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorGenericRetry)),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_outline,
                        size: 64, color: cs.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(l.watchlistEmpty,
                        style: TextStyle(
                            fontSize: 16, color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text(l.watchlistEmptyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(watchlistProvider);
              await ref.read(watchlistProvider.future);
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) =>
                  ChannelListItem(channel: items[i]),
            ),
          );
        },
      ),
    );
  }
}
