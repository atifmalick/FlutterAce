import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home:Scaffold(appBar: AppBar(
        title: Text('Bottom Navigation'),

      ),
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.indigo,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.55),
      selectedFontSize: 18,
      unselectedFontSize: 15,

      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.mail),label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.video_call),label: 'Video Call'),
        BottomNavigationBarItem(icon: Icon(Icons.call),label: 'Voice Call'),

      ],
      ),
      drawer: Drawer(),),
     );
  }
}

