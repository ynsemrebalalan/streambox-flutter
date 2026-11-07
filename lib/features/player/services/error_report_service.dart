import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/utils/redact.dart';

/// Oynatıcı otomatik hata raporu — Android PlayerComponents.ErrorReportDialog
/// ile aynı `feedback` belge şeması (type "Otomatik Hata", isAutoReport true).
/// iOS'a özgü ek alanlar: `platform`, `osVersion` (androidApi şema uyumu için 0).
class ErrorReportInfo {
  final String device;
  final String osVersion;
  final String appVersion;
  const ErrorReportInfo(this.device, this.osVersion, this.appVersion);

  static Future<ErrorReportInfo> load() async {
    var device = 'iOS';
    var os = '';
    var version = '';
    try {
      if (Platform.isIOS) {
        final i = await DeviceInfoPlugin().iosInfo;
        device = 'Apple ${i.utsname.machine}';
        os = i.systemVersion;
      }
    } catch (_) {}
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return ErrorReportInfo(device, os, version);
  }
}

/// Firestore'a gidecek rapor metni — kimlik bilgileri temizlenmiş
/// ([redactSensitive]). Dialog kullanıcıya AYNI metni gösterir.
String buildErrorReportMessage({
  required String? channelName,
  required String errorMessage,
  required String device,
  required String osVersion,
  required String appVersion,
  String note = '',
}) {
  final name = redactSensitive(channelName ?? '');
  final msg = StringBuffer()
    ..writeln('[Otomatik Hata Raporu]')
    ..writeln(name.isEmpty ? '' : 'Kanal: $name')
    ..writeln('Hata: ${redactSensitive(errorMessage)}')
    ..writeln('Cihaz: $device')
    ..writeln('iOS: $osVersion')
    ..writeln('Versiyon: $appVersion');
  if (note.trim().isNotEmpty) {
    msg
      ..writeln()
      ..writeln('Kullanıcı notu: ${redactSensitive(note.trim())}');
  }
  return msg.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

Future<bool> sendAutoErrorReport({
  required String? channelName,
  required String errorMessage,
  required ErrorReportInfo info,
  String note = '',
}) async {
  final message = buildErrorReportMessage(
    channelName: channelName,
    errorMessage: errorMessage,
    device: info.device,
    osVersion: info.osVersion,
    appVersion: info.appVersion,
    note: note,
  );
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) await auth.signInAnonymously();
    await FirebaseFirestore.instance.collection('feedback').add({
      'message': message,
      'type': 'Otomatik Hata',
      'email': 'auto-report@streambox.app',
      'device': info.device,
      'androidApi': 0,
      'platform': 'ios',
      'osVersion': info.osVersion,
      'appVersion': info.appVersion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isAutoReport': true,
    });
    return true;
  } catch (e) {
    debugPrint('[ErrorReport] send failed: $e');
    return false;
  }
}
