// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Experience _$ExperienceFromJson(Map<String, dynamic> json) => _Experience(
  id: json['id'] as String,
  role: json['role'] as String,
  company: json['company'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  description: json['description'] as String,
  techStack: (json['techStack'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isEducation: json['isEducation'] as bool? ?? false,
);

Map<String, dynamic> _$ExperienceToJson(_Experience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'company': instance.company,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'techStack': instance.techStack,
      'isEducation': instance.isEducation,
    };
