import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../data/services/stalker/stalker_protocol.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Stalker / MAG alanlari (Android HomeComponents Stalker sekmesi): bilgi
/// karti, portal URL, MAC (yazarken bicimlenir) + "Uret", bicim ipucu.
/// Ekle ve Duzenle ekranlari ortak kullanir.
class StalkerFields extends StatelessWidget {
  final TextEditingController urlCtrl;
  final TextEditingController macCtrl;
  final bool showInfoCard;
  const StalkerFields({
    super.key,
    required this.urlCtrl,
    required this.macCtrl,
    this.showInfoCard = true,
  });

  void _onMacChanged(String v) {
    final f = StalkerMac.format(v);
    if (f == v) return;
    macCtrl.value = TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showInfoCard) ...[
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.playlistsStalkerCardTitle,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: TextSize.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l.playlistsStalkerCardBody,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: TextSize.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
        TextField(
          controller: urlCtrl,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l.playlistsStalkerPortalLabel,
            hintText: l.playlistsStalkerPortalHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: Spacing.md),
        TextField(
          controller: macCtrl,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          onChanged: _onMacChanged,
          decoration: InputDecoration(
            labelText: l.playlistsStalkerMacLabel,
            hintText: l.playlistsStalkerMacHint,
            helperText: l.playlistsStalkerMacHelp,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
            // iOS: rastgele MAC üretme düğmesi yok — App Review cihaz kimliği
            // taklidi olarak değerlendirebilir. MAC portal sağlayıcısından gelir.
          ),
        ),
      ],
    );
  }
}
