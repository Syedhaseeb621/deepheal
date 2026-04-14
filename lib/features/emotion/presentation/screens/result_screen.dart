import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.05), AppColors.purple.withOpacity(0.05)],
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
                      _buildEmotionCircle(),
                      const SizedBox(height: 32),
                      _buildScoreSection(),
                      const SizedBox(height: 32),
                      _buildInsightSection(),
                      const SizedBox(height: 32),
                      _buildSuggestionsSection(context),
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

  Widget _buildEmotionCircle() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.teal.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: const Center(
            child: Icon(Icons.sentiment_satisfied_alt_rounded, size: 80, color: AppColors.teal),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        const Text(
          'Peaceful',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.teal),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildScoreSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Confidence', '94%', AppColors.primary),
          Container(width: 1, height: 40, color: AppColors.textDisabled.withOpacity(0.2)),
          _buildScoreItem('Stability', 'High', AppColors.teal),
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

  Widget _buildInsightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Based on your expression and choice of words, you appear to be in a calm, reflective state. Your respiratory rate seems steady, indicating low stress levels.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggested Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSuggestionCard(
          context,
          '5-Min Meditation',
          'Perfect to maintain this peaceful state.',
          Icons.self_improvement_rounded,
          AppColors.teal,
        ),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          context,
          'Gratitude Journal',
          'Note down three things you are grateful for.',
          Icons.edit_note_rounded,
          AppColors.primary,
        ),
      ],
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSuggestionCard(BuildContext context, String title, String desc, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => context.push('/therapy'),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        color: color.withOpacity(0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
