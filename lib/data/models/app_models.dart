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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotionName': emotionName,
      'confidence': confidence,
      'insight': insight,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
      'colorValue': color.value,
    };
  }

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      id: json['id'] as String,
      emotionName: json['emotionName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      insight: json['insight'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      suggestions: List<String>.from(json['suggestions'] as List),
      color: Color(json['colorValue'] as int),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;
  final String? feedback; // 'positive', 'negative', or null

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
    this.feedback,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestions,
    String? feedback,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
      'feedback': feedback,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      suggestions: json['suggestions'] != null ? List<String>.from(json['suggestions'] as List) : null,
      feedback: json['feedback'] as String?,
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback,
    };
  }

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      content: json['content'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      feedback: json['feedback'] as String?,
    );
  }
}

