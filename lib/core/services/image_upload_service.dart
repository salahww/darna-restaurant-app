import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service to upload profile images to Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image and return the download URL
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
    required String folder, // 'customers' or 'drivers'
  }) async {
    try {
      // Create a unique filename
      final fileName = 'profile_$userId.jpg';
      final path = 'profiles/$folder/$fileName';

      // Upload the file
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      debugPrint('✅ Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage({
    required String userId,
    required String folder,
  }) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final path = 'profiles/$folder/$fileName';
      
      final ref = _storage.ref().child(path);
      await ref.delete();
      
      debugPrint('✅ Image deleted');
    } catch (e) {
      debugPrint('⚠️ Error deleting image: $e');
      // Don't throw - file might not exist
    }
  }
}
