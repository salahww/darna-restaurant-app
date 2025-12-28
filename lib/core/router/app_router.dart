import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/auth/presentation/screens/splash_screen.dart';
import 'package:darna/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:darna/features/auth/presentation/screens/login_screen.dart';
import 'package:darna/features/auth/presentation/screens/signup_screen.dart';
import 'package:darna/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:darna/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:darna/features/cart/presentation/screens/cart_screen.dart';
import 'package:darna/features/auth/presentation/screens/role_based_router.dart';
import 'package:darna/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:darna/features/delivery/presentation/screens/driver_profile_screen.dart';
import 'package:darna/features/delivery/presentation/screens/edit_driver_profile_screen.dart';
import 'package:darna/features/settings/presentation/screens/settings_screen.dart';
import 'package:darna/features/profile/presentation/screens/profile_screen.dart';
import 'package:darna/features/admin/presentation/screens/driver_management_screen.dart';
import 'package:darna/features/admin/presentation/screens/add_driver_screen.dart';
import 'package:darna/core/router/page_transitions.dart';

/// App router configuration with authentication flow
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Auth Routes
    GoRoute(
      path: '/auth/onboarding',
      pageBuilder: (context, state) => PageTransitions.fadeScale(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/login',
      pageBuilder: (context, state) => PageTransitions.fadeScale(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/signup',
      pageBuilder: (context, state) => PageTransitions.fadeScale(
        key: state.pageKey,
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      pageBuilder: (context, state) => PageTransitions.fadeScale(
        key: state.pageKey,
        child: const ForgotPasswordScreen(),
      ),
    ),
    
    // Main App (Protected Route)
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleBasedRouter(),
    ),
    
    // Cart - Slide Up like a modal
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => PageTransitions.slideUp(
        key: state.pageKey,
        child: const CartScreen(),
      ),
    ),
    
    // Edit Profile
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const EditProfileScreen(),
      ),
    ),
    
    // Driver Profile
    GoRoute(
      path: '/driver/profile',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const DriverProfileScreen(),
      ),
    ),
    
    // Edit Driver Profile
    GoRoute(
      path: '/driver/edit-profile',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const EditDriverProfileScreen(),
      ),
    ),
    
    // Settings
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    
    // Profile
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const ProfileScreen(),
      ),
    ),
    
    // Admin - Driver Management
    GoRoute(
      path: '/admin/drivers',
      pageBuilder: (context, state) => PageTransitions.slideRight(
        key: state.pageKey,
        child: const DriverManagementScreen(),
      ),
    ),
    
    // Admin - Add Driver
    GoRoute(
      path: '/admin/add-driver',
      pageBuilder: (context, state) => PageTransitions.slideUp(
        key: state.pageKey,
        child: const AddDriverScreen(),
      ),
    ),
  ],
  
  // Redirect logic is handled in SplashScreen
  // to avoid complexity here
);
