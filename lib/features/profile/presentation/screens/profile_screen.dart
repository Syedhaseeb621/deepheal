import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final totalSessions = ref.watch(therapyHistoryProvider).length;
    final history = ref.watch(emotionHistoryProvider);
    final latestMood = history.isNotEmpty ? history.first.emotionName.split(' ')[0] : 'Calm';

    // Simplified streak calculation: count consecutive days starting from today or yesterday
    int streak = 0;
    if (history.isNotEmpty) {
      final days = history.map((e) => DateUtils.dateOnly(e.timestamp)).toSet().toList();
      days.sort((a, b) => b.compareTo(a)); // Newest first
      
      final today = DateUtils.dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      
      if (days.contains(today) || days.contains(yesterday)) {
        streak = 1;
        DateTime currentDay = days.contains(today) ? today : yesterday;
        while (days.contains(currentDay.subtract(const Duration(days: 1)))) {
          streak++;
          currentDay = currentDay.subtract(const Duration(days: 1));
        }
      }
    }

    final user = ref.watch(authProvider);
    final userName = user?.name ?? 'User';
    final userEmail = user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(userName, userEmail),
              const SizedBox(height: 40),
              _buildStatsSection(totalSessions, streak, latestMood),
              const SizedBox(height: 40),
              _buildSettingsSection(context, ref, themeMode, notificationsEnabled),
              const SizedBox(height: 40),
              _buildLogoutButton(context, ref),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
            ),
          ],
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatsSection(int sessions, int streak, String mood) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Sessions', '$sessions', AppColors.primary)),
        Expanded(child: _buildStatItem('Streak', '$streak Days', AppColors.teal)),
        Expanded(child: _buildStatItem('Mood', mood, AppColors.purple)),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, ThemeMode themeMode, bool notificationsEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSettingTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          value: themeMode == ThemeMode.dark,
          onChanged: (val) {
            ref.read(themeProvider.notifier).toggleTheme(val);
          },
        ),
        _buildSettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          value: notificationsEnabled,
          onChanged: (val) {
            ref.read(notificationsEnabledProvider.notifier).toggleNotifications(val);
          },
        ),
        _buildActionTile(Icons.security_rounded, 'Privacy & Security'),
        _buildActionTile(Icons.help_outline_rounded, 'Help Center'),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        ref.read(chatProvider.notifier).clearHistory();
        if (context.mounted) context.go('/login');
      },
      child: const Text(
        'Logout',
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      ),
    );
  }
}

