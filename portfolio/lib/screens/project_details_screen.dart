import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String demoLink;
  final List<String> techStack;

  const ProjectDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.demoLink,
    required this.techStack,
  });

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text(title),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: title,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ).animate().fadeIn(duration: 800.ms).scale(),
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Technologies Used:",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: techStack.map((tech) {
                return Chip(
                  label: Text(
                    tech,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueGrey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ).animate().fadeIn();
              }).toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(demoLink),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withOpacity(0.8),
                  foregroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  "View Demo",
                  style: TextStyle(fontSize: 18),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
