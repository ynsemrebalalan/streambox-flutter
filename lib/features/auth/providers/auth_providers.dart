import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/auth_state.dart';

/// AuthRepository singleton'ı.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Reactive auth state — tüm UI bunu izler.
/// İlk emit `AuthLoading`, sonrası user'a göre.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authRepositoryProvider).authStateStream();
});

/// Convenience: aktif User (anon veya kalıcı). Null = unauthenticated.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.userOrNull;
});

/// Convenience: kalıcı (login yapmış) user var mı? Anon FALSE döner.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.isAuthenticated ?? false;
});
