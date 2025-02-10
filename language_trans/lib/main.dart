import 'package:flutter/material.dart';
import 'package:language_trans/language_translation.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translater application',
      debugShowCheckedModeBanner: false,
      
      home: LanguageTranslationPage(),
    );
  }
}
