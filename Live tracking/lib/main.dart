import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://fwzdjunutkhbemcnjdlb.supabase.co',
    anonKey: 'sb_publishable_yPW_-yh_gkvm70U4htmFBA_h7PAZp63',
  );

  runApp(const CircleGuardApp());
}

class CircleGuardApp extends StatelessWidget {
  const CircleGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CircleGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => _buildHome(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  Widget _buildHome() {
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      return const HomeScreen();
    } else {
      return const SplashScreen();
    }
  }
}
