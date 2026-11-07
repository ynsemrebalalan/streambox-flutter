import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/redact.dart';
import '../../player/services/error_report_service.dart';
import '../logic/feedback_logic.dart';

/// Android `FeedbackRepository.send` paritesi: gorseller Firebase Storage
/// `feedback/{ts}/image_{i}.jpg` (5 MB ustu atlanir), belge Firestore
/// `feedback` koleksiyonuna (Android semasi + platform:'ios').
abstract final class FeedbackService {
  /// Basarisizlikta hata firlatir (UI mesaj gosterir).
  static Future<void> send({
    required String name,
    required String email,
    required String message,
    required String type,
    List<String> imagePaths = const [],
  }) async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    for (var i = 0; i < imagePaths.length && i < feedbackMaxImages; i++) {
      try {
        final file = File(imagePaths[i]);
        if (!isFeedbackImageAllowed(await file.length())) continue;
        final ref = FirebaseStorage.instance.ref('feedback/$ts/image_$i.jpg');
        await ref
            .putFile(file, SettableMetadata(contentType: 'image/jpeg'))
            .timeout(const Duration(seconds: 60));
        urls.add(await ref.getDownloadURL());
      } catch (e) {
        // Android ile ayni: gorsel yuklenemezse metin yine gonderilir.
        debugPrint('[Feedback] image $i upload failed: $e');
      }
    }

    final info = await ErrorReportInfo.load();
    final doc = buildFeedbackDoc(
      name: name,
      email: email,
      message: message,
      type: type,
      imageUrls: urls,
      // Otomatik eklenen teknik bilgi de temizlenir (kullanıcı metni aynen).
      device: redactSensitive(info.device),
      osVersion: redactSensitive(info.osVersion),
      appVersion: redactSensitive(info.appVersion),
      nowMs: ts,
    );
    await FirebaseFirestore.instance
        .collection('feedback')
        .add(doc)
        .timeout(const Duration(seconds: 20));
  }
}
