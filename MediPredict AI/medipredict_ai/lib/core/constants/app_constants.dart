class AppConstants {
  AppConstants._();

  static const String appName = 'MediPredict AI';
  static const String appTagline = 'Your AI Health Companion';

  // Border radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 50.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Risk thresholds
  static const int riskLowMax = 3;
  static const int riskMediumMax = 6;

  static String riskLabel(int score) {
    if (score <= riskLowMax) return 'Low';
    if (score <= riskMediumMax) return 'Medium';
    return 'High';
  }
}
