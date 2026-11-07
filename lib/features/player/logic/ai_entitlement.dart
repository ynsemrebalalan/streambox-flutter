import 'dart:convert';

/// Sunucu (groq-proxy.php?action=entitlement) AI hak durumu.
///
/// 7 günlük AI deneme süresi SUNUCU tarafında tutulur (Android'in yerel/
/// Firestore deneme motoru iOS'a taşınmadı). Yanıt:
/// `{"pro":bool,"trialActive":bool,"trialEndsAt":unix|null,"allowed":bool}`.
class AiEntitlementStatus {
  final bool pro;
  final bool trialActive;
  final bool allowed;
  final DateTime? trialEndsAt;

  const AiEntitlementStatus({
    required this.pro,
    required this.trialActive,
    required this.allowed,
    this.trialEndsAt,
  });

  /// Gövde JSON nesnesi değilse null (çağıran "sunucuya ulaşılamadı" sayar).
  static AiEntitlementStatus? tryParse(String? body) {
    if (body == null || body.trim().isEmpty) return null;
    try {
      final json = jsonDecode(body);
      if (json is! Map) return null;
      return AiEntitlementStatus(
        pro: json['pro'] == true,
        trialActive: json['trialActive'] == true,
        allowed: json['allowed'] == true,
        trialEndsAt: _parseUnix(json['trialEndsAt']),
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseUnix(Object? v) {
    final secs = switch (v) {
      final num n => n.toInt(),
      final String s => int.tryParse(s.trim()),
      _ => null,
    };
    if (secs == null || secs <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(secs * 1000, isUtc: true);
  }
}

const int kAiTrialDays = 7;

/// Kalan deneme günü (yukarı yuvarlanır, 1..7). Bitmiş/bilinmiyorsa 0.
int trialDaysLeft(DateTime? endsAt, DateTime now) {
  if (endsAt == null) return 0;
  final remaining = endsAt.difference(now);
  if (remaining <= Duration.zero) return 0;
  const day = Duration(days: 1);
  final days = (remaining.inMilliseconds + day.inMilliseconds - 1) ~/ day.inMilliseconds;
  return days.clamp(1, kAiTrialDays);
}

enum AiGateReason { pro, ownKey, trial, failOpen }

sealed class AiGateOutcome {
  const AiGateOutcome();
}

class AiGateAllowed extends AiGateOutcome {
  final AiGateReason reason;
  final int daysLeft;
  final bool justStarted;
  const AiGateAllowed(this.reason, {this.daysLeft = 0, this.justStarted = false});
}

class AiGateDenied extends AiGateOutcome {
  final DateTime? trialEndsAt;
  const AiGateDenied({this.trialEndsAt});
}

/// AI altyazı kapısı (saf karar).
///
/// Pro → geç; kendi OpenAI anahtarı → geç (ücreti kullanıcı öder); sunucuya
/// ulaşılamadı → geç (sunucu zaten her istekte yeniden doğrular, fail-open);
/// sunucu "allowed" → deneme; aksi halde paywall.
AiGateOutcome decideAiGate({
  required bool isPro,
  required bool hasOwnKey,
  required AiEntitlementStatus? server,
  required DateTime now,
}) {
  if (isPro) return const AiGateAllowed(AiGateReason.pro);
  if (hasOwnKey) return const AiGateAllowed(AiGateReason.ownKey);
  if (server == null) return const AiGateAllowed(AiGateReason.failOpen);
  if (server.pro) return const AiGateAllowed(AiGateReason.pro);
  if (!server.allowed) return AiGateDenied(trialEndsAt: server.trialEndsAt);
  final ends = server.trialEndsAt;
  final days = trialDaysLeft(ends, now);
  // Sunucu "şimdi başladı" bilgisini ayrıca vermiyor: kalan süre tam 7 güne
  // çok yakınsa (≤ 2 dk sapma) deneme bu istekle başlamış demektir.
  final justStarted = ends != null &&
      ends.difference(now) >=
          const Duration(days: kAiTrialDays) - const Duration(minutes: 2);
  return AiGateAllowed(AiGateReason.trial, daysLeft: days, justStarted: justStarted);
}
