import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("About Me"),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Lottie Animation on top
            Lottie.asset("assets/animations/intro.json",
                height: 180, repeat: true),

            const SizedBox(height: 20),

            // Personal Bio Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                "Hello! I'm Muhammad Atif, a passionate Flutter Developer and ML enthusiast.\n\nI specialize in crafting cross-platform mobile apps with beautiful UI and efficient functionality. My interests include AI, app animations, and open-source contributions.\n\nCurrently working on mobile-first projects blending clean UI, smooth animations, and smart ML APIs.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Info Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                InfoTile(label: "Name", value: "Muhammad Atif"),
                InfoTile(label: "Email", value: "atifraheem@gmail.com"),
                InfoTile(label: "Phone", value: "+923128634510"),
                InfoTile(label: "Location", value: "Sukkur, Pakistan"),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}
