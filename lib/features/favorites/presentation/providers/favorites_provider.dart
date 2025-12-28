import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favorites state notifier for managing favorite products with persistence
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  static const _favoritesKey = 'favorites';

  /// Load favorites from local storage
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
    state = Set<String>.from(favoritesList);
  }

  /// Save favorites to local storage
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, state.toList());
  }

  /// Toggle favorite status for a product
  void toggleFavorite(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _saveFavorites();
  }

  /// Check if a product is favorited
  bool isFavorite(String productId) {
    return state.contains(productId);
  }

  /// Get count of favorited items
  int get count => state.length;

  /// Clear all favorites
  void clearFavorites() {
    state = {};
    _saveFavorites();
  }
}

/// Favorites provider - stores product IDs
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

/// Provider to check if a specific product is favorited
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(productId);
});

/// Provider for favorites count
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.length;
});
