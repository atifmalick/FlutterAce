import 'package:flutter/material.dart';

class SkillProgress extends StatelessWidget {
  final String skill;
  final double level;

  const SkillProgress({super.key, required this.skill, required this.level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: level,
              minHeight: 12,
              color: Colors.amberAccent,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
