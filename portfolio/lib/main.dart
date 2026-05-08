import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Portfolio App',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Poppins',
            primarySwatch: Colors.cyan,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            primarySwatch: Colors.cyan,
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
