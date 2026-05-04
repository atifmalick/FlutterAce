import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math' as math;

/// LocationService handles all location tracking, permissions, and updates.
/// Phase 2: Location Engine - Core tracking logic
class LocationService {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() {
    return _instance;
  }
  
  LocationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _locationUpdateTimer;
  StreamSubscription? _positionStream;
  final _locationStreamController = StreamController<Position>.broadcast();
  
  Stream<Position> get locationStream => _locationStreamController.stream;
  
  static const int UPDATE_INTERVAL_SECONDS = 30; // Update every 30 seconds
  static const LocationAccuracy LOCATION_ACCURACY = LocationAccuracy.high;

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
      
      // Enable background location updates (handled by background service)
      return true;
    } catch (e) {
      print('Error requesting location permissions: $e');
      return false;
    }
  }

  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LOCATION_ACCURACY,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Update user's location in Supabase profiles table
  Future<bool> updateLocationInSupabase({
    required double latitude,
    required double longitude,
    int? batteryLevel,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('profiles').update({
        'last_lat': latitude,
        'last_lng': longitude,
        'last_seen': DateTime.now().toIso8601String(),
        'is_online': true,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating location in Supabase: $e');
      return false;
    }
  }

  /// Start continuous location tracking (30-second intervals)
  /// This should be called from the background service and main app
  Future<void> startLocationTracking() async {
    if (_locationUpdateTimer != null) {
      print('Location tracking already active');
      return;
    }

    final hasPermission = await requestLocationPermissions();
    if (!hasPermission) {
      print('Location permissions not granted');
      return;
    }

    // Perform immediate update
    final position = await getCurrentLocation();
    if (position != null) {
      await updateLocationInSupabase(
        latitude: position.latitude,
        longitude: position.longitude,
        batteryLevel: await _getBatteryLevel(),
      );
      _locationStreamController.add(position);
    }

    // Set up periodic updates
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: UPDATE_INTERVAL_SECONDS),
      (_) => _performLocationUpdate(),
    );

    print('Location tracking started');
  }

  /// Stop continuous location tracking
  void stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
    print('Location tracking stopped');
  }

  /// Internal method to perform periodic location update
  Future<void> _performLocationUpdate() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        await updateLocationInSupabase(
          latitude: position.latitude,
          longitude: position.longitude,
          batteryLevel: await _getBatteryLevel(),
        );
        _locationStreamController.add(position);
        print('Location updated: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      print('Error in periodic location update: $e');
    }
  }

  /// Get battery level (simple implementation)
  Future<int> _getBatteryLevel() async {
    try {
      // This would require battery_info plugin for real implementation
      // For now, returning a default value
      return 85;
    } catch (e) {
      return 100;
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  static double haversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    return distanceKm * 1000; // Convert to meters
  }

  static double _toRadians(double degree) {
    return degree * (3.14159265359 / 180);
  }

  /// Set user offline status
  Future<void> setUserOffline() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('profiles').update({
        'is_online': false,
      }).eq('id', userId);
    } catch (e) {
      print('Error setting user offline: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}

