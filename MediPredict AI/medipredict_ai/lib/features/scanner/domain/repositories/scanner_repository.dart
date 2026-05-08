import '../entities/medical_report.dart';

abstract class ScannerRepository {
  Future<String> extractTextFromImage(String imagePath);
  List<ExtractedBiomarker> analyzeExtractedText(String text);
  Future<MedicalReport> saveReport({
    required String userId,
    required String fileUrl,
    required String extractedText,
    required Map<String, dynamic> analysisJson,
  });
  Future<List<MedicalReport>> getReports(String userId);
}
