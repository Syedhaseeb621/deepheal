import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/app_models.dart';
import '../../data/mock/mock_data.dart';

// Auth State Provider
final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;
  void setUser(UserModel? user) => state = user;
}

// Navigation Drawer / Bottom Nav Provider
final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(() {
  return NavIndexNotifier();
});

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

// Emotion History Provider
final emotionHistoryProvider = NotifierProvider<EmotionHistoryNotifier, List<EmotionResult>>(() {
  return EmotionHistoryNotifier();
});

class EmotionHistoryNotifier extends Notifier<List<EmotionResult>> {
  @override
  List<EmotionResult> build() => MockData.emotionHistory;

  void addResult(EmotionResult result) {
    state = [result, ...state];
  }
}

// Chat Provider
final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => MockData.initialMessages;

  void sendMessage(String text) {
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];
    
    // Simulate AI Reply
    _simulateAIReply();
  }

  void _simulateAIReply() async {
    await Future.delayed(const Duration(seconds: 1));
    final aiMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: "Thank you for sharing that. It sounds like you're reflecting on your day. Would you like to explore these feelings more or try a calming exercise?",
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: ["Explore Feelings", "Breathing Exercise", "Journaling"],
    );
    state = [...state, aiMsg];
  }
}

// Therapy History Provider
final therapyHistoryProvider = NotifierProvider<TherapyHistoryNotifier, List<TherapySession>>(() {
  return TherapyHistoryNotifier();
});

class TherapyHistoryNotifier extends Notifier<List<TherapySession>> {
  @override
  List<TherapySession> build() => MockData.therapyHistory;

  void addSession(TherapySession session) {
    state = [session, ...state];
  }
}
