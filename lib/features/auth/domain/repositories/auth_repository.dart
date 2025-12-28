import 'package:darna/core/utils/either_extension.dart';
import '../entities/app_user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Get current logged-in user
  Future<AppUser?> getCurrentUser();

  /// Listen to authentication state changes
  Stream<AppUser?> get authStateChanges;

  /// Login with email and password
  FutureEither<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register new client user
  FutureEither<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  /// Logout current user
  FutureEither<void> logout();

  /// Update user profile
  FutureEither<AppUser> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? preferredLanguage,
  });

  /// Add product to favorites
  FutureEither<void> addToFavorites({
    required String userId,
    required String productId,
  });

  /// Remove product from favorites
  FutureEither<void> removeFromFavorites({
    required String userId,
    required String productId,
  });
}
