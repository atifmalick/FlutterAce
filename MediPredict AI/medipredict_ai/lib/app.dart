import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';

class MediPredictApp extends StatelessWidget {
  const MediPredictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediPredict AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
