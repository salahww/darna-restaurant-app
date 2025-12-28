import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/domain/repositories/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/features/order/data/repositories/firestore_order_repository.dart';

// Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository(FirebaseFirestore.instance);
});

// Stream Single Order Provider
final orderStreamProvider = StreamProvider.family<OrderEntity, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrder(orderId);
});
