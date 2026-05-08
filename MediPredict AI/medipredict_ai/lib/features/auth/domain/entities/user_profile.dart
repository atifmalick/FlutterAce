class UserProfile {
  final String id;
  final String fullName;
  final String medicalHistorySummary;
  final String bloodGroup;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.medicalHistorySummary = '',
    this.bloodGroup = '',
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      medicalHistorySummary: json['medical_history_summary'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'medical_history_summary': medicalHistorySummary,
    'blood_group': bloodGroup,
  };

  UserProfile copyWith({
    String? fullName,
    String? medicalHistorySummary,
    String? bloodGroup,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      medicalHistorySummary: medicalHistorySummary ?? this.medicalHistorySummary,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      createdAt: createdAt,
    );
  }
}
