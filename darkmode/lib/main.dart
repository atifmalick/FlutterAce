import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dark-Mode'),
        ),
        body: Center(
          child: Container(
            child: Text('Welcome to the Flutter',
            style: TextStyle(
              fontSize: 20,
              color: Colors.blueGrey,
            ),),
          ),
          
        ),

      ),
      
    );
  }
}
