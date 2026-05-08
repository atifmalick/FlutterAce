// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Skill _$SkillFromJson(Map<String, dynamic> json) => _Skill(
  id: json['id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$SkillCategoryEnumMap, json['category']),
  proficiency: (json['proficiency'] as num).toDouble(),
  iconUrl: json['iconUrl'] as String?,
);

Map<String, dynamic> _$SkillToJson(_Skill instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': _$SkillCategoryEnumMap[instance.category]!,
  'proficiency': instance.proficiency,
  'iconUrl': instance.iconUrl,
};

const _$SkillCategoryEnumMap = {
  SkillCategory.frontend: 'frontend',
  SkillCategory.backend: 'backend',
  SkillCategory.ai: 'ai',
  SkillCategory.tools: 'tools',
};
