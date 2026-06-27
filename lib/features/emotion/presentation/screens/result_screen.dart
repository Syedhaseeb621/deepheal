import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../data/models/app_models.dart';

class ResultScreen extends StatelessWidget {
  final EmotionResult? result;
  
  const ResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final themeColor = result?.color ?? AppColors.teal;
    final emotion = result?.emotionName ?? 'Peaceful';
    final confidencePercent = result != null ? '${(result!.confidence * 100).toInt()}%' : '94%';
    final insightText = result?.insight ?? 'Based on your expression and choice of words, you appear to be in a calm, reflective state.';
    final suggestionsList = result?.suggestions ?? [
      'Practice a short focused breathing exercise.',
      'Reflect on your thoughts in a journal entry.'
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.withValues(alpha: 0.05), AppColors.purple.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      _buildEmotionCircle(themeColor, emotion),
                      const SizedBox(height: 32),
                      _buildScoreSection(confidencePercent, themeColor),
                      const SizedBox(height: 32),
                      _buildInsightSection(insightText),
                      const SizedBox(height: 32),
                      _buildSuggestionsSection(context, suggestionsList, themeColor),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  text: 'Finish',
                  onPressed: () => context.go('/dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          const Text(
            'Analysis Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildEmotionCircle(Color color, String emotion) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Center(
            child: Icon(Icons.sentiment_satisfied_alt_rounded, size: 80, color: color),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          emotion,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildScoreSection(String confidence, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Confidence', confidence, AppColors.primary),
          Container(width: 1, height: 40, color: AppColors.textDisabled.withValues(alpha: 0.2)),
          _buildScoreItem('Stability', 'High', color),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInsightSection(String insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          insight,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSuggestionsSection(BuildContext context, List<String> suggestions, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggested Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSuggestionCard(
            context,
            suggestion,
            'Recommended based on your current state.',
            Icons.self_improvement_rounded,
            color,
          ),
        )),
      ],
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1, end: 0);
  }


  Widget _buildSuggestionCard(BuildContext context, String title, String desc, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => context.push('/therapy'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        color: color.withValues(alpha: 0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

