import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_projects.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/animated_tech_chip.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
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
                title: 'Projects',
                subtitle: 'A selection of my recent work',
              ).animate().fadeIn(duration: 500.ms),
              
              const SizedBox(height: 32),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: isDesktop ? 1.5 : 1.1,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              project.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.title,
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (project.githubUrl != null)
                                  IconButton(
                                    icon: const Icon(Icons.code),
                                    onPressed: () => launchUrl(Uri.parse(project.githubUrl!)),
                                    tooltip: 'View Source',
                                  ),
                                if (project.liveUrl != null)
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () => launchUrl(Uri.parse(project.liveUrl!)),
                                    tooltip: 'Live Demo',
                                  ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            project.description,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.techStack.map((tech) => AnimatedTechChip(label: tech)).toList(),
                        )
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 600.ms).slideY(begin: 0.2, end: 0).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
