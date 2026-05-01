import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill.freezed.dart';
part 'skill.g.dart';

enum SkillCategory {
  frontend,
  backend,
  ai,
  tools
}

@freezed
abstract class Skill with _$Skill {
  const factory Skill({
    required String id,
    required String name,
    required SkillCategory category,
    required double proficiency, // 0.0 to 1.0
    String? iconUrl,
  }) = _Skill;

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
}
