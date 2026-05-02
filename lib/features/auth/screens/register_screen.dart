import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../../onboarding/legal_notice_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      _showError(AppLocalizations.of(context).authAcceptTerms);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).registerWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).authVerifyEmailHint),
      ));
      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_authErrorMessage(e));
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context).authErrorGeneric(e.toString()));
      }
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
      'weak-password' => l.authErrorWeakPassword,
      'email-already-in-use' => l.authErrorEmailInUse,
      'too-many-requests' => l.authErrorTooManyRequests,
      'network-request-failed' => l.authErrorNetwork,
      _ => l.authErrorGeneric(e.message ?? e.code),
    };
  }

  void _openLegal() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const LegalNoticeScreen(),
      fullscreenDialog: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.authSignUpTitle)),
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
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                        labelText: l.authPasswordLabel,
                        border: const OutlineInputBorder()),
                    validator: (v) => (v == null || v.length < 6)
                        ? l.authErrorWeakPassword
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: l.authConfirmPasswordLabel,
                        border: const OutlineInputBorder()),
                    validator: (v) => (v != _passCtrl.text)
                        ? l.authErrorPasswordMismatch
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _termsAccepted,
                    onChanged: (v) =>
                        setState(() => _termsAccepted = v ?? false),
                    title: Text(l.authAcceptTerms,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: AlignmentDirectional.centerStart),
                      onPressed: _openLegal,
                      child: Text(l.authViewTerms),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _busy ? null : _register,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(l.authSignUpButton),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed:
                        _busy ? null : () => context.go(AppRoutes.login),
                    child: Text(l.authHaveAccountQuestion),
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
