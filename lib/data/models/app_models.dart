import 'package:flutter/material.dart';

class EmotionResult {
  final String id;
  final String emotionName;
  final double confidence; // 0.0 to 1.0
  final String insight;
  final DateTime timestamp;
  final List<String> suggestions;
  final Color color;

  EmotionResult({
    required this.id,
    required this.emotionName,
    required this.confidence,
    required this.insight,
    required this.timestamp,
    required this.suggestions,
    required this.color,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}

class TherapySession {
  final String id;
  final String title;
  final String type; // 'breathing', 'journaling'
  final String? content;
  final DateTime timestamp;
  final String? feedback;

  TherapySession({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    required this.timestamp,
    this.feedback,
  });
}
