import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_authErrorMessage(e));
    } catch (e) {
      if (mounted) _showError(_genericError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'cancelled' && mounted) _showError(_authErrorMessage(e));
    } catch (e) {
      if (mounted) _showError(_genericError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
      if (mounted) context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'cancelled' && mounted) _showError(_authErrorMessage(e));
    } catch (e) {
      if (mounted) _showError(_genericError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  String _authErrorMessage(FirebaseAuthException e) {
    final l = AppLocalizations.of(context);
    return switch (e.code) {
      'invalid-email' => l.authErrorInvalidEmail,
      'wrong-password' || 'invalid-credential' || 'user-not-found' =>
        l.authErrorWrongPassword,
      'too-many-requests' => l.authErrorTooManyRequests,
      'network-request-failed' => l.authErrorNetwork,
      'requires-recent-login' => l.authRequiresRecentLogin,
      _ => l.authErrorGeneric(e.message ?? e.code),
    };
  }

  String _genericError(Object e) =>
      AppLocalizations.of(context).authErrorGeneric(e.toString());

  Future<void> _openResetPasswordSheet() async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.authResetPasswordTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l.authResetPasswordHint,
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: l.authEmailLabel, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final email = ctrl.text.trim();
                    if (email.isEmpty) return;
                    try {
                      await ref
                          .read(authRepositoryProvider)
                          .sendPasswordReset(email);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(l.authResetPasswordSent)));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(_authErrorMessage(e))));
                      }
                    }
                  },
                  child: Text(l.authResetPasswordTitle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.authSignInTitle)),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                        labelText: l.authEmailLabel,
                        border: const OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || !v.contains('@') || !v.contains('.'))
                            ? l.authErrorInvalidEmail
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                        labelText: l.authPasswordLabel,
                        border: const OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 6)
                        ? l.authErrorWeakPassword
                        : null,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _busy ? null : _openResetPasswordSheet,
                      child: Text(l.authForgotPassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _busy ? null : _signInWithEmail,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(l.authSignInButton),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l.authOrDivider,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SocialSignInButton(
                    provider: SocialProvider.google,
                    label: l.authSignInWithGoogle,
                    onPressed: _busy ? null : _signInWithGoogle,
                  ),
                  if (Platform.isIOS || Platform.isMacOS) ...[
                    const SizedBox(height: 12),
                    SocialSignInButton(
                      provider: SocialProvider.apple,
                      label: l.authSignInWithApple,
                      onPressed: _busy ? null : _signInWithApple,
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed:
                        _busy ? null : () => context.push(AppRoutes.register),
                    child: Text(l.authNoAccountQuestion),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
