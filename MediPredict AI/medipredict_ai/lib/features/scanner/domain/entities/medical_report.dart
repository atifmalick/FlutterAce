class MedicalReport {
  final String id;
  final String userId;
  final String fileUrl;
  final String extractedText;
  final Map<String, dynamic> aiAnalysisJson;
  final DateTime createdAt;

  const MedicalReport({
    required this.id,
    required this.userId,
    required this.fileUrl,
    this.extractedText = '',
    this.aiAnalysisJson = const {},
    required this.createdAt,
  });

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fileUrl: json['file_url'] as String? ?? '',
      extractedText: json['extracted_text'] as String? ?? '',
      aiAnalysisJson: json['ai_analysis_json'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'file_url': fileUrl,
    'extracted_text': extractedText,
    'ai_analysis_json': aiAnalysisJson,
  };
}

/// Represents a single extracted biomarker from an OCR scan.
class ExtractedBiomarker {
  final String name;
  final double value;
  final String unit;
  final double refMin;
  final double refMax;
  final bool isAbnormal;

  const ExtractedBiomarker({
    required this.name,
    required this.value,
    required this.unit,
    required this.refMin,
    required this.refMax,
    required this.isAbnormal,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'ref_min': refMin,
    'ref_max': refMax,
    'is_abnormal': isAbnormal,
  };
}
