import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<TriageResult> analyzeSymptoms(String symptoms);
  Future<void> saveHealthLog({
    required String userId,
    required List<String> symptomTags,
    required int severityScore,
    required String aiNotes,
  });
}
