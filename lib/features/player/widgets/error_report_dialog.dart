import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../services/error_report_service.dart';

/// Oynatıcı hatası için hızlı geri bildirim (Android ErrorReportDialog).
Future<void> showErrorReportDialog(
  BuildContext context, {
  required String? channelName,
  required String errorMessage,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ErrorReportDialog(channelName: channelName, errorMessage: errorMessage),
  );
}

class _ErrorReportDialog extends StatefulWidget {
  final String? channelName;
  final String errorMessage;
  const _ErrorReportDialog({required this.channelName, required this.errorMessage});

  @override
  State<_ErrorReportDialog> createState() => _ErrorReportDialogState();
}

class _ErrorReportDialogState extends State<_ErrorReportDialog> {
  final _note = TextEditingController();
  ErrorReportInfo? _info;
  bool _sending = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    // Önizleme notla birlikte canlı güncellenir (gönderilen metnin aynısı).
    _note.addListener(_onNoteChanged);
    ErrorReportInfo.load().then((i) {
      if (mounted) setState(() => _info = i);
    });
  }

  void _onNoteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _note.removeListener(_onNoteChanged);
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final info = _info ?? await ErrorReportInfo.load();
    await sendAutoErrorReport(
      channelName: widget.channelName,
      errorMessage: widget.errorMessage,
      info: info,
      note: _note.text,
    );
    // Android ile aynı: gönderim hatası kullanıcıya ayrıca gösterilmez.
    if (mounted) {
      setState(() {
        _sending = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final small = TextStyle(fontSize: 11, color: Theme.of(context).hintColor);
    if (_sent) {
      return AlertDialog(
        title: Text(l.errorReportThanks),
        content: Text(l.errorReportReceived),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.close)),
        ],
      );
    }
    final info = _info;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.bug_report, color: Color(0xFFFF5252), size: 22),
          const SizedBox(width: 8),
          Expanded(child: Text(l.errorReportTitle)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gönderilecek metnin TAMAMI (kimlik bilgileri temizlenmiş).
            Text(l.errorReportPreviewLabel, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  buildErrorReportMessage(
                    channelName: widget.channelName,
                    errorMessage: widget.errorMessage,
                    device: info?.device ?? '',
                    osVersion: info?.osVersion ?? '',
                    appVersion: info?.appVersion ?? '',
                    note: _note.text,
                  ),
                  style: small,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(l.errorReportNoteLabel, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _note,
              maxLength: 300,
              maxLines: 3,
              decoration: InputDecoration(hintText: l.errorReportNotePlaceholder),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.errorReportSend),
        ),
      ],
    );
  }
}
