import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_state.dart';
import '../../auth/providers/auth_providers.dart';
import '../../billing/providers/purchases_providers.dart';
import '../../billing/widgets/paywall_trigger.dart';
import '../cloud_sync_controller.dart';

/// Settings içinde gösterilen Cloud Sync özet satırı + manuel "Şimdi Senkron"
/// butonu. Pro değil → paywall; auth değil → login → paywall.
class CloudSyncTile extends ConsumerWidget {
  const CloudSyncTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final status = ref.watch(cloudSyncControllerProvider);
    final isPro = ref.watch(isProProvider);
    final auth  = ref.watch(authStateProvider).valueOrNull;
    final isAuth = auth is AuthAuthenticated;

    final subtitle = !isPro
        ? l.cloudSyncProRequired
        : !isAuth
            ? l.cloudSyncSignInRequired
            : status.lastSyncedAt == null
                ? l.cloudSyncNever
                : l.cloudSyncLastAt(_humanTime(status.lastSyncedAt!, l));

    return ListTile(
      leading: Icon(
        status.phase == CloudSyncPhase.error
            ? Icons.cloud_off
            : Icons.cloud_sync,
        color: status.phase == CloudSyncPhase.error
            ? cs.error
            : cs.onSurfaceVariant,
      ),
      title: Text(l.cloudSyncTitle),
      subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
      trailing: status.phase == CloudSyncPhase.syncing
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l.cloudSyncSyncNow,
              onPressed: () async {
                if (!isPro) {
                  await requirePro(
                      context, ref, PaywallTrigger.cloudSync);
                  return;
                }
                await ref
                    .read(cloudSyncControllerProvider.notifier)
                    .syncNow();
              },
            ),
    );
  }

  static String _humanTime(DateTime dt, AppLocalizations l) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l.cloudSyncJustNow;
    if (diff.inHours < 1)   return l.cloudSyncMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1)    return l.cloudSyncHoursAgo(diff.inHours);
    return l.cloudSyncDaysAgo(diff.inDays);
  }
}
