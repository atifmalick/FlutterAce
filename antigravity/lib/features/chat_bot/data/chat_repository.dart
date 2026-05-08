import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // Use dotenv or a default empty string for safety during compilation
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  print('ChatRepository: API Key loaded: ${apiKey.isNotEmpty ? 'YES (length: ${apiKey.length})' : 'NO'}');
  return ChatRepository(apiKey: apiKey);
});

class ChatRepository {
  final GenerativeModel _model;
  late final ChatSession _chatSession;
  final String _apiKey;

  ChatRepository({required String apiKey}) 
      : _apiKey = apiKey,
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system('''
You are the AI assistant representing the owner of this portfolio app (Muhammad Atif).
Your goal is to answer questions from recruiters and clients about the developer's experience, skills, and projects in a professional, concise, and helpful manner.
The developer is highly skilled in Flutter, Dart, NLP, and AI.
Keep your answers brief and to the point.
'''),
        ) {
    if (apiKey.isNotEmpty) {
      _chatSession = _model.startChat();
      debugPrint('ChatRepository: Chat session started successfully.');
    }
  }

  Future<String> sendMessage(String text) async {
    if (_apiKey.isEmpty) {
      debugPrint('ChatRepository: No API Key found.');
      return "I'm running in offline mode because no API key was provided. Please add GEMINI_API_KEY to your .env file.";
    }

    try {
      debugPrint('ChatRepository: Sending message to Gemini...');
      final response = await _chatSession.sendMessage(Content.text(text));
      
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        return "I received an empty response from the AI. This might be due to safety filters or a temporary issue.";
      }
      
      return responseText;
    } catch (e) {
      debugPrint('ChatRepository: Error sending message: $e');
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid') || errorStr.contains('403') || errorStr.contains('401')) {
        return "Error: Invalid API Key. Please ensure your Gemini API key is correct and has access to the 'gemini-1.5-flash' model.";
      } else if (errorStr.contains('socketexception') || errorStr.contains('connection failed')) {
        return "Error: Network connection failed. Please check your internet connection.";
      } else if (errorStr.contains('quota')) {
        return "Error: API quota exceeded. Please try again later.";
      }
      
      return "Error: Could not connect to the AI model ($e). Please check your API key and internet connection.";
    }
  }
}
