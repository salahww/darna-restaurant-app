import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to create new driver accounts
class DriverCreationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new driver account
  Future<String?> createDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    required String adminEmail,
    required String adminPassword,
  }) async {
    try {
      // 1. Create driver user in Firebase Auth (this signs in as driver)
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // 2. Update display name
      await userCredential.user!.updateDisplayName(name);

      // 3. Create driver document in Firestore
      await _firestore.collection('drivers').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'vehicleType': vehicleType.toLowerCase(),
        'licensePlate': licensePlate,
        'isAvailable': false,
        'currentLocation': null,
        'activeOrderId': null,
        'rating': 5.0,
        'totalDeliveries': 0,
        'fcmToken': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 4. Create user document with driver role
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'driver',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Sign out the driver
      await _auth.signOut();
      
      // 6. Sign the admin back in
      await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      print('✅ Driver created: $name ($email)');
      print('✅ Admin re-authenticated');
      return userId;
    } on FirebaseAuthException catch (e) {
      print('❌ Auth error creating driver: ${e.code}');
      
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email already in use');
        case 'weak-password':
          throw Exception('Password is too weak (min 6 characters)');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Error creating driver: ${e.message}');
      }
    } catch (e) {
      print('❌ Error creating driver: $e');
      throw Exception('Failed to create driver: $e');
    }
  }

  /// Get all drivers
  Stream<List<Map<String, dynamic>>> getAllDrivers() {
    return _firestore
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete driver (remove from Firestore and Auth)
  Future<void> deleteDriver(String driverId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('drivers').doc(driverId).delete();
      
      // Note: Deleting from Auth requires re-authentication
      // For production, use Cloud Functions to delete auth user
      print('✅ Driver deleted from Firestore: $driverId');
    } catch (e) {
      print('❌ Error deleting driver: $e');
      throw Exception('Failed to delete driver');
    }
  }
}
