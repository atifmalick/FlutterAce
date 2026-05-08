import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import '../widgets/skill_progress.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Skills & Tools"),
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
            lottieHeader("assets/animations/flutter.json"),
            sectionCard(
              title: "📱 Flutter Development",
              skills: const [
                ["Dart Programming", 0.9],
                ["Flutter Widgets & State Management", 0.85],
                ["Firebase Integration", 0.8],
                ["Animations & UI Design", 0.85],
                ["REST API Integration", 0.8],
                ["Supabase / Cloud Firestore", 0.75],
              ],
            ),
            const SizedBox(height: 24),
            lottieHeader("assets/animations/ml.json"),
            sectionCard(
              title: "🤖 Machine Learning & AI",
              skills: const [
                ["Python Programming", 0.95],
                ["NumPy / Pandas / Matplotlib", 0.9],
                ["Scikit-learn & Data Preprocessing", 0.85],
                ["Deep Learning (CNN/RNN)", 0.8],
                ["TensorFlow / Keras / PyTorch", 0.8],
                ["Model Deployment (TFLite / APIs)", 0.75],
              ],
            ),
            const SizedBox(height: 24),
            sectionCard(
              title: "🛠️ Tools & Workflow",
              skills: const [
                ["Git & GitHub", 0.9],
                ["VS Code / Android Studio", 0.9],
                ["Figma / UI Prototyping", 0.85],
                ["Linux / Command Line Tools", 0.75],
                ["Postman & API Testing", 0.8],
              ],
            ),
          ]
              .animate(interval: 300.ms)
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.08, curve: Curves.easeOutBack),
        ),
      ),
    );
  }

  // 📱 Section Card with glassmorphism style
  Widget sectionCard({required String title, required List<List> skills}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          ...skills.map((item) =>
              SkillProgress(skill: item[0] as String, level: item[1] as double))
        ],
      ),
    );
  }

  // 🔥 Lottie animation header
  Widget lottieHeader(String asset) {
    return Center(
        child: SizedBox(
          height: 130,
          child: Lottie.asset(asset, repeat: true),
        )
            .animate()
            .fadeIn(duration: 1000.ms)
            .scale(),
    );
  }
}
