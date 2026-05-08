# CircleGuard - Quick Reference Guide

## 🚀 Quick Start (5 minutes)

### 1. Supabase Setup
```bash
# Go to supabase.com → Create Project
# Copy URL and Anon Key
# Update lib/main.dart:
await Supabase.initialize(
  url: 'YOUR_URL',
  anonKey: 'YOUR_KEY',
);
```

### 2. Database Migration
```bash
# Copy supabase/migrations/001_init_schema.sql
# Paste into Supabase SQL Editor → Execute
```

### 3. Google Maps
```bash
# Get API key from Google Cloud Console
# Add to android/app/src/main/AndroidManifest.xml
# Add to ios/Runner/Info.plist
```

### 4. Build & Run
```bash
flutter pub get
flutter run
```

---

## 📱 Core Services

### Start Location Tracking
```dart
final locationService = LocationService();
await locationService.requestLocationPermissions();
await locationService.startLocationTracking();
```

### Create Circle
```dart
final circleService = CircleService();
final circle = await circleService.createCircle(
  name: 'My Family',
  description: 'Family members',
);
print('Invite Code: ${circle.inviteCode}');
```

### Join Circle
```dart
await circleService.joinCircle('123456');
```

### Stream Member Locations
```dart
circleService.streamCircleMembers(circleId).listen((members) {
  // Update map markers
  for (var member in members) {
    updateMarker(member);
  }
});
```

### Create Safe Zone
```dart
final geofenceService = GeofenceService();
await geofenceService.createGeofence(
  circleId: circleId,
  name: 'School',
  latitude: 37.7749,
  longitude: -122.4194,
  radiusMeters: 500,
);
```

### Sign In / Sign Up
```dart
// Sign up
await AuthService().signUp(
  email: 'user@example.com',
  password: 'secure',
  displayName: 'John',
);

// Sign in
await AuthService().signIn(
  email: 'user@example.com',
  password: 'secure',
);

// Get profile
final profile = await AuthService().getCurrentUserProfile();
```

---

## 🎯 Common Tasks

### Calculate Distance
```dart
final distance = LocationService.haversineDistance(
  lat1: 37.7749, lon1: -122.4194,
  lat2: 37.3382, lon2: -121.8863,
);
print('Distance: ${distance / 1000} km');
```

### Check if Inside Geofence
```dart
final isInside = geofenceService.isUserInGeofence(
  userLat: 37.7749,
  userLng: -122.4194,
  geofenceLat: 37.7749,
  geofenceLng: -122.4194,
  radiusMeters: 500,
);
```

### Get Circle Members
```dart
final members = await circleService.getCircleMembers(circleId);
```

### Get Geofence Events
```dart
final events = await geofenceService.getGeofenceEvents(
  circleId: circleId,
  limitDays: 7,
);
```

### Update User Profile
```dart
await AuthService().updateUserProfile(
  displayName: 'Jane Doe',
  avatarUrl: 'https://...',
);
```

---

## 🎨 UI Components

### Add Marker to Map
```dart
final markers = <Marker>{};
markers.add(
  Marker(
    markerId: MarkerId(member.id),
    position: LatLng(member.lastLat!, member.lastLng!),
    infoWindow: InfoWindow(
      title: member.displayName,
      snippet: 'Battery: ${member.batteryLevel}%',
    ),
  ),
);
setState(() => _markers = markers);
```

### Show Circle List
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => CircleSelector(
    circles: circles,
    selectedCircle: selectedCircle,
    onCircleSelected: (circle) {
      // Update state
    },
  ),
);
```

### Show Members Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => MembersBottomSheet(
    members: members,
    circle: circle,
    onMemberTap: (member) {
      // Navigate to member
    },
  ),
);
```

### Create Geofence Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AddSafeZoneDialog(
    circle: circle,
    onSafeZoneCreated: () {
      // Refresh map
    },
  ),
);
```

---

## 🔧 Configuration

### Location Update Interval
```dart
// In AppConfig
static const int LOCATION_UPDATE_INTERVAL_SECONDS = 30;
```

### Theme Colors
```dart
// Primary Color (Trust Blue)
Color(0xFF1E88E5)

// Accent Color (Safe Green)
Color(0xFF43A047)

// Error Color
Color(0xFFD32F2F)
```

### Feature Flags
```dart
// Enable/disable features
static const bool ENABLE_BACKGROUND_SERVICE = true;
static const bool ENABLE_PUSH_NOTIFICATIONS = true;
static const bool DEBUG_MODE = true;
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/services/location_service_test.dart
```

### Integration Tests
```bash
flutter test integration_test/app_test.dart
```

### With Coverage
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## 🐛 Debugging

### View Logs
```bash
flutter run -v
```

### Print Debugging
```dart
print('Debug: $value');
debugPrint('Debug: $value');
```

### DevTools
```bash
flutter pub global activate devtools
devtools
```

### Database Inspection
```bash
# Supabase Dashboard → SQL Editor
SELECT * FROM profiles LIMIT 10;
```

---

## 📊 Database Queries

### Get User's Circles
```sql
SELECT circles.* FROM circles
JOIN circle_members ON circles.id = circle_members.circle_id
WHERE circle_members.user_id = 'user-id';
```

### Get Online Members
```sql
SELECT * FROM profiles
WHERE is_online = true
AND id IN (
  SELECT user_id FROM circle_members
  WHERE circle_id = 'circle-id'
);
```

### Get Recent Geofence Events
```sql
SELECT * FROM geofence_events
WHERE circle_id = 'circle-id'
AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

### Update Location
```sql
UPDATE profiles
SET last_lat = 37.7749,
    last_lng = -122.4194,
    last_seen = NOW()
WHERE id = 'user-id';
```

---

## 🚨 Error Handling

### Common Errors

**"Permission denied"**
```dart
// Check RLS policies
// Verify user is in circle
```

**"Invalid invite code"**
```dart
// Verify code format (6 digits)
// Check code hasn't expired
```

**"Location permission denied"**
```dart
// Request permission via:
await LocationService().requestLocationPermissions();
```

**"Map not rendering"**
```bash
# Clear cache and rebuild:
flutter clean && flutter pub get && flutter run
```

---

## 📦 Deployment Commands

### Android Release
```bash
flutter build apk --release

# Split by ABI
flutter build apk --release --split-per-abi
```

### iOS Release
```bash
flutter build ios --release

# Archive in Xcode for App Store submission
```

### Web Release
```bash
flutter build web --release
```

---

## 🔐 Security Checklist

- [ ] Update Supabase credentials
- [ ] Configure Google Maps API restrictions
- [ ] Enable HTTPS everywhere
- [ ] Configure RLS policies
- [ ] Review permission scopes
- [ ] Test with invalid inputs
- [ ] Check for sensitive data in logs
- [ ] Verify token expiration

---

## 📚 File Location Reference

| What | File |
|-----|------|
| Main app | `lib/main.dart` |
| Auth screens | `lib/screens/auth/` |
| Home screen | `lib/screens/home/home_screen.dart` |
| Location service | `lib/services/location_service.dart` |
| Circle service | `lib/services/circle_service.dart` |
| Geofence service | `lib/services/geofence_service.dart` |
| Database schema | `supabase/migrations/001_init_schema.sql` |
| Android config | `android/app/src/main/AndroidManifest.xml` |
| iOS config | `ios/Runner/Info.plist` |
| Theme | `lib/theme/app_theme.dart` |
| Config | `lib/config/app_config.dart` |

---

## 🎯 Development Workflow

### 1. Feature Development
```bash
# Pull latest
git pull

# Create branch
git checkout -b feature/your-feature

# Make changes
# Test locally
flutter test
flutter run

# Commit
git add .
git commit -m "feat: your feature"
```

### 2. Build Testing
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk
flutter build ios
```

### 3. Deployment
```bash
# Update version
# Build release
flutter build apk --release
flutter build ios --release

# Submit to stores
```

---

## 💡 Pro Tips

1. **Real-Time Updates**: Use StreamBuilder for live data
2. **Marker Clustering**: For 50+ members, implement clustering
3. **Battery Optimization**: Increase update interval in dev
4. **Testing**: Always test on real devices
5. **Networking**: Cache data locally when offline
6. **Performance**: Use profiler to identify bottlenecks
7. **Security**: Never commit API keys
8. **Documentation**: Keep README updated

---

## 🆘 Getting Help

- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Supabase Support**: https://supabase.com/support
- **Google Maps**: https://issuetracker.google.com/issues?q=componentid:187172
- **Stack Overflow**: Tag with `flutter`, `supabase`, `google-maps-flutter`

---

**Last Updated**: May 4, 2026  
**Version**: 1.0.0
