import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/message.dart';
import '../../data/chat_repository.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  ChatState({required this.messages, required this.isLoading});

  ChatState copyWith({List<Message>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final _uuid = const Uuid();

  @override
  ChatState build() {
    return ChatState(messages: [
      Message(
        id: const Uuid().v4(),
        text: 'Hi there! I am an AI assistant representing the developer. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      )
    ], isLoading: false);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final repository = ref.read(chatRepositoryProvider);

    // 1. Add user message
    final userMessage = Message(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // 2. Fetch AI response
    final responseText = await repository.sendMessage(text);

    // 3. Add AI message
    final aiMessage = Message(
      id: _uuid.v4(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isLoading: false,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
