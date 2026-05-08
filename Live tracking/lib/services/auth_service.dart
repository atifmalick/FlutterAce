import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// AuthService handles authentication and user profile management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign up with email and password
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          displayName: displayName,
        );
      }

      return response;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Update online status
        await _updateUserOnlineStatus(response.user!.id, true);
      }

      return response;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Set user offline
        await _updateUserOnlineStatus(userId, false);
      }

      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching current user profile: $e');
      return null;
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('profiles').update({
        'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Create user profile (internal)
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'display_name': displayName,
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  /// Update user's online status
  Future<void> _updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _supabase.from('profiles').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  /// Stream authentication state changes
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }
}
