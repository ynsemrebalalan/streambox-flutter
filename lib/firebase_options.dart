// Firebase yapılandırması — GoogleService-Info.plist değerlerinden manuel
// oluşturuldu (2026-05-19). Normalde `flutterfire configure` üretir.
//
// SEBEP: GoogleService-Info.plist Xcode projesine (project.pbxproj) hiç
// eklenmemişti → .app bundle'ına kopyalanmıyordu → iOS'ta
// Firebase.initializeApp() config bulamayıp "[core/no-app] No Firebase App"
// patlıyordu. Bu, App Store 2.1(a) "Apple ile giriş başarısız" reddinin
// gerçek sebebiydi. Config'i Dart'a gömerek init plist'ten bağımsız olur.
//
// NOT: apiKey GİZLİ DEĞİL — Firebase istemci anahtarları zaten uygulamanın
// içinde gömülü gelir (plist/json). Güvenlik Firestore Rules + App Check
// ile sağlanır; bu dosyanın commit'lenmesi standarttır.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase platform seçenekleri. `Firebase.initializeApp(options: ...)` ile
/// kullanılır.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions web için yapılandırılmadı.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        // Flutter uygulaması iOS-only yayınlanıyor (Android = ayrı Kotlin
        // codebase). Çağrı yine de _initFirebaseAndAnalytics try/catch'inde.
        throw UnsupportedError(
          'DefaultFirebaseOptions $defaultTargetPlatform için yapılandırılmadı.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvBURpH2nfHvEGw12zNCQowlAi1eUCXNs',
    appId: '1:583696434507:ios:552671f997870871cc14ce',
    messagingSenderId: '583696434507',
    projectId: 'streambox-b0aaf',
    storageBucket: 'streambox-b0aaf.firebasestorage.app',
    databaseURL: 'https://streambox-b0aaf-default-rtdb.firebaseio.com',
    iosBundleId: 'com.ynsemrebalalan.iptvai',
    iosClientId:
        '583696434507-dp78u7jc99i07f28qb4othk7quk73tfq.apps.googleusercontent.com',
  );
}
