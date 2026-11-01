import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import 'other_apps.dart';

/// "Diğer uygulamalarımız" ekranı. Liste daveddeva.com/apps.json'dan gelir (bkz. other_apps.dart).
class OtherAppsScreen extends StatefulWidget {
  const OtherAppsScreen({super.key, required this.selfPackage, required this.lang});

  final String selfPackage;
  final String lang;

  @override
  State<OtherAppsScreen> createState() => _OtherAppsScreenState();
}

class _OtherAppsScreenState extends State<OtherAppsScreen> {
  late final _repo = OtherAppsRepository(selfPackage: widget.selfPackage);
  late Future<List<OtherApp>> _future = _load();

  Future<List<OtherApp>> _load({bool force = false}) => _repo.load(
        platform: Platform.isIOS ? OtherAppsPlatform.ios : OtherAppsPlatform.android,
        lang: widget.lang,
        forceRefresh: force,
      );

  Future<void> _refresh() async {
    final next = _load(force: true);
    setState(() => _future = next);
    await next;
  }

  Future<void> _open(OtherApp app) async {
    if (app.kids && !await _parentalGate()) return;
    final ok = await launchUrl(Uri.parse(app.storeUrl), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).otherAppsOpenFailed)),
      );
    }
  }

  /// Çocuk uygulamalarında mağazaya çıkmadan önce yetişkin doğrulaması (Apple 1.3, Google Families).
  Future<bool> _parentalGate() async {
    final l10n = AppLocalizations.of(context);
    final rnd = Random();
    final a = 11 + rnd.nextInt(9);
    final b = 11 + rnd.nextInt(9);
    final controller = TextEditingController();
    final passed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.otherAppsGateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.otherAppsGateQuestion} $a + $b = ?'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.otherAppsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim() == '${a + b}'),
            child: Text(l10n.otherAppsContinue),
          ),
        ],
      ),
    );
    controller.dispose();
    return passed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otherAppsTitle)),
      body: FutureBuilder<List<OtherApp>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final apps = snapshot.data ?? const <OtherApp>[];
          if (apps.isEmpty) {
            return _EmptyState(
              text: l10n.otherAppsEmpty,
              retry: l10n.otherAppsRetry,
              onRetry: _refresh,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: apps.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
              itemBuilder: (_, i) => _AppTile(app: apps[i], onTap: () => _open(apps[i])),
            ),
          );
        },
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app, required this.onTap});

  final OtherApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.apps_rounded, color: scheme.onSurfaceVariant),
    );
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.square(
          dimension: 56,
          child: app.iconUrl == null
              ? fallback
              : Image.network(
                  app.iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback,
                ),
        ),
      ),
      title: Text(app.name, style: Theme.of(context).textTheme.titleSmall),
      subtitle: app.tagline.isEmpty
          ? null
          : Text(app.tagline, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.open_in_new_rounded, size: 20, color: scheme.onSurfaceVariant),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text, required this.retry, required this.onRetry});

  final String text;
  final String retry;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(retry)),
          ],
        ),
      ),
    );
  }
}
