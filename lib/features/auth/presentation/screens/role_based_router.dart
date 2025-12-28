import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:darna/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:darna/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:darna/features/auth/domain/entities/app_user.dart';
import 'package:darna/features/delivery/presentation/screens/driver_dashboard_screen.dart';

/// Role-based router that directs users to appropriate screens
class RoleBasedRouter extends ConsumerWidget {
  const RoleBasedRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          debugPrint('RoleBasedRouter: No user logged in');
          // No user logged in, show customer app
          return const MainNavigationScreen();
        }

        debugPrint('RoleBasedRouter: User logged in - ${user.email}, Role: ${user.role.name}');

        // Route based on role
        switch (user.role) {
          case UserRole.admin:
            debugPrint('RoleBasedRouter: Showing Admin Dashboard');
            return const AdminDashboardScreen();
          case UserRole.driver:
            debugPrint('RoleBasedRouter: Showing Driver Dashboard');
            return const DriverDashboardScreen();
          case UserRole.guest:
            debugPrint('RoleBasedRouter: Showing Guest (Customer) App');
            return const MainNavigationScreen();
          case UserRole.customer:
          default:
            debugPrint('RoleBasedRouter: Showing Customer App');
            return const MainNavigationScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // On error, default to customer app
        debugPrint('Role router error: $error');
        return const MainNavigationScreen();
      },
    );
  }
}

/// Placeholder screen for features coming soon
class _ComingSoonScreen extends StatelessWidget {
  final String role;

  const _ComingSoonScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$role Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon in Phase 2',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}


