import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/auth/domain/entities/app_user.dart';

/// Service for admin authentication and role management
class AdminAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user with role
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        debugPrint('⚠️ User document does not exist for ${firebaseUser.email}');
        // Create default customer user if doesn't exist
        final newUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          role: UserRole.customer,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
        return newUser;
      }

      final userData = userDoc.data()!;
      debugPrint('📄 User document data: $userData');
      debugPrint('👤 Role from Firestore: ${userData['role']}');
      
      final user = AppUser.fromJson(userData);
      debugPrint('✅ Parsed user role: ${user.role.name}');
      
      return user;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  /// Check if current user is driver
  Future<bool> isDriver() async {
    final user = await getCurrentUser();
    return user?.isDriver ?? false;
  }

  /// Create admin user (for initial setup)
  /// This should be called from a secure admin panel or script
  Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Firestore user document with admin role
      final adminUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone ?? '',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(adminUser.toJson());

      debugPrint('Admin user created successfully: $email');
    } catch (e) {
      debugPrint('Error creating admin user: $e');
      rethrow;
    }
  }

  /// Create driver user
  Future<void> createDriverUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    String vehicleType = 'motorcycle',
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Firestore user document with driver role
      final driverUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: UserRole.driver,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(driverUser.toJson());

      // Also create driver profile
      await _firestore.collection('drivers').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'isAvailable': false,
        'currentLocation': null,
        'activeOrderId': null,
        'rating': 5.0,
        'totalDeliveries': 0,
      });

      debugPrint('Driver user created successfully: $email');
    } catch (e) {
      debugPrint('Error creating driver user: $e');
      rethrow;
    }
  }

  /// Create customer user (for testing)
  Future<void> createCustomerUser({
    required String email,
    required String password,
    String name = 'Test Client',
    String phone = '',
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Firestore user document with customer role
      final customerUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(customerUser.toJson());

      debugPrint('Customer user created successfully: $email');
    } catch (e) {
      debugPrint('Error creating customer user: $e');
      rethrow;
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.name,
      });
      debugPrint('User role updated: $userId -> ${newRole.name}');
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }
}


