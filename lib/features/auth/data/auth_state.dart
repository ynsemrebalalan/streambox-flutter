import 'package:firebase_auth/firebase_auth.dart';

/// Reactive auth durumları — Riverpod `StreamProvider` üzerinden expose edilir.
/// UI bu sealed class'ın hangi alt-sınıfında olduğuna göre dallanır.
sealed class AuthState {
  const AuthState();
}

/// Kayıtlı durum henüz belli değil (cold-start, ilk frame).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Anonim Firebase user. UID var, email yok. Login değil ama Firestore yazabilir.
class AuthAnonymous extends AuthState {
  final User user;
  const AuthAnonymous(this.user);

  String get uid => user.uid;
}

/// Email/Google/Apple ile giriş yapmış user.
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  String get uid => user.uid;
  String? get email => user.email;
  String? get displayName => user.displayName;
  bool get emailVerified => user.emailVerified;

  /// Hangi sağlayıcıyla giriş yaptı? (`password`, `google.com`, `apple.com`)
  List<String> get providerIds =>
      user.providerData.map((p) => p.providerId).toList();

  /// Apple ile giris yapildi mi? Apple Sign-In "Hide My Email" tespiti
  /// icin gereklidir. 2026-05-25.
  bool get isAppleProvider => providerIds.contains('apple.com');

  /// Email Apple Private Relay mi? (`xxxxxxxxxx@privaterelay.appleid.com`)
  /// Kullanici "Hide My Email" sectiyse Firebase'e bu format yazilir,
  /// UI gercek email yerine "gizli e-posta" gostermeli.
  bool get isAppleRelayEmail {
    final e = email;
    if (e == null) return false;
    return e.toLowerCase().endsWith('@privaterelay.appleid.com');
  }
}

/// Hiç user yok — Firebase Auth ne anonim ne kalıcı bir kullanıcı tanıyor.
/// Normalde anon sign-in fail ettiğinde bu state'e düşülür (offline + ilk açılış).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth çağrısı sırasında oluşan hata. UI mesaj gösterir.
class AuthError extends AuthState {
  final String code;
  final String message;
  const AuthError({required this.code, required this.message});
}

extension AuthStateUserAccess on AuthState {
  /// Convenience: hangi state'de olursa olsun User varsa döndür.
  User? get userOrNull {
    return switch (this) {
      AuthAnonymous(:final user) => user,
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
  }

  bool get isAnonymous => this is AuthAnonymous;
  bool get isAuthenticated => this is AuthAuthenticated;
}
