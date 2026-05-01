import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/mock_experience.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/animated_tech_chip.dart';

class ExperiencePage extends ConsumerWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiences = ref.watch(experienceProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

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
                title: 'Experience',
                subtitle: 'My professional journey',
              ).animate().fadeIn(duration: 500.ms),
              
              const SizedBox(height: 32),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final exp = experiences[index];
                  final dateFormat = DateFormat('MMM yyyy');
                  final start = dateFormat.format(exp.startDate);
                  final end = exp.endDate != null ? dateFormat.format(exp.endDate!) : 'Present';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: exp.isEducation ? theme.colorScheme.secondary : theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != experiences.length - 1)
                                Container(
                                  width: 2,
                                  height: 100, // Approximate height, or use IntrinsicHeight
                                  color: theme.dividerColor.withOpacity(0.1),
                                ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isDesktop)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exp.role,
                                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '$start - $end',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.role,
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$start - $end',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      exp.isEducation ? Icons.school : Icons.business,
                                      size: 16,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      exp.company,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  exp.description,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: exp.techStack.map((tech) => AnimatedTechChip(label: tech)).toList(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms).slideY(begin: 0.1, end: 0),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
