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
      duration: const Duration(milliseconds: 3000), // Slower, smoother 3s duration
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic), // More fluid curve
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
    final textColor = isDark ? const Color(0xFFE5D9C7) : AppColors.primary;

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
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      // Micro-feathering (1.5%) for smoothness without ghosting
                      final double maskVal = _animation.value;
                      final double featherEn = (maskVal + 0.015).clamp(0.0, 1.0);
                      
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
                  child: Padding(
                    // Padding is CRITICAL to prevent clipping of font swashes
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      'Our Home is your Home',
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
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
