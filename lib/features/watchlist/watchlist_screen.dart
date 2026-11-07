import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/large_title_scaffold.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/channel_model.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/widgets/channel_list_item.dart';

/// Pro: "İzleme Listem" — Android paritesi: tüm playlist'lerden, limitsiz,
/// en yeni önce. Kanal silinse bile snapshot ile görünür.
final watchlistProvider = FutureProvider.autoDispose<List<ChannelModel>>(
  (ref) => ref.read(watchlistRepoProvider).getAll(),
);

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.watchlistClearAll),
        content: Text(l.watchlistClearConfirm),
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
    if (ok != true) return;
    await ref.read(watchlistRepoProvider).clearAll();
    ref.invalidate(watchlistProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = ref.watch(watchlistProvider);
    final hasItems = list.valueOrNull?.isNotEmpty ?? false;

    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);

    return LargeTitleScaffold(
      title: l.watchlistTitle,
      actions: [
        if (hasItems)
          IconButton(
            tooltip: l.watchlistClearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _confirmClear(context, ref),
          ),
      ],
      onRefresh: hasItems
          ? () async {
              ref.invalidate(watchlistProvider);
              await ref.read(watchlistProvider.future);
            }
          : null,
      slivers: [
        ...list.when(
          loading: () => [
            SliverToBoxAdapter(
              child: SkeletonPulse(
                child: Column(
                  children: List.generate(
                      8, (_) => const ChannelRowSkeleton()),
                ),
              ),
            ),
          ],
          error: (e, _) => [
            fill(EmptyState.error(
              title:       l.errorGenericRetry,
              actionLabel: l.retry,
              onAction:    () => ref.invalidate(watchlistProvider),
            )),
          ],
          data: (items) => items.isEmpty
              ? [
                  fill(EmptyState(
                    icon:    Icons.bookmark_outline,
                    title:   l.watchlistEmpty,
                    message: l.watchlistEmptyHint,
                  )),
                ]
              : [
                  SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => ChannelListItem(channel: items[i]),
                  ),
                ],
        ),
      ],
    );
  }
}
