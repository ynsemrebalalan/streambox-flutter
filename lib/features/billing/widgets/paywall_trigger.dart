import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/data/auth_state.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/purchases_providers.dart';

/// Bir feature'a girmeden önce kullanıcının Pro olup olmadığını kontrol et.
/// Akış:
///   1. Pro ise true döner (özellik açık).
///   2. Anonim/login değilse → /login → success'te /paywall'a otomatik geç.
///   3. Login ama free ise → /paywall.
///   4. Satın alma başarılı → true; iptal → false.
///
/// Çağrı yerinde:
/// ```dart
/// final ok = await requirePro(context, ref, PaywallTrigger.aiSubtitle);
/// if (ok) startAiSubtitle();
/// ```
Future<bool> requirePro(
  BuildContext context,
  WidgetRef ref,
  PaywallTrigger trigger,
) async {
  if (ref.read(isProProvider)) return true;

  final authState = ref.read(authStateProvider).valueOrNull;
  final needsLogin =
      authState is AuthAnonymous || authState is AuthUnauthenticated;

  if (needsLogin) {
    // /login akışı sonrası kullanıcı home'a düşer; paywall'ı login_screen
    // navigation tamamlandıktan sonra otomatik aç. Login screen extra param
    // ile bunu yapmıyor (basit tutuldu) — burada manuel: login push'undan
    // sonra paywall'ı yine push et.
    final loggedIn =
        await context.push<bool>(AppRoutes.login) ?? _hasUserAfterPush(ref);
    if (!loggedIn) return false;
    if (!context.mounted) return false;
    if (ref.read(isProProvider)) return true;
  }

  if (!context.mounted) return false;

  final purchased = await context.push<bool>(
    AppRoutes.paywall,
    extra: <String, dynamic>{'trigger': trigger.name},
  );
  return purchased ?? false;
}

bool _hasUserAfterPush(WidgetRef ref) {
  final auth = ref.read(authStateProvider).valueOrNull;
  return auth is AuthAuthenticated;
}

/// Hangi noktadan paywall açıldı? Analytics + paywall copy variant için.
enum PaywallTrigger {
  secondPlaylist,
  aiSubtitle,
  cloudSync,
  tvApp,
  settingsCta,
  parentalLock,    // Phase 1: ebeveyn kilidi
  premiumTheme,    // Phase 1: özel temalar
  watchlist,       // Phase 1: izleme listesi (free şu an, ileride Pro olabilir)
  epg,             // Phase 3: TV rehberi otomatik fetch
  pip,             // Phase 4: Picture-in-Picture
  airplay,         // Phase 4: AirPlay/Cast
  multiProfile,    // Phase 6: çoklu profil
  noAds,           // Phase 5: reklamsız
}
