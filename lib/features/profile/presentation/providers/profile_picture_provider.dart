import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/core/services/storage_service.dart';

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// State for profile picture upload
class ProfilePictureState {
  final bool isUploading;
  final double uploadProgress;
  final String? error;

  const ProfilePictureState({
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.error,
  });

  ProfilePictureState copyWith({
    bool? isUploading,
    double? uploadProgress,
    String? error,
  }) {
    return ProfilePictureState(
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
    );
  }
}

/// Notifier for managing profile picture uploads
class ProfilePictureNotifier extends StateNotifier<ProfilePictureState> {
  final StorageService _storageService;
  final FirebaseFirestore _firestore;
  final ImagePicker _picker = ImagePicker();

  ProfilePictureNotifier(this._storageService, this._firestore)
      : super(const ProfilePictureState());

  /// Pick and upload profile picture
  Future<String?> pickAndUploadImage(String userId, String? oldImageUrl) async {
    try {
      // Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        debugPrint('📸 Image picker cancelled');
        return null;
      }

      state = state.copyWith(isUploading: true, uploadProgress: 0.0);

      // Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await _storageService.deleteProfilePicture(oldImageUrl);
      }

      // Upload new image
      final downloadUrl = await _storageService.uploadProfilePicture(
        File(pickedFile.path),
        userId,
      );

      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePictureUrl': downloadUrl,
      });

      state = state.copyWith(isUploading: false, uploadProgress: 1.0);
      debugPrint('✅ Profile picture updated in Firestore');

      return downloadUrl;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload image: $e',
      );
      debugPrint('❌ Error in pickAndUploadImage: $e');
      return null;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String userId, String imageUrl) async {
    try {
      state = state.copyWith(isUploading: true);

      await _storageService.deleteProfilePicture(imageUrl);
      
      await _firestore.collection('users').doc(userId).update({
        'profilePictureUrl': null,
      });

      state = state.copyWith(isUploading: false);
      debugPrint('✅ Profile picture removed');
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to delete image: $e',
      );
      debugPrint('❌ Error deleting profile picture: $e');
    }
  }

  /// Reset error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for ProfilePictureNotifier
final profilePictureProvider =
    StateNotifierProvider<ProfilePictureNotifier, ProfilePictureState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ProfilePictureNotifier(storageService, FirebaseFirestore.instance);
});
