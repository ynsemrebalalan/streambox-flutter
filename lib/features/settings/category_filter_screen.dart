import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/hidden_categories_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/home_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

class _CatFilterState {
  final List<PlaylistModel> playlists;
  final String playlistId;
  final Map<String, List<String>> categoriesByType; // live/movie/series → [cat]
  final Set<String> hidden;

  const _CatFilterState({
    this.playlists = const [],
    this.playlistId = '',
    this.categoriesByType = const {},
    this.hidden = const {},
  });

  _CatFilterState copyWith({Set<String>? hidden}) => _CatFilterState(
        playlists: playlists,
        playlistId: playlistId,
        categoriesByType: categoriesByType,
        hidden: hidden ?? this.hidden,
      );
}

// ── Provider ─────────────────────────────────────────────────────────────────

/// Android CategoryFilterScreen paritesi: gizli kategoriler PLAYLIST BAŞINA;
/// üstte playlist seçici, Tümünü Göster / Tümünü Gizle.
final _catFilterProvider =
    AsyncNotifierProvider.autoDispose<_CatFilterNotifier, _CatFilterState>(
  _CatFilterNotifier.new,
);

class _CatFilterNotifier extends AutoDisposeAsyncNotifier<_CatFilterState> {
  HiddenCategoriesRepository get _hiddenRepo =>
      HiddenCategoriesRepository(ref.read(settingsRepoProvider));

  @override
  Future<_CatFilterState> build() async {
    final playlists = await ref.read(playlistRepoProvider).getAll();
    final active = ref.read(activePlaylistProvider);
    final id = playlists.any((p) => p.id == active)
        ? active
        : (playlists.firstOrNull?.id ?? '');
    return _load(playlists, id);
  }

  Future<_CatFilterState> _load(List<PlaylistModel> playlists, String id) async {
    if (id.isEmpty) return _CatFilterState(playlists: playlists);
    final repo = ref.read(channelRepoProvider);
    final results = await Future.wait([
      repo.getCategories(id, 'live'),
      repo.getCategories(id, 'movie'),
      repo.getCategories(id, 'series'),
    ]);
    return _CatFilterState(
      playlists: playlists,
      playlistId: id,
      categoriesByType: {
        'live': results[0],
        'movie': results[1],
        'series': results[2],
      },
      hidden: await _hiddenRepo.get(id),
    );
  }

  Future<void> selectPlaylist(String id) async {
    final s = state.value;
    if (s == null || id == s.playlistId) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(s.playlists, id));
  }

  Future<void> toggle(String category) async {
    final s = state.value;
    if (s == null) return;
    final next = Set<String>.from(s.hidden);
    if (!next.remove(category)) next.add(category);
    state = AsyncData(s.copyWith(hidden: next));
    await _hiddenRepo.set(s.playlistId, next);
  }

  Future<void> showAll() async {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(hidden: {}));
    await _hiddenRepo.set(s.playlistId, {});
  }

  Future<void> hideAll() async {
    final s = state.value;
    if (s == null) return;
    final all = <String>{
      for (final cats in s.categoriesByType.values) ...cats,
    };
    state = AsyncData(s.copyWith(hidden: all));
    await _hiddenRepo.set(s.playlistId, all);
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class CategoryFilterScreen extends ConsumerWidget {
  const CategoryFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_catFilterProvider);
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    final sections = <(String, String, IconData)>[
      ('live',   l.categoryFilterSectionLive,   Icons.live_tv),
      ('movie',  l.categoryFilterSectionMovie,  Icons.movie),
      ('series', l.categoryFilterSectionSeries, Icons.video_library),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.categoryFilterTitle),
        leading: BackButton(onPressed: () {
          // Önce navigate — refreshVisibility içindeki async SQL fetch'leri
          // back tuşuna immediate feedback engelliyor + exception fırlarsa
          // navigation hiç çalışmıyordu. Refresh fire-and-forget background'da.
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.settings);
          }
          ref.read(homeProvider.notifier).refreshVisibility()
              .catchError((_) {});
        }),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(_catFilterProvider.notifier).showAll(),
            child: Text(l.categoryFilterShowAll),
          ),
          TextButton(
            onPressed: () =>
                ref.read(_catFilterProvider.notifier).hideAll(),
            child: Text(l.categoryFilterHideAll,
                style: TextStyle(color: cs.error)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const ChannelListSkeleton(rows: 6),
        error: (e, _) => EmptyState.error(
          title:       l.errorWithDetails('$e'),
          actionLabel: l.retry,
          onAction:    () => ref.invalidate(_catFilterProvider),
        ),
        data: (state) {
          final noCats =
              state.categoriesByType.values.every((cats) => cats.isEmpty);
          if (state.playlists.length <= 1 && noCats) {
            return EmptyState(
              icon:  Icons.filter_list_off_rounded,
              title: l.categoryFilterEmpty,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              if (state.playlists.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: DropdownButtonFormField<String>(
                    value: state.playlistId,
                    decoration: InputDecoration(
                      labelText: l.categoryFilterPlaylist,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final p in state.playlists)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        ref.read(_catFilterProvider.notifier).selectPlaylist(id);
                      }
                    },
                  ),
                ),
              for (final (type, label, icon) in sections)
                if ((state.categoriesByType[type] ?? []).isNotEmpty)
                  _SectionCard(
                    label: label,
                    icon: icon,
                    categories: state.categoriesByType[type]!,
                    hidden: state.hidden,
                    onToggle: (cat) =>
                        ref.read(_catFilterProvider.notifier).toggle(cat),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> categories;
  final Set<String> hidden;
  final ValueChanged<String> onToggle;

  const _SectionCard({
    required this.label,
    required this.icon,
    required this.categories,
    required this.hidden,
    required this.onToggle,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final activeCount =
        widget.categories.where((c) => !widget.hidden.contains(c)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: Spacing.md),
              child: Row(
                children: [
                  Icon(widget.icon, size: 20, color: cs.primary),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      l.categoryFilterCount(widget.label, activeCount, widget.categories.length),
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            for (final cat in widget.categories)
              _CategoryRow(
                name: cat,
                visible: !widget.hidden.contains(cat),
                onToggle: () => widget.onToggle(cat),
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final bool visible;
  final VoidCallback onToggle;

  const _CategoryRow({
    required this.name,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.sm),
        child: Row(
          children: [
            Icon(
              visible ? Icons.visibility : Icons.visibility_off,
              size: 18,
              color: visible ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: visible ? cs.onSurface : cs.onSurfaceVariant,
                    decoration:
                        visible ? null : TextDecoration.lineThrough,
                  )),
            ),
            Switch(
              value: visible,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                onToggle();
              },
            ),
          ],
        ),
      ),
    );
  }
}
