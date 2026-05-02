import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/providers/purchases_providers.dart';
import '../billing/widgets/paywall_trigger.dart';

/// Premium tema seçici. Default 2 tema herkese açık,
/// 4 Pro tema kilit + paywall.
class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isPro = ref.watch(isProProvider);
    final current = ref.watch(themeVariantProvider);

    final themes = <(PremiumTheme, String, List<Color>)>[
      (PremiumTheme.defaultDark,  l.themeDefaultDark,  _swatch(AppTheme.dark)),
      (PremiumTheme.defaultLight, l.themeDefaultLight, _swatch(AppTheme.light)),
      (PremiumTheme.crimson,      l.themeCrimson,      _swatch(AppTheme.crimson)),
      (PremiumTheme.royal,        l.themeRoyal,        _swatch(AppTheme.royal)),
      (PremiumTheme.forest,       l.themeForest,       _swatch(AppTheme.forest)),
      (PremiumTheme.ocean,        l.themeOcean,        _swatch(AppTheme.ocean)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.themePickerTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: themes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final (variant, name, swatch) = themes[i];
          final isLocked = variant.isPro && !isPro;
          final isSelected = current == variant;
          return _ThemeCard(
            name: name,
            swatch: swatch,
            isPro: variant.isPro,
            isLocked: isLocked,
            isSelected: isSelected,
            onTap: () async {
              if (isLocked) {
                final ok = await requirePro(
                    context, ref, PaywallTrigger.premiumTheme);
                if (!ok) return;
              }
              ref
                  .read(themeVariantProvider.notifier)
                  .setVariant(variant);
            },
          );
        },
      ),
    );
  }

  static List<Color> _swatch(ThemeData t) => [
        t.colorScheme.primary,
        t.colorScheme.secondary,
        t.colorScheme.surface,
        t.scaffoldBackgroundColor,
      ];
}

class _ThemeCard extends StatelessWidget {
  final String name;
  final List<Color> swatch;
  final bool isPro;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.name,
    required this.swatch,
    required this.isPro,
    required this.isLocked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
          color: cs.surface,
        ),
        child: Row(
          children: [
            // Swatch preview
            Row(
              mainAxisSize: MainAxisSize.min,
              children: swatch
                  .map((c) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 24,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.white24, width: 0.5),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
            if (isPro)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('PRO',
                    style: TextStyle(
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            const SizedBox(width: 8),
            if (isLocked) Icon(Icons.lock, size: 16, color: cs.onSurfaceVariant),
            if (isSelected) Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
