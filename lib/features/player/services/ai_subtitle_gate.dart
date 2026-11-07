import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/secure_storage.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/ai_proxy_client.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../billing/providers/purchases_providers.dart';
import '../../billing/widgets/paywall_trigger.dart';
import '../logic/ai_entitlement.dart';

/// AI altyazı kapısı (Android PlayerScreen.runAiGate paritesi, deneme SUNUCUDA):
///   Pro → geç · kendi OpenAI anahtarı → geç · aksi halde `entitlement start=1`:
///   allowed → "deneme başladı / N gün kaldı" · değilse "deneme bitti" + paywall.
///   Sunucuya ulaşılamazsa fail-open (sunucu her AI isteğinde yeniden doğrular).
///
/// Dönüş: AI altyazı başlatılabilir mi.
Future<bool> runAiSubtitleGate(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);

  final provider = await SettingsRepository().get(SettingsKeys.aiProvider) ?? 'groq';
  final key = await SecureStorage.getOpenAiKey();
  if (provider == 'openai' && key.isEmpty) {
    messenger?.showSnackBar(SnackBar(content: Text(l.aiSubErrNoOpenAiKey)));
    return false;
  }
  final hasOwnKey = provider == 'openai' && key.isNotEmpty;

  var isPro = ref.read(isProProvider);
  if (!isPro && !hasOwnKey) {
    // Açılışta RC henüz yanıt vermemiş olabilir — karar öncesi bir kez tazele.
    try {
      await ref
          .read(purchasesNotifierProvider.notifier)
          .refresh()
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
    isPro = ref.read(isProProvider);
  }

  final server =
      (isPro || hasOwnKey) ? null : await fetchAiEntitlement(start: true);
  final outcome = decideAiGate(
    isPro: isPro,
    hasOwnKey: hasOwnKey,
    server: server,
    now: DateTime.now().toUtc(),
  );

  switch (outcome) {
    case AiGateAllowed(reason: AiGateReason.trial, :final justStarted, :final daysLeft):
      messenger?.showSnackBar(SnackBar(
        content: Text(justStarted
            ? l.aiTrialStarted(kAiTrialDays)
            : l.aiTrialDaysLeft(daysLeft)),
        duration: const Duration(seconds: 4),
      ));
      return true;
    case AiGateAllowed():
      return true;
    case AiGateDenied():
      if (!context.mounted) return false;
      return showAiTrialEndedPaywall(context, ref);
  }
}

/// "Deneme bitti" metni + paywall (PaywallTrigger.aiSubtitle).
Future<bool> showAiTrialEndedPaywall(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(l.paywallAiTrialEnded), duration: const Duration(seconds: 4)),
  );
  return requirePro(context, ref, PaywallTrigger.aiSubtitle);
}
