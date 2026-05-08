import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/supabase_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = SupabaseClientHelper.client;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await SupabaseClientHelper.profiles()
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await SupabaseClientHelper.profiles()
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;
}
