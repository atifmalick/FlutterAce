import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  final List<Map<String, String>> doctors = const [
    {
      'name': 'Dr. Hina Khan',
      'specialty': 'Cardiologist',
      'image': 'assets/images/doctor2.jpg'
    },
    {
      'name': 'Dr. Ali Malik',
      'specialty': 'Dermatologist',
      'image': 'assets/images/doctor1.webp'
    },
    {
      'name': 'Dr. Ahmed Raza',
      'specialty': 'Neurologist',
      'image': 'assets/images/doctor3.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Available Doctors"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _buildDoctorCard(context, doctor).animate().fadeIn(duration: 400.ms).scale();
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, String> doctor) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(doctor['image']!),
          radius: 30,
        ),
        title: Text(
          doctor['name']!,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          doctor['specialty']!,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorProfileScreen(
                  name: doctor['name']!,
                  specialty: doctor['specialty']!,
                  imagePath: doctor['image']!,
                ),
              ),
            );
          },

      ),
    );
  }
}
