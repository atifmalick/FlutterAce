import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/skill.dart';

final skillsProvider = Provider<List<Skill>>((ref) {
  return [
    const Skill(id: '1', name: 'Flutter', category: SkillCategory.frontend, proficiency: 0.95),
    const Skill(id: '2', name: 'Dart', category: SkillCategory.frontend, proficiency: 0.9),
    const Skill(id: '3', name: 'Riverpod', category: SkillCategory.frontend, proficiency: 0.85),
    const Skill(id: '4', name: 'Python', category: SkillCategory.ai, proficiency: 0.8),
    const Skill(id: '5', name: 'TensorFlow', category: SkillCategory.ai, proficiency: 0.7),
    const Skill(id: '6', name: 'NLP', category: SkillCategory.ai, proficiency: 0.75),
    const Skill(id: '7', name: 'Firebase', category: SkillCategory.backend, proficiency: 0.85),
    const Skill(id: '8', name: 'Git', category: SkillCategory.tools, proficiency: 0.9),
  ];
});
