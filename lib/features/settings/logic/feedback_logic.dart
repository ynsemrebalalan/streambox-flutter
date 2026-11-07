/// Geri bildirim formu — Android FeedbackDialog / FeedbackRepository paritesi.
library;

const feedbackMaxMessageLength = 500;
const feedbackMaxImages = 3;
const feedbackMaxImageBytes = 5 * 1024 * 1024; // 5 MB

final _emailRe = RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');

bool isValidFeedbackEmail(String email) => _emailRe.hasMatch(email.trim());

bool canSendFeedback({
  required String email,
  required String message,
  required bool sending,
}) =>
    !sending && isValidFeedbackEmail(email) && message.trim().isNotEmpty;

bool isFeedbackImageAllowed(int sizeBytes) =>
    sizeBytes > 0 && sizeBytes <= feedbackMaxImageBytes;

/// Firestore `feedback` belgesi. Android alanlari aynen (+ `platform`,
/// `osVersion`; `androidApi` sema uyumu icin 0).
Map<String, Object> buildFeedbackDoc({
  required String name,
  required String email,
  required String message,
  required String type,
  required List<String> imageUrls,
  required String device,
  required String osVersion,
  required String appVersion,
  required int nowMs,
}) =>
    {
      'message': message,
      'type': type,
      'email': email.trim(),
      if (name.trim().isNotEmpty) 'name': name.trim(),
      if (imageUrls.isNotEmpty) 'imageUrls': List<String>.of(imageUrls),
      'device': device,
      'androidApi': 0,
      'appVersion': appVersion,
      'timestamp': nowMs,
      'platform': 'ios',
      'osVersion': osVersion,
    };
