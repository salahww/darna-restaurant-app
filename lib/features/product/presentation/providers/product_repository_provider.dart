import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/mock_product_repository.dart'; 

/// Provider for the ProductRepository
/// Switched to Mock Implementation for CAN 2025 features
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirestoreProductRepository(FirebaseFirestore.instance);
});
