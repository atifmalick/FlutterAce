class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final TriageResult? triageResult;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.triageResult,
  });
}

class TriageResult {
  final String riskLevel;
  final int riskScore;
  final List<String> possibleConditions;
  final List<String> recommendations;
  final String disclaimer;

  const TriageResult({
    required this.riskLevel,
    required this.riskScore,
    required this.possibleConditions,
    required this.recommendations,
    this.disclaimer = 'This is not a medical diagnosis. Please consult a healthcare professional.',
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      riskLevel: json['risk_level'] as String? ?? 'Low',
      riskScore: json['risk_score'] as int? ?? 1,
      possibleConditions: (json['possible_conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      disclaimer: json['disclaimer'] as String? ??
          'This is not a medical diagnosis. Please consult a healthcare professional.',
    );
  }

  Map<String, dynamic> toJson() => {
    'risk_level': riskLevel,
    'risk_score': riskScore,
    'possible_conditions': possibleConditions,
    'recommendations': recommendations,
    'disclaimer': disclaimer,
  };
}
