import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Analyze Your Emotions',
      description:
          'Use advanced AI to track your mood through text, voice, and facial expressions.',
      icon: Icons.psychology_rounded,
      color: AppColors.primary,
    ),
    OnboardingItem(
      title: 'Personalized Therapy',
      description:
          'Receive tailored suggestions for breathing, journaling, and meditation based on your mood.',
      icon: Icons.self_improvement_rounded,
      color: AppColors.teal,
    ),
    OnboardingItem(
      title: 'Stay Connected',
      description:
          'Chat with our AI companion anytime you need a listening ear or professional advice.',
      icon: Icons.chat_bubble_rounded,
      color: AppColors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Reserve fixed height for bottom controls: dots + button + skip + padding
            const double bottomControlsHeight = 180.0;
            final double contentHeight =
                constraints.maxHeight - bottomControlsHeight;

            return Column(
              children: [
                // ── Scrollable page content ──────────────────────────────────
                SizedBox(
                  height: contentHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _OnboardingPage(item: item);
                    },
                  ),
                ),

                // ── Fixed bottom controls ────────────────────────────────────
                SizedBox(
                  height: bottomControlsHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _items.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : AppColors.textDisabled,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppButton(
                          text: _currentPage == _items.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: () {
                            if (_currentPage < _items.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context.go('/login');
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        if (_currentPage < _items.length - 1)
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ── Single onboarding slide ─────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale icon circle based on available height so it never overflows
        final double iconSize = constraints.maxHeight < 320 ? 64 : 100;
        final double iconPadding = constraints.maxHeight < 320 ? 24 : 36;
        final double gapAfterIcon = constraints.maxHeight < 320 ? 24 : 48;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: iconSize, color: item.color),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  SizedBox(height: gapAfterIcon),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ── Data model ─────────────────────────────────────────────────────────────
class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
