import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../projects/data/mock_projects.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/animated_tech_chip.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    // Get featured projects
    final allProjects = ref.watch(projectsProvider);
    final featuredProjects = allProjects.where((p) => p.isFeatured).toList();

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
              // HERO SECTION
              Text(
                'Hello, I am',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Muhammad Atif',
                style: isDesktop ? theme.textTheme.displayLarge?.copyWith(fontSize: 64) : theme.textTheme.displayLarge,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Text(
                  'I build production-quality Flutter applications and integrate cutting-edge NLP/AI models to create seamless, intelligent products. Currently open to new opportunities.',
                  style: theme.textTheme.bodyLarge,
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
              ),
              
              const SizedBox(height: 48),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  PrimaryButton(
                    text: 'View Projects',
                    icon: Icons.work,
                    onPressed: () => context.go('/projects'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/contact'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Contact Me',
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 80),

              // HIGHLIGHTS SECTION
              const SectionHeader(
                title: 'Featured Work',
                subtitle: 'Selected projects showcasing my expertise',
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
              
              const SizedBox(height: 32),

              SizedBox(
                height: 400,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featuredProjects.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final project = featuredProjects[index];
                    return GlassCard(
                      width: isDesktop ? 350 : MediaQuery.of(context).size.width * 0.75,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              project.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            project.title,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              project.description,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: project.techStack.take(3).map((tech) => AnimatedTechChip(label: tech)).toList(),
                          )
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 1000 + (index * 200)), duration: 500.ms).slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/chat');
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Chat with AI'),
        backgroundColor: theme.colorScheme.secondary,
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms),
    );
  }
}
