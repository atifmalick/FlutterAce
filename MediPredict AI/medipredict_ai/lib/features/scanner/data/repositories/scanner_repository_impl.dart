import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/medical_report.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../../../core/supabase_client.dart';
import '../../../../core/utils/reference_ranges.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  @override
  List<ExtractedBiomarker> analyzeExtractedText(String text) {
    final biomarkers = <ExtractedBiomarker>[];
    final lines = text.split('\n');

    for (final line in lines) {
      // Try to find biomarker names and numeric values in each line
      for (final ref in ReferenceRanges.ranges) {
        final lowerLine = line.toLowerCase();
        bool found = lowerLine.contains(ref.name.toLowerCase());
        if (!found) {
          for (final alias in ref.aliases) {
            if (lowerLine.contains(alias)) {
              found = true;
              break;
            }
          }
        }

        if (found) {
          // Extract numeric value from line
          final numRegex = RegExp(r'(\d+\.?\d*)');
          final matches = numRegex.allMatches(line).toList();

          if (matches.isNotEmpty) {
            // Take the most likely value (usually first significant number)
            for (final match in matches) {
              final value = double.tryParse(match.group(1)!);
              if (value != null && value > 0) {
                // Heuristic: skip very small or very large numbers that are likely not the reading
                if (value >= ref.min * 0.1 && value <= ref.max * 10) {
                  biomarkers.add(ExtractedBiomarker(
                    name: ref.name,
                    value: value,
                    unit: ref.unit,
                    refMin: ref.min,
                    refMax: ref.max,
                    isAbnormal: ref.isAbnormal(value),
                  ));
                  break;
                }
              }
            }
          }
        }
      }
    }

    return biomarkers;
  }

  @override
  Future<MedicalReport> saveReport({
    required String userId,
    required String fileUrl,
    required String extractedText,
    required Map<String, dynamic> analysisJson,
  }) async {
    final response = await SupabaseClientHelper.medicalReports()
        .insert({
          'user_id': userId,
          'file_url': fileUrl,
          'extracted_text': extractedText,
          'ai_analysis_json': analysisJson,
        })
        .select()
        .single();

    return MedicalReport.fromJson(response);
  }

  @override
  Future<List<MedicalReport>> getReports(String userId) async {
    final response = await SupabaseClientHelper.medicalReports()
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MedicalReport.fromJson(json))
        .toList();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
