import '../../../l10n/generated/app_localizations.dart';
import 'ai_error.dart';

/// [AiErrorCode] → kullanıcı metni (Android `ai_sub_err_*` karşılıkları).
String aiErrorMessage(AppLocalizations l, AiErrorCode code) => switch (code) {
      AiErrorCode.proRequired => l.aiSubErrProRequired,
      AiErrorCode.quota => l.aiSubErrQuota,
      AiErrorCode.busy => l.aiSubErrBusy,
      AiErrorCode.unauthorized => l.aiSubErrUnavailable,
      AiErrorCode.invalidKey => l.aiSubErrInvalidKey,
      AiErrorCode.server => l.aiSubErrUnavailable,
      AiErrorCode.rejected => l.aiSubErrRejected,
      AiErrorCode.network => l.aiSubErrUnreachable,
      AiErrorCode.timeout => l.aiSubErrConnectTimeout,
      AiErrorCode.emptyResponse => l.aiSubErrEmptyResponse,
      AiErrorCode.noSpeech => l.aiSubErrNoSpeech,
      AiErrorCode.extract => l.aiSubErrExtract,
      AiErrorCode.notConfigured => l.aiSubErrUnavailable,
      AiErrorCode.generic => l.aiSubErrGeneric,
    };
