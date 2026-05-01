import 'package:freezed_annotation/freezed_annotation.dart';

part 'experience.freezed.dart';
part 'experience.g.dart';

@freezed
abstract class Experience with _$Experience {
  const factory Experience({
    required String id,
    required String role,
    required String company,
    required DateTime startDate,
    DateTime? endDate,
    required String description,
    required List<String> techStack,
    @Default(false) bool isEducation,
  }) = _Experience;

  factory Experience.fromJson(Map<String, dynamic> json) => _$ExperienceFromJson(json);
}
