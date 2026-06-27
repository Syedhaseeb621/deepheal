import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../data/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJsonString = prefs.getString('registered_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJsonString);

      // 1. Check if email is in our database
      final emailExists = usersList.any((u) => u['email'] == email);
      if (!emailExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is not found in our database.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Validate password
      final userMap = usersList.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (userMap != null) {
        final loggedInUser = UserModel(
          id: userMap['id'],
          name: userMap['name'] ?? 'Sarah Mitchell',
          email: userMap['email'],
          mood: 'Calm',
        );

        ref.read(authProvider.notifier).setUser(loggedInUser);
        await prefs.setString('logged_in_user_id', userMap['id']);

        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password. Please try again.')),
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJsonString = prefs.getString('registered_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJsonString);

      // Check if email already registered
      final exists = usersList.any((u) => u['email'] == email);
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User with this email already exists.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Add new user to the frontend array
      final newUser = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'password': password,
      };
      usersList.add(newUser);

      await prefs.setString('registered_users', jsonEncode(usersList));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please sign in.')),
        );
        setState(() {
          _isSignUp = false;
          _isLoading = false;
          _emailController.text = email;
          _passwordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.favorite_rounded, size: 50, color: AppColors.primary)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              _isSignUp ? 'Create Account' : 'Welcome back!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              _isSignUp
                  ? 'Join DeepHeal and start your mental wellness journey.'
                  : 'Sign in to continue your mental wellness journey.',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: 48),
            if (_isSignUp) ...[
              AppTextField(
                hintText: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
            ],
            AppTextField(
              hintText: 'Email Address',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
            AppTextField(
              hintText: 'Password',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            if (!_isSignUp)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),
            const SizedBox(height: 40),
            AppButton(
              text: _isSignUp ? 'Sign Up' : 'Sign In',
              isLoading: _isLoading,
              onPressed: _isSignUp ? _handleSignUp : _handleLogin,
            ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_isSignUp ? "Already have an account? " : "Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}

