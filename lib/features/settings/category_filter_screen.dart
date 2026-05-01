import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/home_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

class _CatFilterState {
  final Map<String, List<String>> categoriesByType; // live/movie/series → [cat]
  final Set<String> hidden;
  final bool isLoading;

  const _CatFilterState({
    this.categoriesByType = const {},
    this.hidden = const {},
    this.isLoading = true,
  });

  _CatFilterState copyWith({
    Map<String, List<String>>? categoriesByType,
    Set<String>? hidden,
    bool? isLoading,
  }) =>
      _CatFilterState(
        categoriesByType: categoriesByType ?? this.categoriesByType,
        hidden: hidden ?? this.hidden,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ── Provider ─────────────────────────────────────────────────────────────────

final _catFilterProvider =
    AsyncNotifierProvider<_CatFilterNotifier, _CatFilterState>(
  _CatFilterNotifier.new,
);

class _CatFilterNotifier extends AsyncNotifier<_CatFilterState> {
  @override
  Future<_CatFilterState> build() async {
    final activeId = ref.read(activePlaylistProvider);
    if (activeId.isEmpty) {
      return const _CatFilterState(isLoading: false);
    }
    final repo = ref.read(channelRepoProvider);
    final settings = ref.read(settingsRepoProvider);

    final results = await Future.wait([
      repo.getCategories(activeId, 'live'),
      repo.getCategories(activeId, 'movie'),
      repo.getCategories(activeId, 'series'),
      settings.get(SettingsKeys.hiddenCategories),
    ]);

    final hidden = <String>{};
    final raw = results[3] as String?;
    if (raw != null && raw.isNotEmpty) {
      hidden.addAll(
          (jsonDecode(raw) as List).cast<String>());
    }

    return _CatFilterState(
      categoriesByType: {
        'live': results[0] as List<String>,
        'movie': results[1] as List<String>,
        'series': results[2] as List<String>,
      },
      hidden: hidden,
      isLoading: false,
    );
  }

  Future<void> toggle(String category) async {
    final s = state.value;
    if (s == null) return;
    final next = Set<String>.from(s.hidden);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }
    state = AsyncData(s.copyWith(hidden: next));
    await _persist(next);
  }

  Future<void> showAll() async {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(hidden: {}));
    await _persist({});
  }

  Future<void> hideAll() async {
    final s = state.value;
    if (s == null) return;
    final all = <String>{};
    for (final cats in s.categoriesByType.values) {
      all.addAll(cats);
    }
    state = AsyncData(s.copyWith(hidden: all));
    await _persist(all);
  }

  Future<void> _persist(Set<String> hidden) async {
    await ref
        .read(settingsRepoProvider)
        .set(SettingsKeys.hiddenCategories, jsonEncode(hidden.toList()));
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
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorWithDetails('$e'))),
        data: (state) {
          if (state.categoriesByType.isEmpty ||
              state.categoriesByType.values.every((cats) => cats.isEmpty)) {
            return Center(
              child: Text(l.categoryFilterEmpty,
                  style: TextStyle(color: cs.onSurfaceVariant)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
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
                  Icon(widget.icon, size: 20, color: AppColors.accent),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      l.categoryFilterCount(widget.label, activeCount, widget.categories.length),
                      style: const TextStyle(
                          fontSize: TextSize.bodyLg,
                          fontWeight: FontWeight.w600),
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
              color: visible ? AppColors.accent : cs.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(name,
                  style: TextStyle(
                    fontSize: TextSize.body,
                    color: visible ? cs.onSurface : cs.onSurfaceVariant,
                    decoration:
                        visible ? null : TextDecoration.lineThrough,
                  )),
            ),
            Switch(
              value: visible,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
