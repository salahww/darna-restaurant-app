import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';
import 'package:darna/features/product/domain/entities/product.dart';

/// Provider for all orders (admin use)
final ordersProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchAllOrders();
});

/// Provider for all products (admin use)
final allProductsProvider = FutureProvider((ref) async {
  final productRepo = ref.watch(productRepositoryProvider);
  final result = await productRepo.getProducts();
  return result.fold(
    (failure) => <Product>[],
    (products) => products,
  );
});
