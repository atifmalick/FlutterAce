import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required List<String> techStack,
    String? githubUrl,
    String? liveUrl,
    @Default(false) bool isFeatured,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}
