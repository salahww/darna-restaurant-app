import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/domain/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrderRepository(this._firestore);

  @override
  Future<String> placeOrder(OrderEntity order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
    return order.id;
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    final orders = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Ensure ID is used
      return OrderEntity.fromMap(data);
    }).toList();
    
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Stream<List<OrderEntity>> watchUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is used
            return OrderEntity.fromMap(data);
          }).toList();
          // Client-side sorting to avoid missing index errors
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  @override
  Stream<OrderEntity> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            data['id'] = doc.id; // Ensure ID is used
            return OrderEntity.fromMap(data);
          } else {
            throw Exception('Order not found');
          }
        });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }

  @override
  Stream<List<OrderEntity>> watchAllOrders() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is used
            return OrderEntity.fromMap(data);
          }).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }
}
