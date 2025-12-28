import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User profile data model
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? profilePictureUrl; // Changed from photoUrl to match AppUser
  final String role;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.profilePictureUrl,
    required this.role,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? data['photoUrl'], // Support legacy field
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      'role': role,
    };
  }
}

/// Provider for current user profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return null;
    }
    return UserProfile.fromFirestore(snapshot.data()!);
  });
});

/// Service to update user profile
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'phone': phone,
    });

    // Also update Firebase Auth display name
    await user.updateDisplayName(name);
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await user.updateEmail(newEmail);
    await _firestore.collection('users').doc(user.uid).update({
      'email': newEmail,
    });
  }
}

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});
