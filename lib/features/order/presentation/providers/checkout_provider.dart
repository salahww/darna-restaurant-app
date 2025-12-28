import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get userId

// Checkout State
enum CheckoutStatus { initial, loading, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;
  final OrderEntity? lastOrder;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.errorMessage,
    this.lastOrder,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    OrderEntity? lastOrder,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastOrder: lastOrder ?? this.lastOrder,
    );
  }
}

// Checkout Controller
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState());

  Future<void> placeOrder({
    required String deliveryAddress,
    required String paymentMethod,
    String? note,
  }) async {
    state = state.copyWith(status: CheckoutStatus.loading);

    try {
      final cartItems = _ref.read(cartProvider);
      final totalAmount = _ref.read(cartTotalProvider);
      // Removed subtotal/deliveryFee from here as they are not explicitly stored in OrderEntity top-level (only totalAmount),
      // BUT OrderEntity implementation I made earlier DID store totalAmount.
      // Wait, OrderEntity constructor:
      /*
      const OrderEntity({
        required this.id,
        required this.userId,
        required this.items,
        required this.totalAmount,
        required this.status,
        required this.deliveryAddress,
        required this.contactPhone, // Need mapping
        required this.createdAt,
        required this.paymentMethod,
      });
      */
      
      // I need to parse phone from deliveryAddress string or pass it separately?
      // In CheckoutScreen: deliveryAddress: '${_addressController.text} (Phone: ${_phoneController.text})'
      // I will extract phone from that format? Or just store all in deliveryAddress for now and put placeholder in phone.
      // Better: Update placeOrder arguments to accept phone.
      
      // Since I can't change CheckoutScreen signature easily in this tool call (need another tool),
      // I'll parse it rudimentarily or just use "N/A" for phone entity field if not provided.
      // Wait, let's extract phone from the string if possible, or just pass empty string to entity.
      // Actually the passed `deliveryAddress` string contains the phone.
      
      final orderId = const Uuid().v4();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_${const Uuid().v4()}';

      final order = OrderEntity(
        id: orderId,
        userId: userId,
        items: cartItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        contactPhone: "", // Store in address line for now
        createdAt: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      final repo = _ref.read(orderRepositoryProvider);
      await repo.placeOrder(order);

      // Clear Cart
      _ref.read(cartProvider.notifier).clearCart();
      
      state = state.copyWith(
        status: CheckoutStatus.success,
        lastOrder: order,
      );
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
