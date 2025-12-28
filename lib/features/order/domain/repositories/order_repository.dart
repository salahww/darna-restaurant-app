import 'package:darna/features/order/domain/entities/order.dart';

abstract class OrderRepository {
  Future<String> placeOrder(OrderEntity order);
  Future<List<OrderEntity>> getUserOrders(String userId);
  Stream<List<OrderEntity>> watchUserOrders(String userId);
  Stream<OrderEntity> watchOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Stream<List<OrderEntity>> watchAllOrders(); // Admin only
}
