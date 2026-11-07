import 'package:flutter/material.dart';

/// iOS-style large-title page: a [SliverAppBar.large] that collapses into a
/// regular bar on scroll, followed by [slivers].
///
/// For non-list states (loading / empty / error) pass a single
/// `SliverFillRemaining(hasScrollBody: false, child: ...)`.
class LargeTitleScaffold extends StatelessWidget {
  const LargeTitleScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions,
    this.leading,
    this.onRefresh,
    this.floatingActionButton,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget>? actions;
  final Widget? leading;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      // RefreshIndicator needs an always-scrollable view even when short.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          leading: leading,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: actions,
        ),
        ...slivers,
        // Home indicator / FAB clearance.
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom +
                (floatingActionButton != null ? 88 : 16),
          ),
        ),
      ],
    );
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: onRefresh == null
          ? scroll
          : RefreshIndicator(onRefresh: onRefresh!, child: scroll),
    );
  }
}
