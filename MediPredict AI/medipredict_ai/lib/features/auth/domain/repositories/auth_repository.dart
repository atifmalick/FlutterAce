import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  Future<UserProfile?> getCurrentProfile();
  Future<void> updateProfile(UserProfile profile);
  bool get isAuthenticated;
  String? get currentUserId;
}
