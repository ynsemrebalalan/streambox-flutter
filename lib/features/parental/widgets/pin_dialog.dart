import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../parental_lock_service.dart';

/// 4 haneli PIN giriş diyaloğu.
///
/// Modes:
///   - [PinDialogMode.verify] — Kayıtlı PIN'i doğrula. true/false döner.
///   - [PinDialogMode.create] — Yeni PIN oluştur (2 kez giriş, eşleşmeli).
///   - [PinDialogMode.change] — Eski PIN ver, yeni PIN oluştur.
enum PinDialogMode { verify, create, change }

class PinDialog extends ConsumerStatefulWidget {
  final PinDialogMode mode;
  final String? title;
  const PinDialog({super.key, required this.mode, this.title});

  static Future<bool> show(
    BuildContext context, {
    required PinDialogMode mode,
    String? title,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(mode: mode, title: title),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends ConsumerState<PinDialog> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  final _focus1 = FocusNode();
  final _focus2 = FocusNode();

  String? _error;
  bool _step2 = false; // create/change mode'da ikinci adım
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus1.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _focus1.dispose();
    _focus2.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_busy) return;
    setState(() {
      _error = null;
      _busy = true;
    });

    final svc = ref.read(parentalLockServiceProvider);

    try {
      switch (widget.mode) {
        case PinDialogMode.verify:
          final ok = await svc.verifyPin(_ctrl1.text);
          if (!mounted) return;
          if (!ok) {
            setState(() {
              _error = AppLocalizations.of(context).parentalPinIncorrect;
              _ctrl1.clear();
              _busy = false;
            });
            _focus1.requestFocus();
            return;
          }
          if (mounted) Navigator.pop(context, true);
          break;

        case PinDialogMode.create:
          if (!_step2) {
            // İlk girişten sonra ikinci adıma geç.
            if (_ctrl1.text.length != 4) {
              setState(() {
                _error = AppLocalizations.of(context).parentalPinFourDigits;
                _busy = false;
              });
              return;
            }
            setState(() {
              _step2 = true;
              _busy = false;
            });
            _focus2.requestFocus();
            return;
          }
          // Step 2: confirm match
          if (_ctrl1.text != _ctrl2.text) {
            setState(() {
              _error = AppLocalizations.of(context).parentalPinMismatch;
              _ctrl2.clear();
              _busy = false;
            });
            _focus2.requestFocus();
            return;
          }
          await svc.setPin(_ctrl1.text);
          await svc.setEnabled(true);
          if (mounted) Navigator.pop(context, true);
          break;

        case PinDialogMode.change:
          if (!_step2) {
            final ok = await svc.verifyPin(_ctrl1.text);
            if (!mounted) return;
            if (!ok) {
              setState(() {
                _error = AppLocalizations.of(context).parentalPinIncorrect;
                _ctrl1.clear();
                _busy = false;
              });
              _focus1.requestFocus();
              return;
            }
            setState(() {
              _step2 = true;
              _busy = false;
              _ctrl1.clear();
            });
            _focus1.requestFocus();
            return;
          }
          // Step 2: new PIN — _ctrl2 used as confirm.
          if (_ctrl1.text.length != 4) {
            setState(() {
              _error = AppLocalizations.of(context).parentalPinFourDigits;
              _busy = false;
            });
            return;
          }
          if (_ctrl1.text != _ctrl2.text) {
            setState(() {
              _error = AppLocalizations.of(context).parentalPinMismatch;
              _ctrl2.clear();
              _busy = false;
            });
            _focus2.requestFocus();
            return;
          }
          await svc.setPin(_ctrl1.text);
          if (mounted) Navigator.pop(context, true);
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final title = widget.title ??
        switch (widget.mode) {
          PinDialogMode.verify => l.parentalEnterPin,
          PinDialogMode.create => _step2
              ? l.parentalConfirmPin
              : l.parentalNewPin,
          PinDialogMode.change => _step2
              ? l.parentalNewPin
              : l.parentalCurrentPin,
        };

    final hint = widget.mode == PinDialogMode.change && _step2
        ? l.parentalConfirmPin
        : null;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinField(
            controller: _ctrl1,
            focusNode: _focus1,
            onChanged: (v) {
              if (v.length == 4 && widget.mode == PinDialogMode.verify) {
                _onSubmit();
              }
            },
          ),
          if (widget.mode == PinDialogMode.create && _step2 ||
              widget.mode == PinDialogMode.change && _step2) ...[
            const SizedBox(height: 12),
            _PinField(
              controller: _ctrl2,
              focusNode: _focus2,
              hint: hint,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _onSubmit,
          child: Text(_step2 || widget.mode == PinDialogMode.verify
              ? l.parentalSubmit
              : l.parentalNext),
        ),
      ],
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final String? hint;
  const _PinField({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, letterSpacing: 12),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        hintText: hint ?? '••••',
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
