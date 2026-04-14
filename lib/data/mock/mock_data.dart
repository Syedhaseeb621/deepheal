import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../models/user_model.dart';

class MockData {
  static UserModel currentUser = UserModel(
    id: 'u1',
    name: 'Sarah Mitchell',
    email: 'sarah@example.com',
    mood: 'Calm',
  );

  static List<EmotionResult> emotionHistory = [
    EmotionResult(
      id: 'e1',
      emotionName: 'Peaceful',
      confidence: 0.92,
      insight: 'You seem to be in a very stable and relaxed state today.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      suggestions: ['Maintain this state with a short meditation.', 'Share your positivity with someone.'],
      color: Colors.teal,
    ),
    EmotionResult(
      id: 'e2',
      emotionName: 'Anxious',
      confidence: 0.78,
      insight: 'There are signs of slight tension in your voice and facial expression.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      suggestions: ['Try the 4-7-8 breathing exercise.', 'Listen to calming ambient sounds.'],
      color: Colors.orange,
    ),
  ];

  static List<TherapySession> therapyHistory = [
    TherapySession(
      id: 's1',
      title: 'Morning Reflection',
      type: 'journaling',
      content: 'I felt productive today but a bit tired.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      feedback: 'Great job identifying your feelings!',
    ),
    TherapySession(
      id: 's2',
      title: 'Deep Breathing',
      type: 'breathing',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      feedback: 'You completed 5 minutes of focused breathing.',
    ),
  ];

  static List<ChatMessage> initialMessages = [
    ChatMessage(
      id: 'm1',
      text: "Hello Sarah! I'm DeepHeal AI. How are you feeling today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];
}
