import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotions = ref.watch(emotionHistoryProvider);
    final sessions = ref.watch(therapyHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity History',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Emotion Analysis Logs'),
              const SizedBox(height: 16),
              ...emotions.map((e) => _buildEmotionHistoryItem(e)).toList(),
              const SizedBox(height: 40),
              _buildSectionTitle('Therapy Sessions'),
              const SizedBox(height: 16),
              ...sessions.map((s) => _buildTherapyHistoryItem(s)).toList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _buildEmotionHistoryItem(dynamic emotion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: emotion.color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.sentiment_satisfied_rounded, color: emotion.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emotion.emotionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(emotion.timestamp),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text('${(emotion.confidence * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: emotion.color)),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildTherapyHistoryItem(dynamic session) {
    final isJournal = session.type == 'journaling';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isJournal ? AppColors.primary : AppColors.teal).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isJournal ? Icons.edit_note_rounded : Icons.air_rounded, color: isJournal ? AppColors.primary : AppColors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    DateFormat('MMM dd, yyyy').format(session.timestamp),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}
