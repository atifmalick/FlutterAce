# CircleGuard - Real-Time Location Sharing App

**A production-grade Flutter + Supabase solution for real-time location sharing with geofencing capabilities.**

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Database Schema](#database-schema)
4. [Project Phases](#project-phases)
5. [Setup Instructions](#setup-instructions)
6. [API Documentation](#api-documentation)
7. [Security & Privacy](#security--privacy)
8. [Deployment](#deployment)

---

## 🎯 Project Overview

**CircleGuard** enables users to:
- Create "Circles" (groups) with unique 6-digit invite codes
- Share live location with circle members in real-time
- Monitor members on a Google Map with custom markers
- Create "Safe Zones" (geofences) with automated entry/exit alerts
- Track battery levels and online status
- Receive local notifications for geofence events

**Key Features:**
- ✅ Real-time synchronization via Supabase Realtime
- ✅ Background location tracking (30-second intervals)
- ✅ Geofence monitoring with Haversine formula
- ✅ Row-Level Security (RLS) for privacy
- ✅ Professional UI with Trust Blue & Safe Green theme
- ✅ Responsive design for iOS & Android

---

## 🛠 Tech Stack

### Frontend
- **Flutter** 3.0+
- **Dart** 3.0+
- **Google Maps Flutter** 2.7.0
- **Geolocator** 10.0 (location services)
- **Supabase Flutter** 2.0 (realtime & auth)

### Backend
- **Supabase** (PostgreSQL + Realtime + Edge Functions)
- **Row-Level Security (RLS)** for data privacy
- **PostgreSQL Extensions**: uuid-ossp, pgcrypto

### Background & Notifications
- **Flutter Background Service** 5.0+
- **Flutter Local Notifications** 17.0+
- **Permission Handler** 11.4+

### UI/UX
- **Material Design 3**
- **Animations** library for smooth transitions
- **Connectivity Plus** for network state

---

## 📊 Database Schema

### Tables Overview

```
┌─────────────────────────────────────────┐
│           DATABASE SCHEMA               │
└─────────────────────────────────────────┘

profiles
├── id (UUID, PK)
├── email (TEXT, UNIQUE)
├── display_name
├── avatar_url
├── last_lat, last_lng (DOUBLE)
├── is_online (BOOLEAN)
├── battery_level (INT)
├── last_seen (TIMESTAMP)
└── created_at, updated_at

circles
├── id (UUID, PK)
├── name
├── invite_code (UNIQUE, 6 digits)
├── admin_id (FK → profiles)
├── description, color
├── is_active
└── created_at, updated_at

circle_members
├── id (UUID, PK)
├── circle_id (FK → circles)
├── user_id (FK → profiles)
├── role ('admin' | 'member')
└── joined_at, updated_at

geofences
├── id (UUID, PK)
├── circle_id (FK → circles)
├── name, latitude, longitude, radius_meters
├── created_by (FK → profiles)
├── color, is_active
└── created_at, updated_at

geofence_events
├── id (UUID, PK)
├── geofence_id (FK → geofences)
├── user_id (FK → profiles)
├── event_type ('entered' | 'exited')
├── latitude, longitude
└── created_at
```

### Row-Level Security (RLS) Policies

- **profiles**: Users see only themselves and circle members
- **circles**: Members can view their circles
- **circle_members**: Members see circle memberships
- **geofences**: Members view, admins manage
- **geofence_events**: Members view their circle's events

---

## 🚀 Project Phases

### Phase 1: Infrastructure ✅
- [x] Supabase Auth setup
- [x] Database schema with RLS policies
- [x] Enable Realtime on profiles table
- [x] Helper functions (generate_invite_code)

### Phase 2: Location Engine 🔄
- [x] LocationService class (permissions & updates)
- [x] 30-second background update cycle
- [x] Battery level tracking
- [x] Background service initialization
- [ ] **TODO**: Test on real devices

### Phase 3: Map UI 🔄
- [x] Google Maps integration
- [x] Dynamic markers with StreamBuilder
- [x] Custom marker styling
- [x] Circle member list (bottom sheet)
- [ ] **TODO**: Reverse geocoding for addresses
- [ ] **TODO**: Smooth marker animations

### Phase 4: Geofencing 🔄
- [x] Geofence creation (admin UI)
- [x] Haversine distance calculation
- [x] Entry/exit detection
- [x] Local notifications
- [x] Event logging
- [ ] **TODO**: Push notifications via Edge Functions

---

## 🔧 Setup Instructions

### Prerequisites
```bash
- Flutter 3.0+
- Dart 3.0+
- Xcode 14+ (iOS development)
- Android SDK 31+ (Android development)
- Supabase account (https://supabase.com)
- Google Maps API key
```

### 1. Clone & Dependencies
```bash
cd f:\Flutter\Live tracking
flutter pub get
```

### 2. Supabase Setup

#### Create Supabase Project
1. Go to https://supabase.com and create a new project
2. Note your **Project URL** and **Anon Key**

#### Run Database Migration
```bash
# In Supabase Dashboard → SQL Editor
# Copy & paste content of: supabase/migrations/001_init_schema.sql
# Execute query
```

#### Enable Realtime
```sql
-- In Supabase → Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE circle_members;
```

#### Update main.dart
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Google Maps Setup

#### Android
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create/select project
3. Enable **Maps SDK for Android**
4. Create API key
5. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY" />
```

#### iOS
1. Enable **Maps SDK for iOS** in Google Cloud Console
2. Add key to `ios/Runner/Info.plist`:
```xml
<key>GoogleMapsAPIKey</key>
<string>YOUR_API_KEY</string>
```

### 4. Run Application
```bash
flutter pub get
flutter run
```

---

## 📱 API Documentation

### LocationService

```dart
// Start tracking
await LocationService().startLocationTracking();

// Stop tracking
LocationService().stopLocationTracking();

// Get current location
final position = await LocationService().getCurrentLocation();

// Calculate distance (Haversine)
double distance = LocationService.haversineDistance(
  lat1: 37.7749,
  lon1: -122.4194,
  lat2: 37.8044,
  lon2: -122.2712,
);
```

### CircleService

```dart
// Create circle
final circle = await CircleService().createCircle(
  name: 'My Family',
  description: 'Family tracking circle',
);

// Join circle
await CircleService().joinCircle('123456');

// Get circle members (realtime)
CircleService().streamCircleMembers(circleId).listen((members) {
  // Update UI
});

// Remove member (admin)
await CircleService().removeMember(
  circleId: circle.id,
  userId: userId,
);
```

### GeofenceService

```dart
// Create safe zone
final geofence = await GeofenceService().createGeofence(
  circleId: circleId,
  name: 'School',
  latitude: 37.7749,
  longitude: -122.4194,
  radiusMeters: 500,
);

// Monitor geofence
await GeofenceService().monitorGeofence(
  geofence: geofence,
  currentUserLat: 37.7749,
  currentUserLng: -122.4194,
  currentUserId: userId,
  currentUserName: 'John',
);

// Get geofence events
final events = await GeofenceService().getGeofenceEvents(
  circleId: circleId,
  limitDays: 7,
);
```

### AuthService

```dart
// Sign up
await AuthService().signUp(
  email: 'user@example.com',
  password: 'secure_password',
  displayName: 'John Doe',
);

// Sign in
await AuthService().signIn(
  email: 'user@example.com',
  password: 'secure_password',
);

// Sign out
await AuthService().signOut();

// Get current profile
final profile = await AuthService().getCurrentUserProfile();
```

---

## 🔒 Security & Privacy

### Authentication
- **Supabase Auth** with email/password
- **Session tokens** stored securely
- **Auto sign-out** when app closes

### Data Privacy (RLS Policies)
- Users can only view their own profile
- Location data shared only with circle members
- Only circle admins can manage geofences
- Geofence events visible only to circle members

### Location Data
- **Encrypted in transit** (HTTPS/TLS)
- **Updated every 30 seconds** (battery efficient)
- **Automatic cleanup** of offline users (optional)
- **User can revoke access** anytime

### Background Service
- **Minimal permissions** requested
- **No data collected without consent**
- **User can disable** background tracking

---

## 📦 Deployment

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build iOS App
```bash
flutter build ios --release
# Use Xcode to upload to TestFlight/App Store
```

### Build Web (Optional)
```bash
flutter build web --release
# Output: build/web/
```

### Firebase/Analytics (Optional)
```bash
flutter pub add firebase_core firebase_analytics
# Configure in Firebase Console
```

---

## 🐛 Troubleshooting

### Background Service Not Starting
```bash
# Check Android 12+ permissions
# Grant "Allow all the time" for location

# iOS: Check Settings → Privacy → Location
```

### Realtime Updates Not Working
```sql
-- Verify Realtime is enabled:
SELECT * FROM pg_publication WHERE pubname = 'supabase_realtime';

-- Check table subscriptions:
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
```

### Google Maps Not Rendering
- Verify API key is enabled for Maps SDK
- Check AndroidManifest.xml for key placement
- Run `flutter clean && flutter pub get && flutter run`

### Location Permission Denied
```dart
// Request permissions explicitly
bool hasPermission = await LocationService().requestLocationPermissions();
```

---

## 📝 Development Notes

### Next Steps
1. **Phase 3.3**: Implement reverse geocoding for "Current Address"
2. **Phase 3.4**: Add smooth marker animations with `google_maps_flutter_web`
3. **Phase 4.2**: Setup Supabase Edge Functions for push notifications
4. **Phase 5**: User profiles with avatar upload
5. **Phase 6**: Family hierarchy & parental controls
6. **Phase 7**: Emergency SOS alerts

### Performance Considerations
- **Location updates**: 30-second interval (configurable)
- **Map tile caching**: Built-in with Google Maps
- **Marker clustering**: Use MarkerClusterer for 100+ markers
- **Database indexes**: Already created on frequently queried columns

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📄 License

This project is built for demonstration and production purposes. Ensure compliance with location data regulations (GDPR, CCPA, etc.) before deployment.

---

## 👨‍💻 Contributing

For development contributions:
1. Follow Dart style guide
2. Test on both Android & iOS
3. Update this README
4. Test geofencing accuracy

---

**Version**: 1.0.0  
**Last Updated**: May 4, 2026  
**Status**: Active Development (Phase 2-4)
