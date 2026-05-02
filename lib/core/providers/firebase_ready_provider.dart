import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase.initializeApp() tamamlandı mı? Polls Firebase.apps.
///
/// Bootstrap (`main._bootstrapInBackground`) Firebase init'i arka planda
/// timeout'lu yapar (iOS 26 siyah ekran fix'i). Auth/Firestore tüketicileri
/// bu provider'ı await ederek init bitene kadar Loading state'te kalır.
///
/// Update senaryosunda disclaimer atlanıp doğrudan home'a navigate olunca
/// `authStateProvider` Firebase init'ten ÖNCE `FirebaseAuth.instance`
/// çağırıp `[core/no-app] No Firebase App` patlatıyordu — bu provider
/// race'i çözer.
final firebaseReadyProvider = FutureProvider<void>((ref) async {
  if (Firebase.apps.isNotEmpty) return;
  // Max 10 sn bekle, 50ms aralıklarla poll.
  for (var i = 0; i < 200; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
    if (Firebase.apps.isNotEmpty) return;
  }
  throw StateError('Firebase init timeout (10s)');
});
