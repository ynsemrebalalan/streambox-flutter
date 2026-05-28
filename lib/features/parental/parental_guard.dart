import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../data/models/channel_model.dart';
import 'parental_lock_service.dart';
import 'widgets/pin_dialog.dart';

/// Kilitli bir kategoriye/kanala erişmeden önce çağrılır.
///
/// - Kategori kilitli değilse veya kilit kapalıysa → true (engel yok).
/// - Bu oturumda zaten PIN ile açıldıysa → true (tekrar sormaz).
/// - Aksi halde PIN diyaloğu gösterir; doğru PIN girilirse oturum boyunca
///   açar ve true döner, iptal/yanlış ise false döner.
Future<bool> ensureCategoryUnlocked(
  BuildContext context,
  WidgetRef ref,
  String category,
) async {
  if (category.trim().isEmpty) return true;
  final svc = ref.read(parentalLockServiceProvider);
  if (!await svc.isCategoryLocked(category)) return true;

  final key = category.toLowerCase();
  final unlocked = ref.read(parentalUnlockedProvider);
  if (unlocked.contains(key)) return true;

  if (!context.mounted) return false;
  final ok = await PinDialog.show(context, mode: PinDialogMode.verify);
  if (ok) {
    ref.read(parentalUnlockedProvider.notifier).update((s) => {...s, key});
  }
  return ok;
}

/// Bir kanalı oynatır — kanalın kategorisi kilitliyse önce PIN sorar.
/// PIN doğrulanmazsa navigasyon yapılmaz (içerik açılmaz).
Future<void> openChannelGuarded(
  BuildContext context,
  WidgetRef ref,
  ChannelModel channel,
) async {
  if (!await ensureCategoryUnlocked(context, ref, channel.category)) return;
  if (!context.mounted) return;
  context.push(
    AppRoutes.player,
    extra: {
      'channelId': channel.id,
      'channelUrl': channel.streamUrl,
      'title': channel.name,
      'initialPosition': channel.lastPosition,
      'streamType': channel.streamType,
    },
  );
}
