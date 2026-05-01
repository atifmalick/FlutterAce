// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  techStack: (json['techStack'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  githubUrl: json['githubUrl'] as String?,
  liveUrl: json['liveUrl'] as String?,
  isFeatured: json['isFeatured'] as bool? ?? false,
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'techStack': instance.techStack,
  'githubUrl': instance.githubUrl,
  'liveUrl': instance.liveUrl,
  'isFeatured': instance.isFeatured,
};
