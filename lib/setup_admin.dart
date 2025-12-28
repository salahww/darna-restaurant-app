import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:darna/features/admin/data/services/admin_auth_service.dart';
import 'package:darna/features/delivery/data/repositories/firestore_driver_repository.dart';

/// Script to create admin and driver users for testing
/// Run this once to set up test accounts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final authService = AdminAuthService();
  
  print('Creating admin user...');
  try {
    await authService.createAdminUser(
      email: 'admin@darna.com',
      password: 'Admin123!',
      name: 'Restaurant Admin',
      phone: '+212600000001',
    );
    print('✅ Admin user created: admin@darna.com / Admin123!');
  } catch (e) {
    print('❌ Admin creation failed: $e');
  }
  
  print('\nCreating test driver...');
  try {
    await authService.createDriverUser(
      email: 'driver@darna.com',
      password: 'Driver123!',
      name: 'Ahmed El Fassi',
      phone: '+212600000002',
      vehicleType: 'motorcycle',
    );
    print('✅ Driver user created: driver@darna.com / Driver123!');
  } catch (e) {
    print('❌ Driver creation failed: $e');
  }
  
  print('\n✅ Setup complete!');
  print('\nTest Accounts:');
  print('Admin: admin@darna.com / Admin123!');
  print('Driver: driver@darna.com / Driver123!');

  print('\nCreating test client...');
  try {
    await authService.createCustomerUser(
      email: 'client@darna.com',
      password: 'Client123!',
      name: 'Test Client',
      phone: '+212600000003',
    );
    print('✅ Client user created: client@darna.com / Client123!');
  } catch (e) {
    print('❌ Client creation failed: $e');
  }

  print('Client: client@darna.com / Client123!');
}
