# CircleGuard - API Reference

## Services API

### AuthService

```dart
class AuthService {
  // Authentication
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String displayName,
  })

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  })

  Future<void> signOut()

  // Profile Management
  Future<UserProfile?> getCurrentUserProfile()
  Future<UserProfile?> getUserProfile(String userId)

  Future<bool> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  })

  // Status
  bool isAuthenticated()
  String? getCurrentUserId()
  String? getCurrentUserEmail()

  // State Monitoring
  Stream<AuthState> authStateChanges()

  // Password Management
  Future<bool> resetPassword(String email)
  Future<bool> updatePassword(String newPassword)
}
```

### LocationService

```dart
class LocationService {
  // Permissions
  Future<bool> requestLocationPermissions()

  // Location Access
  Future<Position?> getCurrentLocation()

  // Tracking Control
  Future<void> startLocationTracking()
  void stopLocationTracking()

  // Updates to Supabase
  Future<bool> updateLocationInSupabase({
    required double latitude,
    required double longitude,
    int? batteryLevel,
  })

  // Calculations
  static double haversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  })

  // Status
  Future<void> setUserOffline()

  // Cleanup
  void dispose()
}

// Constants
LocationService.UPDATE_INTERVAL_SECONDS = 30
LocationService.LOCATION_ACCURACY = LocationAccuracy.high
```

### CircleService

```dart
class CircleService {
  // Circle Operations
  Future<Circle?> createCircle({
    required String name,
    String? description,
    String? color,
  })

  Future<bool> joinCircle(String inviteCode)

  Future<List<Circle>> getUserCircles()

  Future<Circle?> getCircle(String circleId)

  Future<bool> updateCircle({
    required String circleId,
    String? name,
    String? description,
    String? color,
  })

  Future<bool> deleteCircle(String circleId)

  Future<bool> leaveCircle(String circleId)

  // Member Management
  Future<List<UserProfile>> getCircleMembers(String circleId)

  Future<bool> removeMember({
    required String circleId,
    required String userId,
  })

  // Real-Time Features
  Stream<List<UserProfile>> streamCircleMembers(String circleId)

  // Invite Code
  Future<String?> getCircleInviteCode(String circleId)
}
```

### GeofenceService

```dart
class GeofenceService {
  // Initialization
  Future<void> initializeNotifications()

  // Geofence Management
  Future<Geofence?> createGeofence({
    required String circleId,
    required String name,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    String color = '#43A047',
  })

  Future<List<Geofence>> getCircleGeofences(String circleId)

  Future<bool> deleteGeofence(String geofenceId)

  // Monitoring
  bool isUserInGeofence({
    required double userLat,
    required double userLng,
    required double geofenceLat,
    required double geofenceLng,
    required int radiusMeters,
  })

  Future<void> monitorGeofence({
    required Geofence geofence,
    required double currentUserLat,
    required double currentUserLng,
    required String currentUserId,
    required String currentUserName,
  })

  Future<void> startGeofenceMonitoring({
    required List<String> circleIds,
    required double userLat,
    required double userLng,
    required String userId,
    required String userName,
  })

  // Events
  Future<List<GeofenceEvent>> getGeofenceEvents({
    required String circleId,
    int limitDays = 7,
  })

  // Cleanup
  void dispose()
}
```

### BackgroundService

```dart
class BackgroundService {
  // Initialization
  Future<void> initializeBackgroundService()

  // Control
  Future<void> startBackgroundLocationTracking()
  Future<void> stopBackgroundLocationTracking()

  // Main Handler
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service)
}
```

---

## Data Models

### UserProfile
```dart
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final double? lastLat;
  final double? lastLng;
  final bool isOnline;
  final int batteryLevel; // 0-100
  final DateTime lastSeen;
  final DateTime createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
  UserProfile copyWith(...)
}
```

### Circle
```dart
class Circle {
  final String id;
  final String name;
  final String inviteCode; // 6-digit code
  final String adminId;
  final String? description;
  final String? color;
  final bool isActive;
  final DateTime createdAt;

  factory Circle.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}
```

### CircleMember
```dart
class CircleMember {
  final String id;
  final String circleId;
  final String userId;
  final String role; // 'admin' | 'member'
  final DateTime joinedAt;

  factory CircleMember.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}
```

### Geofence
```dart
class Geofence {
  final String id;
  final String circleId;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? createdBy;
  final String color; // Hex color
  final bool isActive;
  final DateTime createdAt;

  factory Geofence.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}
```

### GeofenceEvent
```dart
class GeofenceEvent {
  final String id;
  final String geofenceId;
  final String userId;
  final String eventType; // 'entered' | 'exited'
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  factory GeofenceEvent.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}
```

---

## Supabase SQL Queries

### Insert Profile
```sql
INSERT INTO profiles (id, email, display_name, last_seen)
VALUES ('user-id', 'user@example.com', 'John Doe', NOW());
```

### Update Location
```sql
UPDATE profiles
SET last_lat = 37.7749,
    last_lng = -122.4194,
    last_seen = NOW(),
    is_online = true
WHERE id = 'user-id';
```

### Create Circle
```sql
INSERT INTO circles (name, invite_code, admin_id)
VALUES ('Family', '123456', 'admin-id')
RETURNING *;
```

### Add Circle Member
```sql
INSERT INTO circle_members (circle_id, user_id, role)
VALUES ('circle-id', 'user-id', 'member');
```

### Get Circle Members with Location
```sql
SELECT cm.*, p.display_name, p.last_lat, p.last_lng, p.battery_level
FROM circle_members cm
JOIN profiles p ON cm.user_id = p.id
WHERE cm.circle_id = 'circle-id';
```

### Create Geofence
```sql
INSERT INTO geofences (circle_id, name, latitude, longitude, radius_meters, created_by)
VALUES ('circle-id', 'School', 37.7749, -122.4194, 500, 'user-id')
RETURNING *;
```

### Log Geofence Event
```sql
INSERT INTO geofence_events (geofence_id, user_id, event_type, latitude, longitude)
VALUES ('geofence-id', 'user-id', 'entered', 37.7749, -122.4194);
```

### Get Recent Geofence Events
```sql
SELECT * FROM geofence_events
WHERE geofence_id IN (
  SELECT id FROM geofences WHERE circle_id = 'circle-id'
)
AND created_at > NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
```

---

## RLS Policies

### Profile Access
```sql
-- Users see their own profile
SELECT * FROM profiles WHERE id = auth.uid();

-- Users see circle members' profiles
SELECT * FROM profiles
WHERE id IN (
  SELECT user_id FROM circle_members
  WHERE circle_id IN (
    SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
  )
);
```

### Circle Access
```sql
-- Members view their circles
SELECT * FROM circles
WHERE id IN (
  SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
);
```

### Geofence Management
```sql
-- Members view geofences
SELECT * FROM geofences
WHERE circle_id IN (
  SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
);

-- Admins can modify
UPDATE geofences SET ...
WHERE circle_id IN (
  SELECT id FROM circles WHERE admin_id = auth.uid()
);
```

---

## Error Codes

| Code | Message | Solution |
|------|---------|----------|
| 401 | Unauthorized | Sign in again |
| 403 | Permission denied | Check RLS policies |
| 404 | Resource not found | Verify circle/user ID |
| 409 | Conflict | Email/code already exists |
| 422 | Invalid data | Check input validation |
| 429 | Rate limited | Wait before retrying |
| 500 | Server error | Contact support |

---

## Rate Limiting

- Location updates: 30 seconds minimum
- Geofence checks: Once per location update
- API calls: 100 per minute per user

---

## Example Workflows

### Complete User Setup
```dart
// 1. Sign up
await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John',
);

// 2. Start location tracking
await locationService.startLocationTracking();

// 3. Create circle
final circle = await circleService.createCircle(
  name: 'Family',
);

// 4. Share invite code
print(circle.inviteCode); // "123456"

// 5. Initialize geofencing
await geofenceService.initializeNotifications();

// 6. Create safe zone
await geofenceService.createGeofence(
  circleId: circle.id,
  name: 'School',
  latitude: 37.7749,
  longitude: -122.4194,
  radiusMeters: 500,
);
```

### Real-Time Member Tracking
```dart
// Stream member locations
circleService.streamCircleMembers(circleId).listen((members) {
  // Update map markers
  for (final member in members) {
    if (member.lastLat != null && member.lastLng != null) {
      _addMarker(member);
    }
  }
});
```

### Geofence Monitoring Loop
```dart
// In location update handler
final geofences = await geofenceService.getCircleGeofences(circleId);
for (final geofence in geofences) {
  await geofenceService.monitorGeofence(
    geofence: geofence,
    currentUserLat: currentLocation.latitude,
    currentUserLng: currentLocation.longitude,
    currentUserId: userId,
    currentUserName: userName,
  );
}
```

---

**Version**: 1.0.0  
**Last Updated**: May 4, 2026
