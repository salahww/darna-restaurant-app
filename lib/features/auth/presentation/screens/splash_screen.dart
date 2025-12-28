import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/core/widgets/darna_logo.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
    // Animation completion will trigger navigation
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    
    // Brief pause after animation for readability
    await Future.delayed(const Duration(milliseconds: 500));
    
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
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DefaultTextStyle(
                style: GoogleFonts.playwriteUsTrad(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : AppColors.primary,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Our Home is your Home',
                      speed: const Duration(milliseconds: 100),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  isRepeatingAnimation: false,
                  onFinished: _checkAuthAndNavigate,
                ),
              ),
            ),
            
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
