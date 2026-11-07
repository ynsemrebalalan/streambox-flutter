import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../billing/providers/purchases_providers.dart';
import '../../billing/widgets/paywall_trigger.dart';

/// Pro: EPG otomatik tazeleme bilgisi. Android'deki gibi seçilebilir aralık
/// yok — rehber bitmek üzereyken otomatik yenilenir.
class EpgAutoRefreshTile extends ConsumerWidget {
  const EpgAutoRefreshTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isPro = ref.watch(isProProvider);

    return ListTile(
      leading: Icon(Icons.update, color: cs.onSurfaceVariant),
      title: Text(l.epgAutoRefreshTitle),
      subtitle: Text(isPro ? l.epgAutoRefreshAuto : l.cloudSyncProRequired,
          style: TextStyle(color: cs.onSurfaceVariant)),
      trailing: isPro ? null : const Icon(Icons.chevron_right),
      onTap: isPro
          ? null
          : () => requirePro(context, ref, PaywallTrigger.epg),
    );
  }
}
