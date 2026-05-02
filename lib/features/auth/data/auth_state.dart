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
