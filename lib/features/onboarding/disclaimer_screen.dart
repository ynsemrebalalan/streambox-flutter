import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/repositories/settings_repository.dart';

final disclaimerAcceptedProvider = FutureProvider<bool>((ref) async {
  final val = await ref.read(settingsRepoProvider).get(SettingsKeys.disclaimerAccepted);
  return val == 'true';
});

class DisclaimerScreen extends ConsumerWidget {
  final VoidCallback onAccepted;
  const DisclaimerScreen({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.play_circle_outline,
                      size: 40, color: AppColors.accent),
                  const SizedBox(width: Spacing.md),
                  const Text(
                    'IPTV AI Player',
                    style: TextStyle(
                        fontSize: TextSize.titleLg,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                'Important Notice',
                style: TextStyle(
                    fontSize: TextSize.titleSm,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'IPTV AI Player is a media player application. '
                'It does NOT provide, host, or distribute any content.',
                style: TextStyle(
                    fontSize: TextSize.body,
                    color: cs.onSurface,
                    height: 1.5),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'To use this app you must provide your own M3U playlist URL '
                'or Xtream Codes credentials from a service you are legally '
                'subscribed to.',
                style: TextStyle(
                    fontSize: TextSize.body,
                    color: cs.onSurface,
                    height: 1.5),
              ),
              const SizedBox(height: Spacing.md),
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Radius.card),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: cs.error, size: 20),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Using this app to access content you do not have '
                        'rights to is illegal. The developer is not responsible '
                        'for misuse.',
                        style: TextStyle(
                            fontSize: TextSize.caption,
                            color: cs.onSurface,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: Dimens.buttonHeight,
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(settingsRepoProvider)
                        .set(SettingsKeys.disclaimerAccepted, 'true');
                    onAccepted();
                  },
                  child: const Text(
                    'I Understand & Accept',
                    style: TextStyle(fontSize: TextSize.bodyLg),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Center(
                child: Text(
                  'By continuing you agree to use only legally licensed content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: TextSize.caption,
                      color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
