import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isAnalyzing;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isAnalyzing = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isAnalyzing,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String? _userId;
  final _uuid = const Uuid();

  ChatNotifier(this._repository, this._userId) : super(const ChatState()) {
    // Welcome message
    _addBotMessage(
      'Hello! 👋 I\'m your AI health assistant. Describe your symptoms '
      'and I\'ll provide a preliminary risk assessment.\n\n'
      '⚠️ This is not a substitute for professional medical advice.',
    );
  }

  void _addBotMessage(String content, {TriageResult? result}) {
    final msg = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      triageResult: result,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isAnalyzing: true,
      error: null,
    );

    try {
      final result = await _repository.analyzeSymptoms(text);

      // Save to health_logs
      if (_userId != null) {
        final tags = text.toLowerCase().split(RegExp(r'[,.\s]+')).where((t) => t.length > 2).toList();
        await _repository.saveHealthLog(
          userId: _userId,
          symptomTags: tags,
          severityScore: result.riskScore,
          aiNotes: 'Risk: ${result.riskLevel}. Conditions: ${result.possibleConditions.join(", ")}',
        );
      }

      // Build response text
      final buffer = StringBuffer();
      buffer.writeln('📊 **Risk Assessment Complete**\n');
      buffer.writeln('Risk Level: ${result.riskLevel} (${result.riskScore}/10)\n');
      if (result.possibleConditions.isNotEmpty) {
        buffer.writeln('🔍 Possible Conditions:');
        for (final c in result.possibleConditions) {
          buffer.writeln('  • $c');
        }
        buffer.writeln();
      }
      if (result.recommendations.isNotEmpty) {
        buffer.writeln('💡 Recommendations:');
        for (final r in result.recommendations) {
          buffer.writeln('  • $r');
        }
        buffer.writeln();
      }
      buffer.writeln('⚠️ ${result.disclaimer}');

      _addBotMessage(buffer.toString(), result: result);
      state = state.copyWith(isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
      _addBotMessage('Sorry, I encountered an error analyzing your symptoms. Please try again.');
    }
  }

  void clearChat() {
    state = const ChatState();
    _addBotMessage(
      'Chat cleared. Describe your symptoms and I\'ll analyze them for you.',
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(authProvider).profile?.id;
  return ChatNotifier(repo, userId);
});
