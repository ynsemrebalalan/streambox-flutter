import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../billing/providers/purchases_providers.dart';
import '../../billing/widgets/paywall_trigger.dart';
import '../epg_auto_refresh_controller.dart';

/// Pro: EPG arka plan otomatik yenileme tile'ı.
class EpgAutoRefreshTile extends ConsumerWidget {
  const EpgAutoRefreshTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final hours = ref.watch(epgAutoRefreshProvider);
    final isPro = ref.watch(isProProvider);

    final subtitle = !isPro
        ? l.cloudSyncProRequired
        : hours == 0
            ? l.epgAutoRefreshOff
            : l.epgAutoRefreshEvery(hours);

    return ListTile(
      leading: Icon(Icons.update, color: cs.onSurfaceVariant),
      title: Text(l.epgAutoRefreshTitle),
      subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        if (!isPro) {
          await requirePro(context, ref, PaywallTrigger.epg);
          return;
        }
        if (!context.mounted) return;
        final picked = await showModalBottomSheet<int>(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final v in const [0, 6, 12, 24])
                    RadioListTile<int>(
                      value: v,
                      groupValue: hours,
                      onChanged: (n) => Navigator.pop(ctx, n),
                      title: Text(v == 0
                          ? l.epgAutoRefreshOff
                          : l.epgAutoRefreshEvery(v)),
                    ),
                ],
              ),
            );
          },
        );
        if (picked != null) {
          await ref.read(epgAutoRefreshProvider.notifier).setInterval(picked);
        }
      },
    );
  }
}
