import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custome_button.dart';
import 'about_screen.dart';
import 'projects_screen.dart';
import 'skills_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ✅ URL launcher method
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture
                  const CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage("assets/images/profile.jpg"),
                  )
                      .animate()
                      .fadeIn(duration: 1000.ms)
                      .scale(delay: 300.ms),

                  const SizedBox(height: 20),

                  // Name
                  const Text(
                    "Muhammad Atif",
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: -0.2, curve: Curves.easeOutBack),

                  const SizedBox(height: 8),

                  // Tagline
                  const Text(
                    "Flutter Developer | ML Enthusiast",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: -0.2, curve: Curves.easeOutBack),

                  const SizedBox(height: 30),

                  // Social Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialIcon(Icons.email, Colors.orange, () {
                        _launchUrl("mailto:atifraheem@gmail.com");
                      }),
                      socialIcon(Icons.phone, Colors.greenAccent, () {
                        _launchUrl("tel:+923128634510");
                      }),
                      socialIcon(Icons.link, Colors.amber, () {
                        _launchUrl("https://yourportfolio.com");
                      }),
                      socialIcon(Icons.code, Colors.blueAccent, () {
                        _launchUrl("https://github.com/atifmalick");
                      }),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(delay: 400.ms),

                  const SizedBox(height: 30),

                  // Glassmorphism Menu Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomButton("About Me", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AboutScreen()),
                          );
                        }),
                        CustomButton("Projects", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProjectsScreen()),
                          );
                        }),
                        CustomButton("Skills", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SkillsScreen()),
                          );
                        }),
                        CustomButton("Contact Me", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ContactScreen()),
                          );
                        }),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 900.ms)
                      .slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 Reusable Social Icon
  Widget socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
