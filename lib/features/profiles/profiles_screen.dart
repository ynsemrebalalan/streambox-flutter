import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';

/// Phase 6 — Multi-profile yonetim ekrani.
///
/// Free tier: 1 profil (default). Yeni profil eklemeye calisirsa paywall.
/// Pro tier: sinirsiz profil + ekle/duzenle/sil.
class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  List<Profile>? _profiles;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final list = await ref.read(profileRepoProvider).getAll();
    if (mounted) {
      setState(() {
        _profiles = list;
        _loading = false;
      });
    }
  }

  Future<void> _addProfile() async {
    final isPro = ref.read(isProProvider);
    final count = _profiles?.length ?? 0;
    if (!isPro && count >= 1) {
      // Free tier: 1'den fazla profil = paywall.
      final allowed =
          await requirePro(context, ref, PaywallTrigger.multiProfile);
      if (!allowed || !mounted) return;
    }
    final l = AppLocalizations.of(context);
    final name = await _editNameDialog(initial: '', title: l.profileAdd);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(profileRepoProvider).create(name: name.trim());
    await _load();
  }

  Future<void> _renameProfile(Profile p) async {
    final l = AppLocalizations.of(context);
    final name = await _editNameDialog(initial: p.name, title: l.profileEdit);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(profileRepoProvider).update(p.copyWith(name: name.trim()));
    await _load();
  }

  Future<void> _deleteProfile(Profile p) async {
    if (p.isDefault) return;
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.profileDelete),
        content: Text(l.profileDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final active = ref.read(activeProfileProvider);
    if (active == p.id) {
      ref.read(activeProfileProvider.notifier)
          .setActive(ProfileRepository.defaultProfileId);
    }
    await ref.read(profileRepoProvider).delete(p.id);
    await _load();
  }

  Future<String?> _editNameDialog({
    required String initial,
    required String title,
  }) async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: initial);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: l.profileNameLabel),
          maxLength: 32,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = ref.watch(activeProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileSwitcherTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProfile,
        icon: const Icon(Icons.person_add),
        label: Text(l.profileAdd),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                if (_profiles == null || _profiles!.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xl),
                      child: Text(l.errorGeneric),
                    ),
                  )
                else
                  for (final p in _profiles!)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(_iconFor(p.icon)),
                        ),
                        title: Text(
                          p.isDefault ? '${p.name} (${l.profileDefaultName})' : p.name,
                          style: TextStyle(
                            fontWeight: active == p.id
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            switch (v) {
                              case 'switch':
                                ref.read(activeProfileProvider.notifier)
                                    .setActive(p.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l.profileSwitched)),
                                );
                                break;
                              case 'edit':
                                _renameProfile(p);
                                break;
                              case 'delete':
                                _deleteProfile(p);
                                break;
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (active != p.id)
                              PopupMenuItem(
                                value: 'switch',
                                child: Row(children: [
                                  const Icon(Icons.switch_account, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l.profileSwitcherTitle),
                                ]),
                              ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                const Icon(Icons.edit, size: 18),
                                const SizedBox(width: 8),
                                Text(l.profileEdit),
                              ]),
                            ),
                            if (!p.isDefault)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  const Icon(Icons.delete, size: 18, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(l.profileDelete,
                                      style: const TextStyle(color: Colors.red)),
                                ]),
                              ),
                          ],
                        ),
                        onTap: active == p.id
                            ? null
                            : () {
                                ref.read(activeProfileProvider.notifier)
                                    .setActive(p.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l.profileSwitched)),
                                );
                              },
                      ),
                    ),
              ],
            ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'child_care': return Icons.child_care;
      case 'face':       return Icons.face;
      case 'sports':     return Icons.sports_basketball;
      case 'movie':      return Icons.movie;
      default:           return Icons.person;
    }
  }
}
