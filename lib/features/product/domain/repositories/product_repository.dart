import 'package:darna/core/utils/either_extension.dart';
import '../entities/product.dart';

/// Abstract repository for product operations
abstract class ProductRepository {
  /// Get all products
  FutureEither<List<Product>> getProducts();

  /// Get products by category
  FutureEither<List<Product>> getProductsByCategory(String categoryId);

  /// Get single product by ID
  FutureEither<Product> getProductById(String productId);

  /// Search products by name or description
  FutureEither<List<Product>> searchProducts(String query);

  /// Listen to products stream (real-time updates)
  Stream<List<Product>> watchProducts();

  /// Listen to products by category stream
  Stream<List<Product>> watchProductsByCategory(String categoryId);

  // ==========  ADMIN OPERATIONS ==========

  /// Create new product (admin only)
  FutureEither<Product> createProduct(Product product);

  /// Update existing product (admin only)
  FutureEither<Product> updateProduct(Product product);

  /// Delete product (admin only)
  FutureEither<void> deleteProduct(String productId);

  /// Upload product image to storage (admin only)
  FutureEither<String> uploadProductImage({
    required String productId,
    required String imagePath,
  });
}
