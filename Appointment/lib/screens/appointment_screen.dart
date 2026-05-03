import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  final List<Map<String, dynamic>> appointments = const [
    {
      'doctor': 'Dr. Hina Khan',
      'date': '2025-07-12',
      'time': '3:30 PM',
      'status': 'Confirmed'
    },
    {
      'doctor': 'Dr. Ali Malik',
      'date': '2025-07-15',
      'time': '11:00 AM',
      'status': 'Pending'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appt = appointments[index];
          return _buildAppointmentCard(appt).animate().fadeIn(duration: 400.ms).scale();
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt) {
    final isConfirmed = appt['status'] == 'Confirmed';

    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          isConfirmed ? Icons.check_circle : Icons.access_time,
          color: isConfirmed ? Colors.greenAccent : Colors.orangeAccent,
          size: 34,
        ),
        title: Text(
          appt['doctor'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Date: ${appt['date']}\nTime: ${appt['time']}",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          appt['status'],
          style: TextStyle(
            color: isConfirmed ? Colors.greenAccent : Colors.orangeAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
