import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Projects"),
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
          children: [
            const SizedBox(height: 20),
            projectCard(
              context: context,
              icon: Icons.cloud,
              title: "Animated Weather UI",
              image: "assets/images/weather.jpg",
              description:
              "A Flutter weather app with animated Lottie backgrounds and live API integration.",
              demoLink: "https://github.com/atifmalick/WeatherApp",
            ),
            projectCard(
              context: context,
              icon: Icons.psychology,
              title: "Brain Tumor Detection",
              image: "assets/images/brain.jpg",
              description:
              "CNN-powered deep learning model for detecting brain tumors from MRI images.",
              demoLink: "https://github.com/atifmalick/BrainTumorDetection",
            ),
            projectCard(
              context: context,
              icon: Icons.book,
              title: "Book Recommendation System",
              image: "assets/images/book.jpg",
              description:
              "ML-based recommendation system for suggesting books based on user preferences.",
              demoLink: "https://github.com/atifmalick/BookRecommender",
            ),
            projectCard(
              context: context,
              icon: Icons.chat,
              title: "Real-time Chat App",
              image: "assets/images/chat.jpg",
              description:
              "Flutter Firebase chat app with real-time messaging and group support.",
              demoLink: "https://github.com/atifmalick/FlutterChatApp",
            ),
          ]
              .animate(interval: 300.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.08, curve: Curves.easeOutBack),
        ),
      ),
    );
  }

  Widget projectCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String image,
    required String description,
    required String demoLink,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(
              title: title,
              description: description,
              image: image,
              demoLink: demoLink, techStack: [],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blueGrey[700],
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18)
          ],
        ),
      ),
    );
  }
}
