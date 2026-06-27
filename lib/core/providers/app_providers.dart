import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/app_models.dart';
import '../../data/mock/mock_data.dart';
import '../constants/api_constants.dart';

// Auth State Provider
final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  static const String _loggedInUserIdKey = 'logged_in_user_id';
  static const String _registeredUsersKey = 'registered_users';

  @override
  UserModel? build() {
    _initializeUser();
    return null;
  }

  Future<void> _initializeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInUserId = prefs.getString(_loggedInUserIdKey);
      if (loggedInUserId == null) return;

      // Load the registered users array and find the logged-in user
      final usersJsonString = prefs.getString(_registeredUsersKey) ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJsonString);

      final userMap = usersList.firstWhere(
        (u) => u['id'] == loggedInUserId,
        orElse: () => null,
      );

      if (userMap != null) {
        state = UserModel(
          id: userMap['id'],
          name: userMap['name'] ?? 'User',
          email: userMap['email'] ?? '',
          mood: 'Calm',
        );
      }
    } catch (_) {}
  }

  void setUser(UserModel? user) => state = user;

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInUserIdKey);
    } catch (_) {}
    state = null;
  }
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

// Theme Mode Provider (Light/Dark/System)
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('theme_mode');
      if (mode == 'light') {
        state = ThemeMode.light;
      } else if (mode == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', isDark ? 'dark' : 'light');
    } catch (_) {}
  }
}

// Notifications Toggle Provider
final notificationsEnabledProvider = NotifierProvider<NotificationsNotifier, bool>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadNotificationSetting();
    return true; // Enabled by default
  }

  Future<void> _loadNotificationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled');
      if (enabled != null) {
        state = enabled;
      }
    } catch (_) {}
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
    } catch (_) {}
  }
}

// Emotion History Provider
final emotionHistoryProvider = NotifierProvider<EmotionHistoryNotifier, List<EmotionResult>>(() {
  return EmotionHistoryNotifier();
});

class EmotionHistoryNotifier extends Notifier<List<EmotionResult>> {
  @override
  List<EmotionResult> build() {
    _loadHistory();
    return MockData.emotionHistory;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('emotion_history');
      if (list != null) {
        state = list.map((item) => EmotionResult.fromJson(jsonDecode(item))).toList();
      }
    } catch (_) {}
  }

  Future<void> addResult(EmotionResult result) async {
    state = [result, ...state];
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('emotion_history', list);
    } catch (_) {}
  }
}

// Chat Provider
final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    _loadHistory();
    return MockData.initialMessages;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('chat_history');
      if (list != null) {
        state = list.map((item) => ChatMessage.fromJson(jsonDecode(item))).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('chat_history', list);
    } catch (_) {}
  }

  Future<void> updateMessageFeedback(String messageId, String? feedback) async {
    state = state.map((m) => m.id == messageId ? m.copyWith(feedback: feedback) : m).toList();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    state = MockData.initialMessages;
    await _saveHistory();
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];
    await _saveHistory();
    
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
    final user = ref.read(authProvider);
    final userId = user?.id ?? "anonymous_user";

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId, 
          "message": userMessage,
        }),
      ).timeout(const Duration(seconds: 15));

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
          id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    await _saveHistory();
  }

  void _addErrorMsg(String error) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
  List<TherapySession> build() {
    _loadHistory();
    return MockData.therapyHistory;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('therapy_history');
      if (list != null) {
        state = list.map((item) => TherapySession.fromJson(jsonDecode(item))).toList();
      }
    } catch (_) {}
  }

  Future<void> addSession(TherapySession session) async {
    state = [session, ...state];
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('therapy_history', list);
    } catch (_) {}
  }
}

