import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFF00BCD4);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color cases = Color(0xFFFF9800);
  static const Color deaths = Color(0xFFF44336);
  static const Color recovered = Color(0xFF4CAF50);
  static const Color active = Color(0xFF2196F3);
}

class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle numberStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withOpacity(0.1),
        AppColors.secondary.withOpacity(0.1),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

class AppConstants {
  static const String appName = 'COVID-19 Tracker';
  static const String apiSource = 'disease.sh';
  static const String githubRepo = 'https://github.com/disease-sh/API';
  static const String whoWebsite = 'https://covid19.who.int/';

  static const List<Map<String, dynamic>> preventionTips = [
    {
      'title': 'Wash Hands',
      'icon': '🚿',
      'description': 'Wash hands regularly with soap and water',
    },
    {
      'title': 'Wear Mask',
      'icon': '😷',
      'description': 'Wear mask in public places',
    },
    {
      'title': 'Social Distance',
      'icon': '↔️',
      'description': 'Maintain 6 feet distance',
    },
    {
      'title': 'Vaccinate',
      'icon': '💉',
      'description': 'Get vaccinated and boosted',
    },
  ];
}