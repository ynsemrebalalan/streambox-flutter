import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/database/app_database.dart';
import '../../../data/services/firebase_sync_service.dart';
import 'auth_state.dart';

/// Pure data-layer auth wrapper. UI bu sınıfı doğrudan KULLANMAZ — Riverpod
/// provider'ları üzerinden tüketir. Tüm metodlar throw eder; provider'lar
/// `AuthError` state'ine map eder.
///
/// Anon→linked migration mantığı [linkAnonToCredential]'da. Happy path'te UID
/// korunur; sad path ('credential-already-in-use') Firestore data copy
/// `FirebaseSyncService.migrateAnonDataToUser` ile yapılır (Phase E).
class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _authOverride = auth,
        _googleOverride = googleSignIn;

  // Lazy — constructor çağrıldığında FirebaseAuth.instance erişilmesin.
  // Update senaryosunda Firebase init'ten ÖNCE provider instantiate olunca
  // `[core/no-app] No Firebase App` patlıyordu. Lazy late + firebaseReady
  // provider birlikte race'i çözer.
  final FirebaseAuth? _authOverride;
  final GoogleSignIn? _googleOverride;
  late final FirebaseAuth _auth = _authOverride ?? FirebaseAuth.instance;
  late final GoogleSignIn _google = _googleOverride ?? GoogleSignIn();

  // ── Stream ─────────────────────────────────────────────────────────────────

  /// Firebase Auth state değişimlerini sealed [AuthState]'e map'ler.
  /// İlk emit `AuthLoading`, sonrası user'a göre.
  Stream<AuthState> authStateStream() async* {
    yield const AuthLoading();
    yield* _auth.authStateChanges().map(_userToState);
  }

  AuthState _userToState(User? u) {
    if (u == null) return const AuthUnauthenticated();
    if (u.isAnonymous) return AuthAnonymous(u);
    return AuthAuthenticated(u);
  }

  User? get currentUser => _auth.currentUser;

  // ── Email / Password ───────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = EmailAuthProvider.credential(email: email, password: password);
    return _signInOrLink(cred);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = EmailAuthProvider.credential(email: email, password: password);
    final result = await _signInOrLink(cred, isNewAccount: true);
    // Email doğrulama linki gönder — fail olsa devam (kullanıcı sonra Settings'ten
    // tekrar gönderebilir).
    try {
      await result.user?.sendEmailVerification();
    } catch (e) {
      debugPrint('[Auth] sendEmailVerification failed: $e');
    }
    return result;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ── Google ─────────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'cancelled',
        message: 'Google Sign-In iptal edildi.',
      );
    }
    final auth = await account.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    return _signInOrLink(cred);
  }

  // ── Apple ──────────────────────────────────────────────────────────────────

  /// iOS 13+ Sign in with Apple. Android'de paket `signInWithApple` web flow
  /// açar — desteklemiyoruz; yalnızca iOS'ta çağırın.
  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw FirebaseAuthException(
        code: 'unsupported-platform',
        message: 'Apple ile giriş yalnızca iOS/macOS\'ta desteklenir.',
      );
    }

    final rawNonce = _randomNonce();
    final nonceHash = sha256.convert(utf8.encode(rawNonce)).toString();

    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonceHash,
    );

    final cred = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      rawNonce: rawNonce,
      accessToken: apple.authorizationCode,
    );

    final result = await _signInOrLink(cred);

    // Apple ad-soyad SADECE ilk girişte gelir; persistent yoksa kaydet.
    if (apple.givenName != null || apple.familyName != null) {
      final name = [apple.givenName, apple.familyName]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');
      if (name.isNotEmpty && result.user?.displayName == null) {
        try {
          await result.user?.updateDisplayName(name);
        } catch (_) {}
      }
    }

    return result;
  }

  // ── Sign Out / Delete ──────────────────────────────────────────────────────

  Future<void> signOut() async {
    // Tüm sosyal sağlayıcılardan çık (idempotent).
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Apple Guideline 5.1.1(v) zorunlu: hesap silme.
  /// Backend cleanup (Firestore users/{uid}) Cloud Function "Delete User Data"
  /// extension ile asenkron yapılır. RevenueCat subscription'ı user iptal etmeli.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 'requires-recent-login' fırlatabilir → caller tekrar login isteyip retry eder.
    await user.delete();
  }

  // ── Anon → Linked Migration ────────────────────────────────────────────────

  /// Mevcut user anonim ise [credential]'i ona bağla (UID korunur).
  /// Aksi durumda direkt [signInWithCredential] (UID değişebilir).
  ///
  /// Sad path: `credential-already-in-use` → mevcut user'a switch yapılır.
  /// Çağıran tarafta migration helper çağrılmalı (Phase E).
  Future<UserCredential> _signInOrLink(
    AuthCredential credential, {
    bool isNewAccount = false,
  }) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      return linkAnonToCredential(credential);
    }
    if (isNewAccount) {
      // Email register: yeni hesap oluştur — link denemeyiz çünkü anon yoksa
      // createUserWithEmailAndPassword tek doğru API.
      final emailCred = credential as EmailAuthCredential;
      return _auth.createUserWithEmailAndPassword(
        email: emailCred.email,
        password: emailCred.password!,
      );
    }
    return _auth.signInWithCredential(credential);
  }

  /// Anonim user'ı kalıcı credential'e bağla.
  ///
  /// **Happy path:** `linkWithCredential` başarılı → UID korunur, Firestore
  /// data taşımaya gerek yok. UI sadece authStateChanges yeni user'ı emit eder.
  ///
  /// **Sad path:** `credential-already-in-use` → bu credential başka cihazda
  /// zaten kalıcı user. signInWithCredential ile o user'a switch et; çağıran
  /// taraf eski anon UID'yi alıp [FirebaseSyncService.migrateAnonDataToUser]
  /// ile Firestore'da data merge etmeli.
  Future<UserCredential> linkAnonToCredential(AuthCredential credential) async {
    final anon = _auth.currentUser;
    if (anon == null || !anon.isAnonymous) {
      return _auth.signInWithCredential(credential);
    }
    final anonUid = anon.uid;

    try {
      // Happy path: UID korunur, Firestore data zaten dogru path'te.
      final result = await anon.linkWithCredential(credential);
      // Local DB'de anon UID ile (veya NULL ile) yazilmis satirlari yeni
      // UID'e tasi. Happy path'te anonUid == newUid oldugu icin no-op
      // gibi gozukur ama NULL satirlar (v7 migration sonrasi seed) bu
      // sayede anon UID alir → ilk login'de propagate olur.
      final newUid = result.user?.uid ?? anonUid;
      await _migrateLocalAnonToLinked(anonUid: anonUid, newUid: newUid);
      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'credential-already-in-use' &&
          e.code != 'email-already-in-use') {
        rethrow;
      }
      // Sad path: bu credential baska cihazda zaten kalici user.
      // Once o user'a switch et (UID DEGISIR), sonra anon-time data'yi merge et.
      final result = await _auth.signInWithCredential(credential);
      final newUid = result.user?.uid;
      if (newUid != null && newUid != anonUid) {
        await FirebaseSyncService.migrateAnonDataToUser(
          fromAnonUid: anonUid,
          toUserUid: newUid,
        );
        // Local DB'deki anon-time satirlari da yeni UID'e tasi (merge stratejisi:
        // mevcut satir varsa olduğu gibi kalır, conflict resolution sync'te LWW
        // ile updatedAt'a göre çözülür).
        await _migrateLocalAnonToLinked(anonUid: anonUid, newUid: newUid);
      }
      return result;
    }
  }

  /// Anon iken yazilmis local DB satirlarini yeni (kalici) UID'e tasir.
  ///
  /// Strateji: ownerUid IS NULL veya ownerUid == anonUid olan tum cloud-sync
  /// edilen tablolarin satirlari `ownerUid = newUid` olarak guncellenir.
  /// Tek transaction; tablo yoksa try/catch ile yutulur.
  ///
  /// Sad path'te (yeni UID'in ESKI verisi varsa): merge yapilir — eski + yeni
  /// satirlar yan yana kalir; conflict resolution updatedAt LWW ile cozer.
  Future<void> _migrateLocalAnonToLinked({
    required String anonUid,
    required String newUid,
  }) async {
    if (anonUid == newUid) {
      // Happy path same-uid: NULL ownerUid'leri yeni UID'e set et (seed).
    }
    try {
      final db = await AppDatabase.instance;
      await db.transaction((txn) async {
        const tables = [
          'playlists',
          'channels',
          'watchlist',
          'profiles',
        ];
        for (final t in tables) {
          try {
            await txn.update(
              t,
              {'ownerUid': newUid},
              where: 'ownerUid = ? OR ownerUid IS NULL',
              whereArgs: [anonUid],
            );
          } catch (e) {
            // Tablo yoksa atla.
            debugPrint('[Auth] migrate local "$t" skip: $e');
          }
        }
        // Tombstone'lari da migrate et — anon iken silinen ama henuz push
        // edilmemis kayitlar yeni UID altinda push edilebilsin.
        try {
          await txn.update(
            'sync_tombstones',
            {'ownerUid': newUid},
            where: 'ownerUid = ? OR ownerUid IS NULL',
            whereArgs: [anonUid],
          );
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[Auth] _migrateLocalAnonToLinked failed: $e');
      // Migration fail olsa login akisini kesme — kullanici hala giris yapabilir,
      // local data'sina erisebilir; sadece UID propagate olmaz.
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Apple nonce için kriptografik rastgele string.
  String _randomNonce({int length = 32}) {
    const charset =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._';
    final r = Random.secure();
    return List.generate(length, (_) => charset[r.nextInt(charset.length)])
        .join();
  }
}
