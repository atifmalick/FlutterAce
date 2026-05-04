# CircleGuard - Testing & QA Guide

## Testing Strategy

### Test Pyramid
```
       ▲ UI/E2E Tests (10%)
      ╱│╲ Integration Tests (30%)
     ╱ │ ╲ Unit Tests (60%)
    ╱──┴──╲
```

---

## Unit Tests

### Services Testing

#### Location Service Tests
```dart
// test/services/location_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:circleguard/services/location_service.dart';

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    test('Haversine distance calculation', () {
      // San Francisco to San Jose (≈48 km)
      final distance = LocationService.haversineDistance(
        lat1: 37.7749,
        lon1: -122.4194,
        lat2: 37.3382,
        lon2: -121.8863,
      );

      expect(distance, greaterThan(40000)); // 40+ km
      expect(distance, lessThan(60000));   // less than 60 km
    });

    test('Request location permissions', () async {
      // Mock platform channel
      // Test permission request flow
    });
  });
}
```

#### Geofence Service Tests
```dart
// test/services/geofence_service_test.dart
void main() {
  group('GeofenceService', () {
    test('User inside geofence', () {
      final isInside = GeofenceService().isUserInGeofence(
        userLat: 37.7749,
        userLng: -122.4194,
        geofenceLat: 37.7749,
        geofenceLng: -122.4194,
        radiusMeters: 1000,
      );

      expect(isInside, true);
    });

    test('User outside geofence', () {
      final isInside = GeofenceService().isUserInGeofence(
        userLat: 37.7749,
        userLng: -122.4194,
        geofenceLat: 37.3382,
        geofenceLng: -121.8863,
        radiusMeters: 1000,
      );

      expect(isInside, false);
    });
  });
}
```

#### Auth Service Tests
```dart
// test/services/auth_service_test.dart
void main() {
  group('AuthService', () {
    test('Valid email format', () {
      expect(_isValidEmail('user@example.com'), true);
      expect(_isValidEmail('invalid-email'), false);
    });

    test('Password strength validation', () {
      expect(_isStrongPassword('weak'), false);
      expect(_isStrongPassword('StrongPassword123!'), true);
    });
  });
}
```

### Run Unit Tests
```bash
flutter test test/services/

# With coverage:
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## Integration Tests

### User Flow Testing

#### Sign Up & Sign In
```dart
// test_driver/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sign Up Flow', () {
    testWidgets('User can sign up', (WidgetTester tester) async {
      await tester.pumpWidget(const CircleGuardApp());
      
      // Navigate to signup
      await tester.tap(find.byText('Sign Up'));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'John Doe',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        'SecurePassword123',
      );
      
      // Submit
      await tester.tap(find.byText('Create Account'));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Verify success
      expect(find.byText('Account created!'), findsOneWidget);
    });
  });

  group('Circle Management', () {
    testWidgets('User can create circle', (WidgetTester tester) async {
      // Setup: Login first
      // Navigate to create circle
      // Fill name and description
      // Verify circle appears
    });

    testWidgets('User can join circle', (WidgetTester tester) async {
      // Setup: Login first
      // Enter invite code
      // Verify joined successfully
    });
  });

  group('Map Functionality', () {
    testWidgets('Map displays member markers', (WidgetTester tester) async {
      // Verify Google Map renders
      // Verify markers appear for members
      // Verify real-time updates
    });
  });

  group('Geofencing', () {
    testWidgets('User can create safe zone', (WidgetTester tester) async {
      // Long press on map
      // Fill zone details
      // Verify creation
    });

    testWidgets('Geofence entry triggers notification', (WidgetTester tester) async {
      // Mock location update inside geofence
      // Verify notification appears
    });
  });
}
```

### Run Integration Tests
```bash
# Start emulator first
flutter emulators --launch android_emulator

# Run integration tests
flutter test integration_test/ --release

# For specific test:
flutter test integration_test/app_test.dart -t "Sign Up Flow"
```

---

## UI/Functional Tests

### Manual Test Cases

#### Authentication Module
- [ ] **TC-AUTH-001**: Sign up with valid credentials
  - Expected: Account created, redirected to login
  - Steps: Enter name, email, password → Click Sign Up

- [ ] **TC-AUTH-002**: Sign up with existing email
  - Expected: Error message "Email already in use"
  
- [ ] **TC-AUTH-003**: Sign in with correct credentials
  - Expected: Navigate to home screen
  
- [ ] **TC-AUTH-004**: Sign in with wrong password
  - Expected: Error message "Invalid credentials"

- [ ] **TC-AUTH-005**: Sign out
  - Expected: Clear session, navigate to login

#### Circle Management
- [ ] **TC-CIRCLE-001**: Create new circle
  - Expected: Circle created, invite code generated
  - Steps: Click + → Enter name → Click Create

- [ ] **TC-CIRCLE-002**: Copy invite code
  - Expected: Code copied to clipboard
  - Steps: Click share icon → Select copy

- [ ] **TC-CIRCLE-003**: Join circle with valid code
  - Expected: Added as member, see members on map
  - Steps: Click + → Enter code → Click Join

- [ ] **TC-CIRCLE-004**: Join with invalid code
  - Expected: Error "Invalid invite code"

- [ ] **TC-CIRCLE-005**: Leave circle
  - Expected: Removed from members list
  - Steps: Open circle menu → Click Leave

#### Map & Location
- [ ] **TC-MAP-001**: View circle members on map
  - Expected: Markers appear for all members
  
- [ ] **TC-MAP-002**: Member location updates
  - Expected: Marker moves within 30 seconds
  - Setup: Move device location
  
- [ ] **TC-MAP-003**: Tap member marker
  - Expected: InfoWindow shows name and battery
  
- [ ] **TC-MAP-004**: View members list
  - Expected: Shows all members with battery %
  - Steps: Click list icon → View members

- [ ] **TC-MAP-005**: My location button
  - Expected: Camera focuses on current location
  - Steps: Click crosshair icon

#### Geofencing (Admin Only)
- [ ] **TC-GEO-001**: Create safe zone
  - Expected: Circle appears on map
  - Steps: Long-press on map → Fill details → Create

- [ ] **TC-GEO-002**: Adjust geofence radius
  - Expected: Circle size changes
  - Steps: Use slider in creation dialog

- [ ] **TC-GEO-003**: Enter geofence
  - Expected: Local notification triggers
  - Setup: Mock location inside zone

- [ ] **TC-GEO-004**: Exit geofence
  - Expected: Exit notification triggers
  - Setup: Mock location outside zone

- [ ] **TC-GEO-005**: Delete geofence
  - Expected: Circle removed from map
  - Steps: Long-press circle → Delete

#### Notifications
- [ ] **TC-NOTIF-001**: Notification appears when member joins circle
  - Expected: Badge on circle button increments

- [ ] **TC-NOTIF-002**: Notification for geofence entry
  - Expected: "Member arrived at Zone" shown

- [ ] **TC-NOTIF-003**: Notification for low battery
  - Expected: Battery warning notification

- [ ] **TC-NOTIF-004**: Tap notification navigates correctly
  - Expected: Open relevant screen

#### Background Service
- [ ] **TC-BG-001**: Location tracking continues after app close
  - Expected: Location updates visible when reopened
  - Setup: Close app → Wait 1 min → Reopen

- [ ] **TC-BG-002**: Background service restarts after device reboot
  - Expected: Tracking continues
  - Setup: Reboot device → Check location updates

- [ ] **TC-BG-003**: Battery optimization
  - Expected: Location service uses minimal battery
  - Setup: Monitor battery consumption over 1 hour

#### Permissions
- [ ] **TC-PERM-001**: Request location permission
  - Expected: System dialog appears
  - Note: First launch only

- [ ] **TC-PERM-002**: Handle location permission denied
  - Expected: Error message, option to enable in settings
  - Steps: Deny permission → See error

- [ ] **TC-PERM-003**: Request notification permission
  - Expected: System dialog appears

- [ ] **TC-PERM-004**: App works with camera permission denied
  - Expected: No errors, features still work

---

## Performance Testing

### Load Testing

#### Multiple Members
- [ ] Render map with 10 members
- [ ] Render map with 50 members
- [ ] Render map with 100+ members (expect slower performance)

#### Real-Time Updates
```dart
// Measure update latency
Stopwatch watch = Stopwatch();
watch.start();
// Receive location update
watch.stop();
print('Update latency: ${watch.elapsedMilliseconds}ms');
// Expected: < 500ms
```

### Memory Testing
```bash
# Monitor memory usage
flutter run --profile

# Use DevTools → Memory tab
# Expect: < 150MB typical usage
```

### Battery Testing
- [ ] Track battery usage over 2 hours
- [ ] Expected: < 5% battery drain with location tracking

---

## Device Testing Matrix

### Android
- [ ] Android 11 (API 30)
- [ ] Android 12 (API 31+)
- [ ] Android 13 (API 33)
- [ ] Samsung S21 / S22 / S23
- [ ] Google Pixel 5 / 6 / 7

### iOS
- [ ] iOS 15
- [ ] iOS 16
- [ ] iPhone 12 / 13 / 14
- [ ] iPhone SE

### Network Conditions
- [ ] WiFi 4G
- [ ] 5G
- [ ] Poor signal (Airplane mode + re-enable)

---

## Regression Testing Checklist

Before each release, test:
- [ ] Authentication flow
- [ ] Circle creation & joining
- [ ] Map rendering
- [ ] Location updates
- [ ] Geofencing (entry/exit)
- [ ] Notifications
- [ ] Background service
- [ ] Logout
- [ ] Permission requests

---

## Automated Testing Workflow

```bash
# Run all tests with coverage
./scripts/run_tests.sh

# Build and test
flutter clean
flutter pub get
flutter test --coverage
flutter build apk --release
flutter build ios --release

# Check code quality
dart analyze
dart format --set-exit-if-changed .
```

---

## Known Issues & Workarounds

### Android 12+
**Issue**: Background location not updating  
**Workaround**: Grant "Allow all the time" permission in Settings

### iOS Background
**Issue**: Location stops after app terminated  
**Workaround**: Requires iOS 13+, enable Background Modes in Xcode

### Google Maps Cache
**Issue**: Maps not updating tiles  
**Workaround**: `flutter clean && flutter pub get`

---

## Test Metrics

### Target Coverage
- Unit Tests: 80%+
- Integration Tests: 50%+
- Overall Coverage: 70%+

### Performance Benchmarks
- App Launch: < 2 seconds
- Map Render: < 500ms
- Location Update: < 100ms
- Geofence Check: < 50ms

---

**Last Updated**: May 4, 2026
