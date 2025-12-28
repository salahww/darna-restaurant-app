import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/delivery/domain/entities/driver.dart';

/// Provider for current driver profile
final currentDriverProfileProvider = StreamProvider<Driver?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('drivers')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return null;
    }
    
    // Get driver data from Firestore
    final driverData = snapshot.data()!;
    
    // Add email from Firebase Auth if not in Firestore
    if (!driverData.containsKey('email') || driverData['email'] == null || driverData['email'] == '') {
      driverData['email'] = user.email ?? '';
    }
    
    // Add default licensePlate if missing
    if (!driverData.containsKey('licensePlate') || driverData['licensePlate'] == null) {
      driverData['licensePlate'] = '';
    }
    
    return Driver.fromJson(driverData);
  });
});

/// Service to update driver profile
class DriverProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String vehicleType,
    required String licensePlate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('drivers').doc(user.uid).update({
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
    });

    // Also update Firebase Auth display name
    await user.updateDisplayName(name);
  }
}

final driverProfileServiceProvider = Provider<DriverProfileService>((ref) {
  return DriverProfileService();
});
