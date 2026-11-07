import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../logic/feedback_logic.dart';
import '../services/feedback_service.dart';

Future<void> showFeedbackDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => const FeedbackDialog(),
    );

enum _FeedbackType { suggestion, bug, general }

/// Android SettingsComponents.FeedbackDialog paritesi: tur, ad (opsiyonel),
/// e-posta (zorunlu), mesaj (≤500), hata bildiriminde ≤3 gorsel (≤5 MB).
class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  _FeedbackType _type = _FeedbackType.suggestion;
  final List<XFile> _images = [];
  bool _sending = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final c in [_email, _message]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  String _typeLabel(AppLocalizations l, _FeedbackType t) => switch (t) {
        _FeedbackType.suggestion => l.feedbackTypeSuggestion,
        _FeedbackType.bug => l.feedbackTypeBug,
        _FeedbackType.general => l.feedbackTypeGeneral,
      };

  Future<void> _pickImages() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final picked = await ImagePicker().pickMultiImage(
        imageQuality: 85,
        limit: feedbackMaxImages - _images.length,
      );
      var skipped = false;
      final accepted = <XFile>[];
      for (final x in picked) {
        if (isFeedbackImageAllowed(await x.length())) {
          accepted.add(x);
        } else {
          skipped = true;
        }
      }
      if (!mounted) return;
      setState(() {
        _images.addAll(accepted.take(feedbackMaxImages - _images.length));
      });
      if (skipped) {
        messenger?.showSnackBar(SnackBar(content: Text(l.feedbackImageTooLarge)));
      }
    } catch (e) {
      debugPrint('[Feedback] image pick failed: $e');
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FeedbackService.send(
        name: _name.text,
        email: _email.text,
        message: _message.text,
        // Android ile ayni: tur yerellestirilmis etiketle yazilir.
        type: _typeLabel(l, _type),
        imagePaths: _type == _FeedbackType.bug
            ? _images.map((x) => x.path).toList()
            : const [],
      );
      if (mounted) setState(() => _success = true);
    } catch (e) {
      debugPrint('[Feedback] send failed: $e');
      if (mounted) setState(() => _error = l.feedbackError('$e'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.feedback_outlined, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(l.feedbackDialogTitle)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: _success ? _buildSuccess(l, cs, tt) : _buildForm(l, cs, tt),
        ),
      ),
      actions: _success
          ? [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.close),
              ),
            ]
          : [
              TextButton(
                onPressed: _sending ? null : () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
              FilledButton.icon(
                onPressed: canSendFeedback(
                        email: _email.text,
                        message: _message.text,
                        sending: _sending)
                    ? _send
                    : null,
                icon: _sending
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, size: 18),
                label: Text(_sending ? l.commonSending : l.commonSend),
              ),
            ],
    );
  }

  Widget _buildSuccess(AppLocalizations l, ColorScheme cs, TextTheme tt) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 40, color: cs.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(l.feedbackThanks,
                style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text(l.feedbackReceived,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer)),
          ],
        ),
      );

  Widget _buildForm(AppLocalizations l, ColorScheme cs, TextTheme tt) {
    final email = _email.text;
    final emailInvalid = email.trim().isNotEmpty && !isValidFeedbackEmail(email);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.feedbackChooseType,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        SegmentedButton<_FeedbackType>(
          showSelectedIcon: false,
          segments: [
            for (final t in _FeedbackType.values)
              ButtonSegment(value: t, label: Text(_typeLabel(l, t))),
          ],
          selected: {_type},
          onSelectionChanged: _sending
              ? null
              : (s) => setState(() {
                    _type = s.first;
                    if (_type != _FeedbackType.bug) _images.clear();
                  }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          enabled: !_sending,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l.feedbackNameLabel,
            hintText: l.feedbackNamePlaceholder,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          enabled: !_sending,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l.feedbackEmailLabel,
            hintText: l.feedbackEmailPlaceholder,
            border: const OutlineInputBorder(),
            errorText: emailInvalid ? l.feedbackEmailInvalid : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _message,
          enabled: !_sending,
          minLines: 4,
          maxLines: 8,
          maxLength: feedbackMaxMessageLength,
          decoration: InputDecoration(
            labelText: l.feedbackMessageLabel,
            hintText: l.feedbackMessagePlaceholder,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        if (_type == _FeedbackType.bug) ...[
          Row(
            children: [
              Expanded(
                child: Text(l.feedbackScreenshotLabel,
                    style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
              ),
              if (_images.length < feedbackMaxImages)
                OutlinedButton.icon(
                  onPressed: _sending ? null : _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: Text(l.feedbackAddImage),
                ),
            ],
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final x in _images) _thumb(x, cs),
              ],
            ),
          ],
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: tt.bodySmall?.copyWith(color: cs.error)),
        ],
      ],
    );
  }

  Widget _thumb(XFile x, ColorScheme cs) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(x.path),
                width: 72, height: 72, fit: BoxFit.cover),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: cs.inverseSurface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : () => setState(() => _images.remove(x)),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(Icons.close, size: 14, color: cs.onInverseSurface),
                ),
              ),
            ),
          ),
        ],
      );
}
