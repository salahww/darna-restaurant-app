import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/cart/domain/entities/cart_item.dart';
import 'package:darna/features/product/domain/entities/product.dart';

/// Cart state notifier for managing shopping cart
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// Add a product to cart or increment quantity if already exists with same options
  void addToCart({
    required Product product,
    required String portionSize,
    required String spiceLevel,
    required List<String> addons,
    int quantity = 1,
  }) {
    // Check if item with exact same options already exists
    final existingIndex = state.indexWhere((item) =>
        item.product.id == product.id &&
        item.portionSize == portionSize &&
        item.spiceLevel == spiceLevel &&
        _listEquals(item.addons, addons));

    if (existingIndex != -1) {
      // Increment quantity
      final updatedItem = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + quantity,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        portionSize: portionSize,
        spiceLevel: spiceLevel,
        addons: addons,
      );
      state = [...state, newItem];
    }
  }

  /// Remove item from cart completely
  void removeFromCart(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  /// Increment item quantity
  void incrementQuantity(String itemId) {
    final index = state.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final updatedItem = state[index].copyWith(
        quantity: state[index].quantity + 1,
      );
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  /// Decrement item quantity (remove if quantity becomes 0)
  void decrementQuantity(String itemId) {
    final index = state.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final currentQuantity = state[index].quantity;
      if (currentQuantity > 1) {
        final updatedItem = state[index].copyWith(
          quantity: currentQuantity - 1,
        );
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      } else {
        removeFromCart(itemId);
      }
    }
  }

  /// Update cart item options
  void updateCartItem(String itemId, {
    String? portionSize,
    String? spiceLevel,
    List<String>? addons,
  }) {
    final index = state.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final updatedItem = state[index].copyWith(
        portionSize: portionSize,
        spiceLevel: spiceLevel,
        addons: addons,
      );
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  /// Clear all items from cart
  void clearCart() {
    state = [];
  }

  /// Get total number of items (sum of all quantities)
  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get cart subtotal
  double get subtotal {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Get delivery fee (free for orders > 200 MAD)
  double get deliveryFee {
    return subtotal > 200 ? 0.0 : 15.0;
  }

  /// Get total (subtotal + delivery)
  double get total {
    return subtotal + deliveryFee;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Derived providers for easy access
final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  // Assuming item.subtotal handles quantity * price + addons
  return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartDeliveryFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal > 200 ? 0.0 : 15.0;
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final delivery = ref.watch(cartDeliveryFeeProvider);
  return subtotal + delivery;
});
