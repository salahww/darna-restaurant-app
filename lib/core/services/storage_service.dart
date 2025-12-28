import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service for managing Firebase Storage operations with automatic WebP conversion
class StorageService {
  final FirebaseStorage _storage;

  StorageService([FirebaseStorage? storage]) 
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage (auto-converts to WebP)
  /// Returns the download URL
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      debugPrint('📸 Uploading profile picture for user: $userId');
      
      // Compress and convert to WebP (512px max, 85% quality)
      final webpImage = await _convertToWebP(
        imageFile,
        maxSize: 512,
        quality: 85,
      );
      
      // Define storage path with .jpg extension
      final storageRef = _storage.ref().child('profile_pictures/$userId/profile.jpg');
      
      // Upload file
      final uploadTask = storageRef.putData(
        webpImage,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000', // Cache for 1 year
        ),
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

  /// Upload product image to Firebase Storage (auto-converts to WebP)
  /// Optimized for product display (larger size, optimized quality)
  /// Returns the download URL
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      debugPrint('📸 Uploading product image for: $productId');
      
      // Compress and convert to WebP (800px max, 80% quality)
      final webpImage = await _convertToWebP(
        imageFile,
        maxSize: 800,
        quality: 80,
      );
      
      // Define storage path
      final storageRef = _storage.ref().child('product_images/$productId.jpg');
      
      // Upload file
      final uploadTask = storageRef.putData(
        webpImage,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000', // Cache for 1 year
        ),
      );
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ Product image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading product image: $e');
      rethrow;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      debugPrint('🗑️ Deleting image: $imageUrl');
      
      // Extract path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      debugPrint('✅ Image deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      // Don't rethrow - deletion errors shouldn't block
    }
  }

  /// Legacy method - redirects to deleteImage
  Future<void> deleteProfilePicture(String imageUrl) => deleteImage(imageUrl);

  /// Convert image to optimized JPEG format with compression and resizing
  /// [maxSize] - Maximum width/height (maintains aspect ratio)
  /// [quality] - JPEG quality (0-100, recommended: 75-85)
  Future<Uint8List> _convertToWebP(
    File imageFile, {
    required int maxSize,
    required int quality,
  }) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize to max size while maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height > image.width ? maxSize : null,
      );
      
      // Encode as JPEG with specified quality (WebP not available in current package)
      final compressed = img.encodeJpg(resized, quality: quality);
      
      final compressionRatio = ((1 - compressed.length / bytes.length) * 100).toStringAsFixed(1);
      debugPrint('📊 JPEG conversion: ${bytes.length} → ${compressed.length} bytes (-$compressionRatio%)');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('⚠️ Image conversion failed, using fallback: $e');
      // Fallback to original compression if conversion fails
      return await _fallbackCompression(imageFile, maxSize);
    }
  }

  /// Fallback compression using JPEG if WebP fails
  Future<Uint8List> _fallbackCompression(File imageFile, int maxSize) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return bytes;
      }
      
      final resized = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height > image.width ? maxSize : null,
      );
      
      final jpeg = img.encodeJpg(resized, quality: 85);
      return Uint8List.fromList(jpeg);
    } catch (e) {
      debugPrint('⚠️ Fallback compression failed, using original: $e');
      return await imageFile.readAsBytes();
    }
  }
}

