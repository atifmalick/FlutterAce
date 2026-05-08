import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/supabase_client.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<TriageResult> analyzeSymptoms(String symptoms) async {
    // Try Supabase Edge Function first, fallback to local analysis
    try {
      final response = await SupabaseClientHelper.client.functions.invoke(
        'analyze-symptoms',
        body: {'symptoms': symptoms},
      );
      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return TriageResult.fromJson(data);
      }
    } catch (_) {
      // Edge function not available, use local heuristic
    }
    return _localSymptomAnalysis(symptoms);
  }

  /// Local heuristic-based symptom analysis fallback
  TriageResult _localSymptomAnalysis(String symptoms) {
    final lower = symptoms.toLowerCase();
    int score = 1;
    final conditions = <String>[];
    final recommendations = <String>[];
    final tags = <String>[];

    // High severity keywords
    final highSeverity = ['chest pain', 'difficulty breathing', 'shortness of breath',
      'severe bleeding', 'unconscious', 'seizure', 'stroke', 'heart attack',
      'paralysis', 'suicidal', 'overdose'];
    for (final kw in highSeverity) {
      if (lower.contains(kw)) { score += 4; tags.add(kw); }
    }

    // Medium severity
    final medSeverity = ['fever', 'high temperature', 'vomiting', 'diarrhea',
      'severe headache', 'migraine', 'blood in urine', 'blood in stool',
      'persistent cough', 'swelling', 'dizziness', 'fainting', 'palpitations'];
    for (final kw in medSeverity) {
      if (lower.contains(kw)) { score += 2; tags.add(kw); }
    }

    // Low severity
    final lowSeverity = ['cold', 'runny nose', 'sore throat', 'mild headache',
      'fatigue', 'tiredness', 'muscle ache', 'back pain', 'nausea',
      'sneezing', 'cough', 'stomach ache', 'insomnia', 'stress', 'anxiety'];
    for (final kw in lowSeverity) {
      if (lower.contains(kw)) { score += 1; tags.add(kw); }
    }

    score = score.clamp(1, 10);

    // Determine risk level
    String riskLevel;
    if (score <= 3) {
      riskLevel = 'Low';
      conditions.addAll(['Common Cold', 'Minor Ailment', 'Stress-related symptoms']);
      recommendations.addAll(['Rest and hydration', 'Over-the-counter medication may help', 'Monitor symptoms for 24-48 hours']);
    } else if (score <= 6) {
      riskLevel = 'Medium';
      conditions.addAll(['Possible Infection', 'Inflammatory condition', 'Requires monitoring']);
      recommendations.addAll(['Schedule a doctor appointment within 24-48 hours', 'Monitor temperature regularly', 'Stay hydrated and rest']);
    } else {
      riskLevel = 'High';
      conditions.addAll(['Potential Emergency', 'Requires immediate medical attention']);
      recommendations.addAll(['Seek emergency medical care immediately', 'Call emergency services if symptoms worsen', 'Do not ignore these symptoms']);
    }

    return TriageResult(
      riskLevel: riskLevel,
      riskScore: score,
      possibleConditions: conditions,
      recommendations: recommendations,
    );
  }

  @override
  Future<void> saveHealthLog({
    required String userId,
    required List<String> symptomTags,
    required int severityScore,
    required String aiNotes,
  }) async {
    await SupabaseClientHelper.healthLogs().insert({
      'user_id': userId,
      'symptom_tags': symptomTags,
      'severity_score': severityScore,
      'ai_notes': aiNotes,
    });
  }
}
