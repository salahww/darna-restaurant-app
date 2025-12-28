import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service for managing Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage;

  StorageService([FirebaseStorage? storage]) 
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      debugPrint('📸 Uploading profile picture for user: $userId');
      
      // Compress and resize image
      final compressedImage = await _compressImage(imageFile);
      
      // Define storage path
      final storageRef = _storage.ref().child('profile_pictures/$userId/profile.jpg');
      
      // Upload file
      final uploadTask = storageRef.putData(
        compressedImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Profile picture uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      debugPrint('🗑️ Deleting profile picture: $imageUrl');
      
      // Extract path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      debugPrint('✅ Profile picture deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting profile picture: $e');
      // Don't rethrow - deletion errors shouldn't block
    }
  }

  /// Compress and resize image to optimize storage
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize to max 512x512 while maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: image.width > image.height ? 512 : null,
        height: image.height > image.width ? 512 : null,
      );
      
      // Encode as JPEG with 85% quality
      final compressed = img.encodeJpg(resized, quality: 85);
      
      debugPrint('📊 Image compressed: ${bytes.length} → ${compressed.length} bytes');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('⚠️ Image compression failed, using original: $e');
      // Fallback to original if compression fails
      return await imageFile.readAsBytes();
    }
  }
}
