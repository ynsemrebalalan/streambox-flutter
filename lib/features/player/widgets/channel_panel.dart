import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/channel_model.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Oynatıcı içi kanal paneli (Android ChannelPanel): mevcut kategorinin
/// kanalları; dokununca oynatıcıdan çıkmadan geçiş.
Future<ChannelModel?> showChannelPanel(
  BuildContext context, {
  required List<ChannelModel> channels,
  required String currentId,
}) {
  return showModalBottomSheet<ChannelModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xF0101018),
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      final initial = channels.indexWhere((c) => c.id == currentId);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.live_tv, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(l.playerPanelChannels(channels.length),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                controller: ScrollController(
                    initialScrollOffset: initial > 3 ? (initial - 2) * 56.0 : 0),
                itemExtent: 56,
                itemCount: channels.length,
                itemBuilder: (_, i) {
                  final c = channels[i];
                  final current = c.id == currentId;
                  return ListTile(
                    selected: current,
                    selectedTileColor: AppColors.accent.withValues(alpha: 0.18),
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: c.logoUrl.isEmpty
                          ? const Icon(Icons.tv, color: Colors.white54)
                          : CachedNetworkImage(
                              imageUrl: c.logoUrl,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.tv, color: Colors.white54),
                            ),
                    ),
                    title: Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: current ? AppColors.accent : Colors.white,
                            fontWeight: current ? FontWeight.w700 : FontWeight.normal)),
                    trailing: current
                        ? const Icon(Icons.play_arrow, color: AppColors.accent)
                        : null,
                    onTap: () => Navigator.pop(ctx, current ? null : c),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
