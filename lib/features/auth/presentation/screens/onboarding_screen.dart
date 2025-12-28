import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/theme/moroccan_decorations.dart';
import 'package:darna/core/widgets/premium_button.dart';
import 'package:darna/core/constants/app_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Authentic Moroccan Flavors',
      description: 'Experience the rich taste of Tagines, Couscous, and Pastillas prepared with traditional recipes.',
      icon: Icons.star_rate_rounded, // Replaced with Moroccan Star as requested
      image: 'assets/images/onboarding/onboarding_1.png', 
    ),
    OnboardingPage(
      title: 'Premium Delivery',
      description: 'Track your order in real-time. From our kitchen to your doorstep, freshness guaranteed.',
      icon: Icons.delivery_dining, // Replaced with Delivery Man icon
      image: 'assets/images/onboarding/onboarding_2.png',
    ),
    OnboardingPage(
      title: 'Rewards & Offers',
      description: 'Join the Darna family and enjoy exclusive rewards, discounts, and personalized offers.',
      icon: AppIcons.gift,
      image: 'assets/images/onboarding/onboarding_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    } else {
      context.go('/auth/login');
    }
  }

  void _skip() {
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.03, // Subtle pattern
              child: Image.asset(
                'assets/images/patterns/moroccan_pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (_, __, ___) => Container(), // Fallback
              ),
            ),
          ),
          
          // Decorative Circles (Glassmorphic blobs) // Simplified
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.deepTeal,
                      ),
                      child: Text(
                        'Skip',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.brightness == Brightness.dark 
                            ? Colors.white 
                            : AppColors.deepTeal,
                        fontWeight: FontWeight.w600,
                      ),
                      ),
                    ),
                  ),
                ),
                
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], theme);
                    },
                  ),
                ),
                
                // Bottom Area
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                          activeDotColor: AppColors.primary,
                          dotColor: AppColors.primary.withOpacity(0.2),
                          spacing: 8,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Next/Get Started button
                      PremiumButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        onPressed: _nextPage,
                        icon: _currentPage == _pages.length - 1 ? AppIcons.arrowRight : null,
                        width: double.infinity,
                      ).animate(target: _currentPage == _pages.length - 1 ? 1 : 0)
                       .shimmer(duration: 2.seconds, delay: 1.seconds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon illustration with circle
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: AppColors.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms),
          
          const SizedBox(height: 64),
          
          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark 
                  ? Colors.white 
                  : AppColors.charcoal,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0, delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.brightness == Brightness.dark 
                  ? Colors.white70 
                  : AppColors.slate,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, delay: 400.ms),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.image,
  });
}
