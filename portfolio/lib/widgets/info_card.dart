import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        subtitle: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 22)),
      ),
    );
  }
}
