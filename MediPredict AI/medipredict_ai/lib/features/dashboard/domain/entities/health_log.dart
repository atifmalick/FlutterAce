class HealthLog {
  final String id;
  final String userId;
  final List<String> symptomTags;
  final int severityScore;
  final String aiNotes;
  final DateTime timestamp;

  const HealthLog({
    required this.id,
    required this.userId,
    required this.symptomTags,
    required this.severityScore,
    this.aiNotes = '',
    required this.timestamp,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      symptomTags: (json['symptom_tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      severityScore: json['severity_score'] as int? ?? 0,
      aiNotes: json['ai_notes'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'symptom_tags': symptomTags,
    'severity_score': severityScore,
    'ai_notes': aiNotes,
    'timestamp': timestamp.toIso8601String(),
  };
}
