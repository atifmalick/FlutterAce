import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'location_service.dart';

/// GeofenceService handles geofence management, monitoring, and alerts
/// Phase 4: Geofencing & Alerts
class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  
  factory GeofenceService() {
    return _instance;
  }
  
  GeofenceService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  Map<String, bool> _userGeofenceStatus = {}; // Track if user is inside each geofence
  Set<String> _activeGeofenceMonitors = {}; // Active monitoring geofences

  /// Initialize local notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Create a geofence (Safe Zone) - Admin only
  Future<Geofence?> createGeofence({
    required String circleId,
    required String name,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    String color = '#43A047',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.from('geofences').insert({
        'circle_id': circleId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'created_by': userId,
        'color': color,
      }).select();

      if (response.isNotEmpty) {
        return Geofence.fromJson(response[0]);
      }
      return null;
    } catch (e) {
      print('Error creating geofence: $e');
      return null;
    }
  }

  /// Get all geofences for a circle
  Future<List<Geofence>> getCircleGeofences(String circleId) async {
    try {
      final response = await _supabase
          .from('geofences')
          .select()
          .eq('circle_id', circleId)
          .eq('is_active', true);

      return (response as List)
          .map((g) => Geofence.fromJson(g))
          .toList();
    } catch (e) {
      print('Error fetching geofences: $e');
      return [];
    }
  }

  /// Check if user is within a geofence
  /// Uses Haversine formula for accurate distance calculation
  bool isUserInGeofence({
    required double userLat,
    required double userLng,
    required double geofenceLat,
    required double geofenceLng,
    required int radiusMeters,
  }) {
    final distance = LocationService.haversineDistance(
      lat1: userLat,
      lon1: userLng,
      lat2: geofenceLat,
      lon2: geofenceLng,
    );

    return distance <= radiusMeters;
  }

  /// Monitor a specific geofence for user entry/exit
  Future<void> monitorGeofence({
    required Geofence geofence,
    required double currentUserLat,
    required double currentUserLng,
    required String currentUserId,
    required String currentUserName,
  }) async {
    final geofenceKey = geofence.id;
    
    // Check current status
    final isInside = isUserInGeofence(
      userLat: currentUserLat,
      userLng: currentUserLng,
      geofenceLat: geofence.latitude,
      geofenceLng: geofence.longitude,
      radiusMeters: geofence.radiusMeters,
    );

    // Get previous status
    final wasInside = _userGeofenceStatus[geofenceKey] ?? false;

    // Detect entry
    if (isInside && !wasInside) {
      await _handleGeofenceEntry(
        geofence: geofence,
        userId: currentUserId,
        userName: currentUserName,
        latitude: currentUserLat,
        longitude: currentUserLng,
      );
    }

    // Detect exit
    if (!isInside && wasInside) {
      await _handleGeofenceExit(
        geofence: geofence,
        userId: currentUserId,
        userName: currentUserName,
      );
    }

    // Update status
    _userGeofenceStatus[geofenceKey] = isInside;
  }

  /// Handle geofence entry event
  Future<void> _handleGeofenceEntry({
    required Geofence geofence,
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Log event to database
      await _supabase.from('geofence_events').insert({
        'geofence_id': geofence.id,
        'user_id': userId,
        'event_type': 'entered',
        'latitude': latitude,
        'longitude': longitude,
      });

      // Send local notification
      await _sendNotification(
        title: 'Arrived at ${geofence.name}',
        body: '$userName has arrived at ${geofence.name}',
        notificationId: geofence.id.hashCode,
      );

      print('User entered geofence: ${geofence.name}');
    } catch (e) {
      print('Error handling geofence entry: $e');
    }
  }

  /// Handle geofence exit event
  Future<void> _handleGeofenceExit({
    required Geofence geofence,
    required String userId,
    required String userName,
  }) async {
    try {
      // Log event to database
      await _supabase.from('geofence_events').insert({
        'geofence_id': geofence.id,
        'user_id': userId,
        'event_type': 'exited',
      });

      // Send local notification (optional)
      await _sendNotification(
        title: 'Left ${geofence.name}',
        body: '$userName has left ${geofence.name}',
        notificationId: geofence.id.hashCode + 1,
      );

      print('User exited geofence: ${geofence.name}');
    } catch (e) {
      print('Error handling geofence exit: $e');
    }
  }

  /// Send local notification
  Future<void> _sendNotification({
    required String title,
    required String body,
    required int notificationId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'geofence_alerts',
        'Geofence Alerts',
        channelDescription: 'Notifications for geofence entries and exits',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Start monitoring all geofences for a user in circles
  Future<void> startGeofenceMonitoring({
    required List<String> circleIds,
    required double userLat,
    required double userLng,
    required String userId,
    required String userName,
  }) async {
    try {
      // Get all geofences for user's circles
      List<Geofence> allGeofences = [];
      for (String circleId in circleIds) {
        final geofences = await getCircleGeofences(circleId);
        allGeofences.addAll(geofences);
      }

      // Monitor each geofence
      for (Geofence geofence in allGeofences) {
        await monitorGeofence(
          geofence: geofence,
          currentUserLat: userLat,
          currentUserLng: userLng,
          currentUserId: userId,
          currentUserName: userName,
        );
      }
    } catch (e) {
      print('Error starting geofence monitoring: $e');
    }
  }

  /// Delete a geofence
  Future<bool> deleteGeofence(String geofenceId) async {
    try {
      await _supabase.from('geofences').delete().eq('id', geofenceId);
      _userGeofenceStatus.remove(geofenceId);
      _activeGeofenceMonitors.remove(geofenceId);
      return true;
    } catch (e) {
      print('Error deleting geofence: $e');
      return false;
    }
  }

  /// Get recent geofence events for a circle
  Future<List<GeofenceEvent>> getGeofenceEvents({
    required String circleId,
    int limitDays = 7,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: limitDays));
      
      final response = await _supabase
          .from('geofence_events')
          .select()
          .inFilter('geofence_id', 
            await _getCircleGeofenceIds(circleId))
          .gt('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => GeofenceEvent.fromJson(e))
          .toList();
    } catch (e) {
      print('Error fetching geofence events: $e');
      return [];
    }
  }

  /// Helper: Get all geofence IDs for a circle
  Future<List<String>> _getCircleGeofenceIds(String circleId) async {
    final geofences = await getCircleGeofences(circleId);
    return geofences.map((g) => g.id).toList();
  }

  /// Dispose resources
  void dispose() {
    _userGeofenceStatus.clear();
    _activeGeofenceMonitors.clear();
  }
}
