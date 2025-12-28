import 'package:darna/features/auth/domain/entities/app_user.dart';

/// Service to check user permissions for various features
class PermissionService {
  /// Check if user can place orders
  static bool canPlaceOrder(AppUser? user) {
    return user != null && !user.isGuest;
  }

  /// Check if user can view order history
  static bool canViewOrders(AppUser? user) {
    return user != null && !user.isGuest;
  }

  /// Check if user can access profile
  static bool canAccessProfile(AppUser? user) {
    return user != null && !user.isGuest;
  }

  /// Check if user can save favorites
  static bool canSaveFavorites(AppUser? user) {
    return user != null && !user.isGuest;
  }

  /// Check if user can save delivery addresses
  static bool canSaveAddresses(AppUser? user) {
    return user != null && !user.isGuest;
  }

  /// Check if user can add items to cart (guests can do this)
  static bool canAddToCart(AppUser? user) {
    return true; // Everyone can add to cart
  }

  /// Check if user is a guest
  static bool isGuest(AppUser? user) {
    return user?.isGuest ?? false;
  }

  /// Check if user is authenticated (not guest)
  static bool isAuthenticated(AppUser? user) {
    return user != null && !user.isGuest;
  }
}
