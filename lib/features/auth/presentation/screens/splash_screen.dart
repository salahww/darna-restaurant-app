import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/core/widgets/darna_logo.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Splash screen that shows the Darna logo and checks authentication state
/// Automatically navigates to Home if logged in, or Onboarding if not
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // User is logged in -> Navigate to Home
      if (mounted) {
        context.go('/');
      }
    } else {
      // User is not logged in -> Navigate to Onboarding
      if (mounted) {
        context.go('/auth/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade-in animation
            const DarnaLogo(height: 180)
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
            
            const SizedBox(height: 24),
            
            Text(
              'Our Home is your Home',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : AppColors.primary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
