import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/core/widgets/darna_logo.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Splash screen that shows the Darna logo and checks authentication state
/// Automatically navigates to Home if logged in, or Onboarding if not
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });

    // Start delay to allow logo to fade in first
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    
    // Brief pause after animation for readability
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (user != null) {
      if (mounted) context.go('/');
    } else {
      if (mounted) context.go('/auth/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primary;

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
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Ensure nothing is visible at absolute zero
                  if (_animation.value == 0.0) {
                    return const SizedBox.shrink(); 
                  }
                  
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      // Sharp edge to prevent ghosting (0.01 feathering)
                      final double maskVal = _animation.value;
                      final double featherEn = (maskVal + 0.01).clamp(0.0, 1.0);
                      
                      return LinearGradient(
                        colors: [textColor, textColor, Colors.transparent, Colors.transparent],
                        stops: [
                          0.0,
                          maskVal,
                          featherEn,
                          1.0,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: child,
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Our Home is your Home',
                    // Use a slightly larger height to prevent clipping of handwritten ascenders/descenders
                    strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.5),
                    style: GoogleFonts.playwriteUsTrad(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            // Moroccan Star (Red)
            const Icon(
              Icons.star_rate_rounded, // Using rounded star for a softer premium look
              color: AppColors.primary,
              size: 32,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .fadeIn(duration: 600.ms)
             .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1500.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }
}
