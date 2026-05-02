import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_state.dart';
import '../providers/auth_providers.dart';

/// Hesap detayları + sign-out + delete-account.
/// Login DEĞİLSE → "Hesap aç" CTA gösterir.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.authAccountTitle)),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: state.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (auth) {
              if (auth is AuthAuthenticated) {
                return _AuthenticatedView(state: auth);
              }
              return _GuestView();
            },
          ),
        ),
      ),
    );
  }
}

class _AuthenticatedView extends ConsumerStatefulWidget {
  final AuthAuthenticated state;
  const _AuthenticatedView({required this.state});

  @override
  ConsumerState<_AuthenticatedView> createState() =>
      _AuthenticatedViewState();
}

class _AuthenticatedViewState extends ConsumerState<_AuthenticatedView> {
  bool _busy = false;

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go(AppRoutes.home);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changePassword() async {
    final email = widget.state.email;
    if (email == null) return;
    final l = AppLocalizations.of(context);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.authResetPasswordSent)));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.authErrorGeneric(e.message ?? e.code))));
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.authDeleteAccount),
        content: Text(l.authDeleteAccountWarning),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.authDeleteAccountConfirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg = e.code == 'requires-recent-login'
            ? l.authRequiresRecentLogin
            : l.authErrorGeneric(e.message ?? e.code);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    (widget.state.email ?? '?').characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.state.email ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (!widget.state.emailVerified)
                        Text(l.authVerifyEmailHint,
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              if (widget.state.providerIds.contains('password'))
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: Text(l.authChangePassword),
                  onTap: _busy ? null : _changePassword,
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l.authSignOutButton),
                onTap: _busy ? null : _signOut,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _busy ? null : _confirmDeleteAccount,
          icon: const Icon(Icons.delete_forever),
          label: Text(l.authDeleteAccount),
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error),
        ),
      ],
    );
  }
}

class _GuestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.account_circle,
              size: 96,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l.authSignInPromptTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l.authSignInPromptDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push(AppRoutes.register),
            child: Text(l.authSignUpButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(l.authSignInButton),
          ),
        ],
      ),
    );
  }
}
