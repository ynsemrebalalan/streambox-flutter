import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'parental_lock_service.dart';
import 'widgets/pin_dialog.dart';

/// Ebeveyn kilidi ayarlar ekranı.
/// - PIN oluştur / değiştir / sil
/// - Kilit aç/kapat
/// - Kilitlenecek kategorileri seç
class ParentalLockScreen extends ConsumerStatefulWidget {
  const ParentalLockScreen({super.key});

  @override
  ConsumerState<ParentalLockScreen> createState() =>
      _ParentalLockScreenState();
}

class _ParentalLockScreenState extends ConsumerState<ParentalLockScreen> {
  bool _hasPin = false;
  bool _enabled = false;
  Set<String> _locked = {};
  List<String> _allCategories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final svc = ref.read(parentalLockServiceProvider);
    final hasPin = await svc.hasPin();
    final enabled = await svc.isEnabled();
    final locked = await svc.lockedCategories();

    final activePid = ref.read(activePlaylistProvider);
    final repo = ref.read(channelRepoProvider);
    final live = await repo.getCategories(activePid, 'live');
    final movie = await repo.getCategories(activePid, 'movie');
    final series = await repo.getCategories(activePid, 'series');
    final all = <String>{...live, ...movie, ...series}.toList()..sort();

    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _enabled = enabled;
      _locked = locked;
      _allCategories = all;
      _loading = false;
    });
  }

  Future<void> _setupPin() async {
    final ok = await PinDialog.show(context, mode: PinDialogMode.create);
    if (ok) await _load();
  }

  Future<void> _changePin() async {
    final ok = await PinDialog.show(context, mode: PinDialogMode.change);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).parentalPinChanged)),
      );
    }
  }

  Future<void> _removePin() async {
    final ok = await PinDialog.show(context, mode: PinDialogMode.verify);
    if (!ok || !mounted) return;
    await ref.read(parentalLockServiceProvider).clearPin();
    if (!mounted) return;
    await _load();
  }

  Future<void> _toggleEnabled(bool v) async {
    if (!_hasPin) {
      await _setupPin();
      return;
    }
    if (_enabled && !v) {
      // Kilidi kapatmak için PIN doğrula.
      final ok = await PinDialog.show(context, mode: PinDialogMode.verify);
      if (!ok) return;
    }
    await ref.read(parentalLockServiceProvider).setEnabled(v);
    if (!mounted) return;
    setState(() => _enabled = v);
  }

  Future<void> _toggleCategory(String cat, bool v) async {
    final next = {..._locked};
    if (v) {
      next.add(cat.toLowerCase());
    } else {
      next.remove(cat.toLowerCase());
    }
    await ref.read(parentalLockServiceProvider).setLockedCategories(next);
    if (!mounted) return;
    setState(() => _locked = next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.parentalLockTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.parentalLockTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l.parentalLockEnable),
            subtitle: Text(_hasPin
                ? l.parentalLockEnabledHint
                : l.parentalLockSetupFirst),
            value: _enabled && _hasPin,
            onChanged: _toggleEnabled,
          ),
          const Divider(),
          if (!_hasPin)
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l.parentalSetupPin),
              onTap: _setupPin,
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(l.parentalChangePin),
              onTap: _changePin,
            ),
            ListTile(
              leading: const Icon(Icons.lock_open, color: Colors.red),
              title: Text(l.parentalRemovePin,
                  style: const TextStyle(color: Colors.red)),
              onTap: _removePin,
            ),
          ],
          const Divider(),
          if (_hasPin && _enabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l.parentalLockedCategoriesTitle,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (_allCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.parentalNoCategories,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              )
            else
              ..._allCategories.map((c) => CheckboxListTile(
                    title: Text(c),
                    value: _locked.contains(c.toLowerCase()),
                    onChanged: (v) => _toggleCategory(c, v ?? false),
                  )),
          ],
        ],
      ),
    );
  }
}
