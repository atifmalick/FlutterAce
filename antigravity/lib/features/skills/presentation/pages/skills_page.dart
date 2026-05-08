import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_skills.dart';
import '../../domain/skill.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';

class SkillsPage extends ConsumerWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Group skills by category
    final groupedSkills = <SkillCategory, List<Skill>>{};
    for (var skill in skills) {
      if (!groupedSkills.containsKey(skill.category)) {
        groupedSkills[skill.category] = [];
      }
      groupedSkills[skill.category]!.add(skill);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 64.0 : 24.0,
            vertical: 48.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Skills',
                subtitle: 'Technologies and tools I work with',
              ).animate().fadeIn(duration: 500.ms),
              
              const SizedBox(height: 32),

              ...groupedSkills.entries.map((entry) {
                final category = entry.key;
                final categorySkills = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: categorySkills.map((skill) {
                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: skill.proficiency),
                                  duration: 1500.ms,
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 8,
                                            backgroundColor: theme.dividerColor.withOpacity(0.1),
                                            color: _getColorForCategory(category, theme),
                                          ),
                                        ),
                                        Text(
                                          '${(value * 100).toInt()}%',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  skill.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.8, end: 1.0);
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForCategory(SkillCategory category, ThemeData theme) {
    switch (category) {
      case SkillCategory.frontend:
        return Colors.blueAccent;
      case SkillCategory.backend:
        return Colors.orangeAccent;
      case SkillCategory.ai:
        return theme.colorScheme.secondary;
      case SkillCategory.tools:
        return Colors.grey;
    }
  }
}
