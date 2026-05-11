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

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

// Chat Provider
final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => MockData.initialMessages;

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];
    
    // Add "Typing..." placeholder
    final typingMsg = ChatMessage(
      id: 'typing',
      text: '...',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [...state, typingMsg];
    
    // Call real Backend API
    await _getAIResponse(text);
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": "user_123", 
          "message": userMessage,
        }),
      ).timeout(const Duration(seconds: 10));

      // Remove typing indicator
      state = state.where((m) => m.id != 'typing').toList();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final emotion = data['emotion'] ?? 'default';
        final responseData = data['response'] ?? {
          'text': "I'm here for you.",
          'suggestion': "Take a deep breath.",
          'reflection': "How are you feeling now?"
        };
        
        final aiMsg = ChatMessage(
          id: DateTime.now().toString(),
          text: responseData['text'],
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: [
            "Emotion: $emotion",
            responseData['suggestion'],
            responseData['reflection'],
          ],
        );
        state = [...state, aiMsg];
      } else {
        _addErrorMsg("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Remove typing indicator on error
      state = state.where((m) => m.id != 'typing').toList();
      _addErrorMsg("Connection failed. Please ensure the backend is running at ${ApiConstants.baseUrl}");
    }
  }

  void _addErrorMsg(String error) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().toString(),
        text: "Sorry, I'm having trouble connecting. $error",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
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
