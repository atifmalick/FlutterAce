import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/experience.dart';

final experienceProvider = Provider<List<Experience>>((ref) {
  return [
    Experience(
      id: '1',
      role: 'Senior Flutter Developer',
      company: 'Tech Solutions Inc.',
      startDate: DateTime(2022, 5),
      description: 'Led the mobile team in architecting a high-performance e-commerce app. Reduced load times by 40% and implemented custom UI components.',
      techStack: ['Flutter', 'Riverpod', 'Firebase', 'Codemagic'],
    ),
    Experience(
      id: '2',
      role: 'AI / NLP Engineer',
      company: 'InnovateAI',
      startDate: DateTime(2020, 8),
      endDate: DateTime(2022, 4),
      description: 'Developed custom NLP models for document summarization. Integrated these models into a Flutter Web dashboard for legal clients.',
      techStack: ['Python', 'HuggingFace', 'FastAPI', 'Flutter Web'],
    ),
    Experience(
      id: '3',
      role: 'B.S. Computer Science',
      company: 'University of Technology',
      startDate: DateTime(2016, 9),
      endDate: DateTime(2020, 5),
      description: 'Focus on Artificial Intelligence and Software Engineering. Graduated with Honors.',
      techStack: ['C++', 'Java', 'Data Structures', 'Algorithms'],
      isEducation: true,
    ),
  ];
});
