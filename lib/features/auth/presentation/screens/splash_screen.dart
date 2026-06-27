import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check if a user is already logged in
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('logged_in_user_id');

    if (mounted) {
      if (loggedInUserId != null && loggedInUserId.isNotEmpty) {
        context.go('/dashboard');
      } else {
        context.go('/onboarding');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.easeOutBack)
            .shimmer(delay: 1.seconds, duration: 1500.ms),
            const SizedBox(height: 24),
            const Text(
              'DeepHeal',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms)
            .slideY(begin: 0.5, end: 0),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Mental Wellness',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
