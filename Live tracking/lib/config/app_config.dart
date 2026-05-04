/// App configuration constants
class AppConfig {
  // Supabase Configuration
  static const String SUPABASE_URL = 'https://YOUR_SUPABASE_URL.supabase.co';
  static const String SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

  // Location Tracking
  static const int LOCATION_UPDATE_INTERVAL_SECONDS = 30;
  static const double DEFAULT_LATITUDE = 37.7749;
  static const double DEFAULT_LONGITUDE = -122.4194;

  // Geofencing
  static const int DEFAULT_GEOFENCE_RADIUS = 100; // meters
  static const int MIN_GEOFENCE_RADIUS = 10;
  static const int MAX_GEOFENCE_RADIUS = 1000;

  // Circle
  static const int INVITE_CODE_LENGTH = 6;

  // UI Theme Colors
  static const String PRIMARY_COLOR = '#1E88E5'; // Trust Blue
  static const String ACCENT_COLOR = '#43A047'; // Safe Green
  static const String ERROR_COLOR = '#D32F2F';
  static const String WARNING_COLOR = '#FFA726';

  // API Timeouts
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 30);
  static const Duration LOCATION_TIMEOUT = Duration(seconds: 10);

  // Notification Channels
  static const String GEOFENCE_CHANNEL_ID = 'geofence_alerts';
  static const String LOCATION_CHANNEL_ID = 'location_updates';

  // Feature Flags
  static const bool ENABLE_BACKGROUND_SERVICE = true;
  static const bool ENABLE_PUSH_NOTIFICATIONS = true;
  static const bool ENABLE_REVERSE_GEOCODING = true;

  // Development
  static const bool DEBUG_MODE = true;
  static const bool LOG_API_CALLS = true;
}

/// Notification messages
class NotificationMessages {
  static String arrivedAt(String memberName, String zoneName) =>
      '$memberName has arrived at $zoneName';

  static String leftZone(String memberName, String zoneName) =>
      '$memberName has left $zoneName';

  static String locationUpdated(String address) =>
      'Location updated: $address';

  static const String batteryLow = 'Battery is running low';
  static const String offline = 'User went offline';
  static const String online = 'User came online';
}

/// Error messages
class ErrorMessages {
  static const String locationPermissionDenied =
      'Location permission denied. Please enable it in settings.';
  static const String networkError = 'Network error. Check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String invalidInviteCode = 'Invalid invite code.';
  static const String circleNotFound = 'Circle not found.';
  static const String alreadyMember = 'Already a member of this circle.';
  static const String onlyAdminCanDelete = 'Only the admin can delete this.';
  static const String failedToCreateGeofence = 'Failed to create safe zone.';
}

/// Success messages
class SuccessMessages {
  static const String circleCreated = 'Circle created successfully!';
  static const String circleJoined = 'Joined circle successfully!';
  static const String geofenceCreated = 'Safe zone created!';
  static const String memberRemoved = 'Member removed from circle.';
  static const String profileUpdated = 'Profile updated successfully!';
}
