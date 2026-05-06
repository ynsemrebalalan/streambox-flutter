import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/secure_storage.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../parental_lock_service.dart';

/// 4 haneli PIN giriş diyaloğu.
///
/// Modes:
///   - [PinDialogMode.verify] — Kayıtlı PIN'i doğrula. true/false döner.
///   - [PinDialogMode.create] — Yeni PIN oluştur (2 kez giriş, eşleşmeli).
///   - [PinDialogMode.change] — Eski PIN ver, yeni PIN oluştur.
///
/// Brute-force koruması: 5 yanlış giriş → 30 saniyelik cooldown.
/// Cooldown sırasında kalan süre geri sayım olarak gösterilir.
enum PinDialogMode { verify, create, change }

/// Maksimum ardışık yanlış giriş sayısı.
const _kMaxAttempts = 5;

/// Cooldown süresi (saniye).
const _kCooldownSeconds = 30;

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

  // ── Cooldown ───────────────────────────────────────────────────────────────
  int _cooldownRemaining = 0; // sıfır ise cooldown yok
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Diyalog açılır açılmaz mevcut cooldown kontrol et.
    _checkCooldownOnOpen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cooldownRemaining == 0) _focus1.requestFocus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _ctrl1.dispose();
    _ctrl2.dispose();
    _focus1.dispose();
    _focus2.dispose();
    super.dispose();
  }

  // ── Cooldown yönetimi ──────────────────────────────────────────────────────

  Future<void> _checkCooldownOnOpen() async {
    final until = await SecureStorage.getCooldownUntil();
    if (until == null) return;
    final remaining = until.difference(DateTime.now()).inSeconds;
    if (remaining > 0) {
      _startCooldownTimer(remaining);
    } else {
      // Süresi geçmiş cooldown'ı temizle.
      await SecureStorage.clearCooldown();
    }
  }

  void _startCooldownTimer(int seconds) {
    setState(() {
      _cooldownRemaining = seconds;
      _error = null;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldownRemaining--;
      });
      if (_cooldownRemaining <= 0) {
        t.cancel();
        setState(() {
          _cooldownRemaining = 0;
        });
        // Cooldown bitti; odağı geri ver.
        _focus1.requestFocus();
      }
    });
  }

  /// verify/change modlarında yanlış giriş sonrası çağrılır.
  Future<void> _handleFailedAttempt() async {
    await SecureStorage.incrementFailedAttempts();
    final attempts = await SecureStorage.getFailedPinAttempts();

    if (attempts >= _kMaxAttempts) {
      // Cooldown başlat.
      final until = DateTime.now().add(
        const Duration(seconds: _kCooldownSeconds),
      );
      await SecureStorage.setCooldownUntil(until);
      await SecureStorage.resetFailedAttempts();
      _startCooldownTimer(_kCooldownSeconds);
      setState(() {
        _error = null; // cooldown mesajı widget'ta gösterilecek
        _ctrl1.clear();
        _busy = false;
      });
    } else {
      final remaining = _kMaxAttempts - attempts;
      setState(() {
        _error =
            'Yanlış PIN. $remaining deneme hakkınız kaldı.';
        _ctrl1.clear();
        _busy = false;
      });
      _focus1.requestFocus();
    }
  }

  Future<void> _handleSuccessfulVerify() async {
    await SecureStorage.resetFailedAttempts();
    await SecureStorage.clearCooldown();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _onSubmit() async {
    // Cooldown aktifse engelle.
    if (_cooldownRemaining > 0) return;
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
            await _handleFailedAttempt();
            return;
          }
          await _handleSuccessfulVerify();
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
              await _handleFailedAttempt();
              return;
            }
            await _handleSuccessfulVerify();
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

  // ── Build ──────────────────────────────────────────────────────────────────

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

    final isCooldown = _cooldownRemaining > 0;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cooldown banner
          if (isCooldown) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_clock, color: cs.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Çok fazla yanlış giriş. '
                      '$_cooldownRemaining saniye bekleyin.',
                      style: TextStyle(
                        color: cs.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // PIN field(lar)
          AbsorbPointer(
            absorbing: isCooldown,
            child: Opacity(
              opacity: isCooldown ? 0.4 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PinField(
                    controller: _ctrl1,
                    focusNode: _focus1,
                    onChanged: (v) {
                      if (v.length == 4 &&
                          widget.mode == PinDialogMode.verify &&
                          !isCooldown) {
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
                ],
              ),
            ),
          ),

          if (_error != null && !isCooldown) ...[
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
          onPressed: (isCooldown || _busy) ? null : _onSubmit,
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
