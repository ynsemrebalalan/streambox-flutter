import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Centered empty / error state: icon, title, optional message and action.
///
/// Use [EmptyState.error] for failures — the icon switches to `cs.error`.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.isError = false,
    this.autofocusAction = false,
  });

  const EmptyState.error({
    super.key,
    this.icon = Icons.cloud_off_rounded,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon = Icons.refresh,
    this.onAction,
    this.autofocusAction = true,
  }) : isError = true;

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool isError;
  final bool autofocusAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasAction = actionLabel != null && onAction != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xxl,
          vertical: Spacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: isError ? cs.error : cs.onSurfaceVariant),
              const SizedBox(height: Spacing.lg),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: Spacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
              if (hasAction) ...[
                const SizedBox(height: Spacing.xl),
                actionIcon != null
                    ? FilledButton.tonalIcon(
                        autofocus: autofocusAction,
                        onPressed: onAction,
                        icon: Icon(actionIcon),
                        label: Text(actionLabel!),
                      )
                    : FilledButton.tonal(
                        autofocus: autofocusAction,
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
