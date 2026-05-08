import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/project.dart';

final projectsProvider = Provider<List<Project>>((ref) {
  return [
    const Project(
      id: '1',
      title: 'AI Code Assistant',
      description: 'A deep-learning powered coding assistant that contextually understands large codebases.',
      imageUrl: 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?auto=format&fit=crop&q=80&w=1000',
      techStack: ['Flutter', 'Python', 'TensorFlow', 'NLP'],
      githubUrl: 'https://github.com',
      isFeatured: true,
    ),
    const Project(
      id: '2',
      title: 'LegalTech Document Analyzer',
      description: 'An NLP tool built for law firms to rapidly scan and summarize 100+ page contracts.',
      imageUrl: 'https://images.unsplash.com/photo-1450101499163-c8848c66cb85?auto=format&fit=crop&q=80&w=1000',
      techStack: ['Flutter Web', 'Firebase', 'OpenAI API'],
      liveUrl: 'https://flutter.dev',
      isFeatured: true,
    ),
    const Project(
      id: '3',
      title: 'Fintech Dashboard UI',
      description: 'A pixel-perfect, highly animated financial dashboard mimicking top-tier banking apps.',
      imageUrl: 'https://images.unsplash.com/photo-1616077168079-7e09a6a38f4d?auto=format&fit=crop&q=80&w=1000',
      techStack: ['Flutter', 'Riverpod', 'fl_chart'],
      githubUrl: 'https://github.com',
    ),
  ];
});
