import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (_repository.isAuthenticated) {
      final profile = await _repository.getCurrentProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signIn(email: email, password: password);
      final profile = await _repository.getCurrentProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      final profile = await _repository.getCurrentProfile();
      state = AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    final profile = await _repository.getCurrentProfile();
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
