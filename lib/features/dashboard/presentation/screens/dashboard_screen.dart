import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/app_models.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/mood_chart.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/feedback_summary_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedMood;
  String _selectedIntensity = 'Medium'; // Low, Medium, High

  final Map<String, Map<String, dynamic>> _moods = {
    'Calm': {'icon': Icons.spa_rounded, 'color': Colors.teal, 'insight': 'You seem to be in a very stable and relaxed state.'},
    'Stressed': {'icon': Icons.bolt_rounded, 'color': Colors.orange, 'insight': 'You are carrying significant stress or tension today.'},
    'Anxious': {'icon': Icons.wb_twilight_rounded, 'color': Colors.amber, 'insight': 'There are signs of apprehension or unease.'},
    'Sad': {'icon': Icons.sentiment_dissatisfied_rounded, 'color': Colors.blue, 'insight': 'You seem to be feeling a bit down or heavy-hearted.'},
    'Angry': {'icon': Icons.whatshot_rounded, 'color': Colors.red, 'insight': 'You are experiencing frustration or anger.'},
    'Lonely': {'icon': Icons.person_pin_circle_rounded, 'color': Colors.indigo, 'insight': 'You are experiencing feelings of isolation.'},
    'Tired': {'icon': Icons.nights_stay_rounded, 'color': Colors.grey, 'insight': 'Your energy levels appear depleted or low.'},
  };

  void _logMood() {
    if (_selectedMood == null) return;
    
    final info = _moods[_selectedMood]!;
    final moodName = _selectedMood!;
    final color = info['color'] as Color;
    final baseInsight = info['insight'] as String;
    
    final newResult = EmotionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emotionName: '$moodName ($_selectedIntensity)',
      confidence: _selectedIntensity == 'High' ? 0.95 : (_selectedIntensity == 'Medium' ? 0.75 : 0.50),
      insight: 'Manually Logged: $baseInsight Intensity is $_selectedIntensity.',
      timestamp: DateTime.now(),
      suggestions: [
        'Practice a reflection journal exercise for $moodName.',
        'Consider chatting with DeepHeal AI to process these thoughts.'
      ],
      color: color,
    );

    ref.read(emotionHistoryProvider.notifier).addResult(newResult);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully logged mood: $moodName ($_selectedIntensity)'),
        backgroundColor: color,
      ),
    );

    setState(() {
      _selectedMood = null;
      _selectedIntensity = 'Medium';
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationEnabled = ref.watch(notificationsEnabledProvider);
    final history = ref.watch(emotionHistoryProvider);
    
    // Check if user has logged mood today
    final hasLoggedToday = history.any((element) {
      final diff = DateTime.now().difference(element.timestamp).inDays;
      return diff == 0 && element.timestamp.day == DateTime.now().day;
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              if (notificationEnabled && !hasLoggedToday) ...[
                _buildCheckInReminder(),
                const SizedBox(height: 20),
              ],
              _buildManualMoodSelector(),
              const SizedBox(height: 30),
              _buildMoodTracker(context),
              const SizedBox(height: 30),
              _buildQuickActions(context),
              const SizedBox(height: 30),
              _buildFeedbackSummary(context),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        label: const Text('Chat with AI'),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 1.seconds, duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = ref.watch(authProvider);
    final firstName = (user?.name ?? 'there').split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              firstName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              (user?.name ?? 'U').isNotEmpty ? (user?.name ?? 'U')[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }


  Widget _buildCheckInReminder() {
    return GlassCard(
      color: AppColors.primary.withOpacity(0.08),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Check-in Reminder',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                SizedBox(height: 4),
                Text(
                  'You haven\'t logged your mood today. Track it now below!',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shake(delay: 1.seconds);
  }

  Widget _buildManualMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling right now?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Horizontal Mood List
              SizedBox(
                height: 75,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _moods.entries.map((entry) {
                    final isSelected = _selectedMood == entry.key;
                    final info = entry.value;
                    final color = info['color'] as Color;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = entry.key),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 65,
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(info['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? color : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Intensity Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Intensity:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Row(
                    children: ['Low', 'Medium', 'High'].map((intensity) {
                      final isSelected = _selectedIntensity == intensity;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(intensity),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedIntensity = intensity);
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Log Current Mood',
                onPressed: _selectedMood != null ? _logMood : null,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildMoodTracker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Mood Trend',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const GlassCard(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: MoodChart(),
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analyze Emotion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Text',
                icon: Icons.text_fields_rounded,
                color: AppColors.primary,
                onTap: () => context.push('/emotion-analysis'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Voice',
                icon: Icons.mic_none_rounded,
                color: AppColors.teal,
                onTap: () => context.push('/emotion-analysis'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Face',
                icon: Icons.face_retouching_natural_rounded,
                color: AppColors.purple,
                onTap: () => context.push('/emotion-analysis'),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildFeedbackSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Feedback Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const FeedbackSummaryCard(
          insight: 'Your anxiety levels have decreased by 15% this week. Keep practicing those breathing exercises!',
          suggestion: 'Try a 5-minute journaling session tonight.',
        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }
}

