import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'book_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String name;
  final String specialty;
  final String imagePath;

  const DoctorProfileScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Doctor Profile"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 60,
            ).animate().scale(),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              specialty,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              "Dr. Hina Khan is a highly experienced cardiologist with over 10 years of medical practice. She specializes in heart disease diagnosis, cardiac treatments, and patient counseling.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text("Book Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
            ).animate().fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
