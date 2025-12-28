import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/admin/data/services/admin_auth_service.dart';
import 'package:darna/features/auth/domain/entities/app_user.dart';

/// Provider for admin auth service
final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService();
});

/// Stream provider for current user
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(adminAuthServiceProvider);
  
  return authService.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }
    return await authService.getCurrentUser();
  });
});

/// Provider to check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(adminAuthServiceProvider);
  return await authService.isAdmin();
});

/// Provider to check if current user is driver
final isDriverProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(adminAuthServiceProvider);
  return await authService.isDriver();
});
