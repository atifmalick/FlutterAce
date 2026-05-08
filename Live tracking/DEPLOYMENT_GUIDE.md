# CircleGuard - Deployment & Setup Guide

## Pre-Deployment Checklist

### 1. Environment Configuration
- [ ] Update `lib/config/app_config.dart` with Supabase URL and API Key
- [ ] Add Google Maps API key to Android & iOS configs
- [ ] Update package name from `com.example.circleguard` to your domain
- [ ] Update app display name

### 2. Database Setup

#### Connect to Supabase
```bash
# Go to https://supabase.com
# Create new project
# Note: Project URL and Anon Key
```

#### Run Database Migration
```sql
-- Copy entire content of supabase/migrations/001_init_schema.sql
-- Paste into Supabase SQL Editor
-- Execute
```

#### Enable Realtime
```sql
-- In Supabase Dashboard → Realtime
-- Enable for the following tables:
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE circle_members;
ALTER PUBLICATION supabase_realtime ADD TABLE geofences;
```

### 3. Authentication Setup

#### Supabase Auth
```bash
# In Supabase Dashboard → Authentication → Providers
# Enable: Email/Password
# Configure redirect URLs:
# - Android: YOUR_APP://auth-callback
# - iOS: YOUR_APP://auth-callback
# - Web: https://YOUR_DOMAIN/auth/callback
```

### 4. Android Setup

#### Update Package Name
```bash
# In android/app/build.gradle
applicationId "com.yourcompany.circleguard"

# In android/app/src/main/AndroidManifest.xml
package="com.yourcompany.circleguard"
```

#### Add Google Maps API Key
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
</application>
```

#### Build APK
```bash
flutter build apk --release --split-per-abi

# Or for universal APK:
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/`

#### Sign APK (for Play Store)
```bash
# Create keystore (run once):
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Create key.properties:
cat > android/key.properties << EOF
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=key
storeFile=../key.jks
EOF

# Build signed APK:
flutter build apk --release
```

### 5. iOS Setup

#### Update Bundle ID
```bash
# In Xcode:
# Runner → Build Settings → Product Bundle Identifier
# Change to: com.yourcompany.circleguard

# Or via command line:
# ios/Runner.xcodeproj/project.pbxproj
```

#### Add Google Maps API Key
```xml
<!-- ios/Runner/Info.plist -->
<key>GoogleMapsAPIKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

#### Update Location Permissions
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>CircleGuard needs your location to track and share it with your circles.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>CircleGuard needs continuous access to share your location.</string>
```

#### Build for Simulator
```bash
flutter build ios --release

# Or run directly:
flutter run -d "iPhone 14" --release
```

#### Build for App Store
```bash
# In Xcode:
# Select: Product → Destination → Generic iOS Device
# Archive: Product → Archive
# Export with App Store profile

# Or via command line:
flutter build ios --release
# Then use Xcode to archive and upload
```

### 6. Testing Before Release

#### Functional Tests
- [ ] User can sign up
- [ ] User can sign in
- [ ] User can create a circle
- [ ] User can join a circle with invite code
- [ ] Circle members appear on map
- [ ] Location updates every 30 seconds
- [ ] User can create safe zone
- [ ] Geofence entry/exit triggers notification
- [ ] Battery level updates
- [ ] User can logout

#### Permission Tests (Both Platforms)
- [ ] Request location permission on first launch
- [ ] Handle denied permissions gracefully
- [ ] Request notification permission
- [ ] Request camera permission (if avatar feature enabled)

#### Background Service Tests
- [ ] Location tracking continues after closing app
- [ ] Notifications trigger while app is in background
- [ ] App restarts when killed by system
- [ ] Battery usage is acceptable

#### Real Device Testing
```bash
# List connected devices:
flutter devices

# Run on specific device:
flutter run -d <device_id>

# Run with debug logs:
flutter run -d <device_id> -v
```

### 7. Release Configuration

#### Version Bumping
```yaml
# pubspec.yaml
version: 1.0.0+1

# For releases:
# 1.0.1+2 (patch version)
# 1.1.0+3 (minor version)
# 2.0.0+4 (major version)
```

#### Firebase Analytics (Optional)
```bash
flutter pub add firebase_core firebase_analytics

# Configure in Firebase Console
# Download google-services.json (Android)
# Download GoogleService-Info.plist (iOS)
```

#### Crash Reporting (Optional)
```bash
flutter pub add firebase_crashlytics

# Add to main.dart:
await Firebase.initializeApp();
```

### 8. Play Store Deployment

#### Create App Listing
1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details:
   - Title: CircleGuard
   - Description: Real-time location sharing
   - Category: Maps & Navigation
   - Screenshots (minimum 2)
   - Icon & Feature Graphic (1024x500px)

#### Submit for Review
```bash
# Build signed APK
flutter build apk --release

# Upload to Google Play Console
# Pricing & Distribution → Free
# Content Rating → Fill questionnaire
# Submit for review
```

**Review Time**: 2-24 hours

### 9. App Store Deployment

#### Create App in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app
3. Fill in app information

#### Upload Build
```bash
# Build for App Store:
flutter build ios --release

# Archive in Xcode:
# Product → Archive

# Submit:
# Xcode Organizer → Distribute App
```

**Review Time**: 24-48 hours

### 10. Post-Launch

#### Monitoring
- [ ] Check crash reports
- [ ] Monitor user feedback
- [ ] Review analytics
- [ ] Track user retention

#### Updates
```bash
# For bug fixes:
flutter build apk --release --build-number=2
flutter build ios --release --build-number=2

# For new features:
# Update version in pubspec.yaml
flutter build apk --release
flutter build ios --release
```

---

## Environment Variables

Create `.env` file for development:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_MAPS_API_KEY=your-google-maps-key
PACKAGE_NAME=com.yourcompany.circleguard
```

### Load in Flutter:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const CircleGuardApp());
}
```

---

## Troubleshooting

### Build Issues
```bash
# Clean build:
flutter clean
flutter pub get
flutter build apk --release

# Check Gradle issues:
./gradlew build
```

### Maps Not Showing
```bash
# Verify API key is enabled:
# Google Cloud Console → APIs & Services → Maps SDK for Android/iOS

# Clear cache:
flutter clean
```

### Background Service Not Starting
```bash
# Check Android 12+ permissions:
# Settings → App Permissions → Location → Allow all the time

# iOS: Settings → Privacy & Security → Location Services
```

### RLS Policy Issues
```sql
-- Verify RLS is enabled:
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Re-enable if needed:
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

---

## Performance Optimization

### Location Tracking
- Adjust update interval in `AppConfig.LOCATION_UPDATE_INTERVAL_SECONDS`
- Use high accuracy only when needed
- Implement battery optimization

### Map Performance
- Use marker clustering for 50+ markers
- Implement map tile caching
- Lazy load member data

### Database
- Indexes created on frequently queried columns
- Archive old geofence events monthly
- Use pagination for large datasets

---

## Security Checklist

- [ ] Change default Supabase credentials
- [ ] Enable HTTPS everywhere
- [ ] Use strong passwords for admin accounts
- [ ] Implement rate limiting on API
- [ ] Regular security audits
- [ ] Keep Flutter/Dart updated
- [ ] Scan dependencies for vulnerabilities
- [ ] Encrypt sensitive data at rest

---

## Support & Documentation

- Flutter Docs: https://flutter.dev/docs
- Supabase Docs: https://supabase.com/docs
- Google Maps Docs: https://developers.google.com/maps
- Geolocator: https://pub.dev/packages/geolocator

---

**Last Updated**: May 4, 2026
