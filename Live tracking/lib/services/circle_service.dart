import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// CircleService handles circle management
/// Feature A: Circle System
class CircleService {
  static final CircleService _instance = CircleService._internal();
  
  factory CircleService() {
    return _instance;
  }
  
  CircleService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new circle with a unique 6-digit invite code
  Future<Circle?> createCircle({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Generate invite code using Supabase function
      final inviteCode = await _generateInviteCode();

      final response = await _supabase.from('circles').insert({
        'name': name,
        'invite_code': inviteCode,
        'admin_id': userId,
        'description': description,
        'color': color,
      }).select();

      if (response.isNotEmpty) {
        return Circle.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      print('Error creating circle: $e');
      return null;
    }
  }

  /// Generate a unique 6-digit invite code
  Future<String> _generateInviteCode() async {
    try {
      // Call Supabase RPC function to generate code
      final result = await _supabase
          .rpc('generate_invite_code')
          .catchError((e) => null);
      
      if (result != null) {
        return result.toString();
      }
      
      // Fallback: Generate locally
      return _generateLocalInviteCode();
    } catch (e) {
      print('Error generating invite code via RPC: $e');
      return _generateLocalInviteCode();
    }
  }

  /// Generate invite code locally (fallback)
  String _generateLocalInviteCode() {
    final random = List<int>.generate(6, (i) => int.parse('0123456789'[
        (DateTime.now().millisecondsSinceEpoch + i).remainder(10)
    ])).join('');
    return random.padLeft(6, '0');
  }

  /// Join a circle using an invite code
  Future<bool> joinCircle(String inviteCode) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Find circle by invite code
      final circleResponse = await _supabase
          .from('circles')
          .select('id')
          .eq('invite_code', inviteCode)
          .single();

      final circleId = circleResponse['id'];

      // Check if already a member
      final existingMembership = await _supabase
          .from('circle_members')
          .select('id')
          .eq('circle_id', circleId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMembership != null) {
        print('Already a member of this circle');
        return false;
      }

      // Add user to circle
      await _supabase.from('circle_members').insert({
        'circle_id': circleId,
        'user_id': userId,
        'role': 'member',
      });

      print('Successfully joined circle');
      return true;
    } catch (e) {
      print('Error joining circle: $e');
      return false;
    }
  }

  /// Get all circles for the current user
  Future<List<Circle>> getUserCircles() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('circles')
          .select()
          .inFilter('id',
            await _getUserCircleIds(userId));

      return (response as List)
          .map((c) => Circle.fromJson(c))
          .toList();
    } catch (e) {
      print('Error fetching user circles: $e');
      return [];
    }
  }

  /// Get members of a circle
  Future<List<UserProfile>> getCircleMembers(String circleId) async {
    try {
      final response = await _supabase
          .from('circle_members')
          .select('profiles:user_id(id, email, display_name, avatar_url, last_lat, last_lng, is_online, battery_level, last_seen, created_at)')
          .eq('circle_id', circleId);

      List<UserProfile> members = [];
      for (var item in response) {
        final profileData = item['profiles'];
        if (profileData != null) {
          members.add(UserProfile.fromJson(profileData));
        }
      }
      return members;
    } catch (e) {
      print('Error fetching circle members: $e');
      return [];
    }
  }

  /// Get circle by ID
  Future<Circle?> getCircle(String circleId) async {
    try {
      final response = await _supabase
          .from('circles')
          .select()
          .eq('id', circleId)
          .single();

      return Circle.fromJson(response);
    } catch (e) {
      print('Error fetching circle: $e');
      return null;
    }
  }

  /// Update circle details (admin only)
  Future<bool> updateCircle({
    required String circleId,
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verify user is admin
      final circle = await getCircle(circleId);
      if (circle?.adminId != userId) {
        print('Only admin can update circle');
        return false;
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (color != null) updateData['color'] = color;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('circles').update(updateData).eq('id', circleId);
      return true;
    } catch (e) {
      print('Error updating circle: $e');
      return false;
    }
  }

  /// Remove a member from a circle (admin only)
  Future<bool> removeMember({
    required String circleId,
    required String userId,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      // Verify current user is admin
      final circle = await getCircle(circleId);
      if (circle?.adminId != currentUserId) {
        print('Only admin can remove members');
        return false;
      }

      await _supabase
          .from('circle_members')
          .delete()
          .eq('circle_id', circleId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  /// Leave a circle
  Future<bool> leaveCircle(String circleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Check if user is admin
      final circle = await getCircle(circleId);
      if (circle?.adminId == userId) {
        print('Admin cannot leave circle. Please transfer ownership first.');
        return false;
      }

      await _supabase
          .from('circle_members')
          .delete()
          .eq('circle_id', circleId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error leaving circle: $e');
      return false;
    }
  }

  /// Delete a circle (admin only)
  Future<bool> deleteCircle(String circleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verify user is admin
      final circle = await getCircle(circleId);
      if (circle?.adminId != userId) {
        print('Only admin can delete circle');
        return false;
      }

      await _supabase.from('circles').delete().eq('id', circleId);
      return true;
    } catch (e) {
      print('Error deleting circle: $e');
      return false;
    }
  }

  /// Stream circle member locations in real-time
  /// Feature B: Live Map Synchronization
  Stream<List<UserProfile>> streamCircleMembers(String circleId) async* {
    try {
      final memberIds = await _getCircleMemberIds(circleId);
      if (memberIds.isEmpty) {
        yield [];
      } else {
        yield* _supabase
            .from('profiles')
            .stream(primaryKey: ['id'])
            .inFilter('id', memberIds)
            .map((data) => (data as List)
                .map((p) => UserProfile.fromJson(p))
                .toList());
      }
    } catch (e) {
      print('Error streaming circle members: $e');
      yield [];
    }
  }

  /// Helper: Get all circle IDs for a user
  Future<List<String>> _getUserCircleIds(String userId) async {
    try {
      final response = await _supabase
          .from('circle_members')
          .select('circle_id')
          .eq('user_id', userId);

      return (response as List)
          .map((m) => m['circle_id'] as String)
          .toList();
    } catch (e) {
      print('Error fetching user circle IDs: $e');
      return [];
    }
  }

  /// Helper: Get member IDs for a circle
  Future<List<String>> _getCircleMemberIds(String circleId) async {
    try {
      final response = await _supabase
          .from('circle_members')
          .select('user_id')
          .eq('circle_id', circleId);

      return (response as List)
          .map((m) => m['user_id'] as String)
          .toList();
    } catch (e) {
      print('Error fetching circle member IDs: $e');
      return [];
    }
  }

  /// Get invite code for a circle (admin only)
  Future<String?> getCircleInviteCode(String circleId) async {
    try {
      final circle = await getCircle(circleId);
      return circle?.inviteCode;
    } catch (e) {
      print('Error getting invite code: $e');
      return null;
    }
  }
}
