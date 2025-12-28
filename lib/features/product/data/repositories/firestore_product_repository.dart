import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:darna/core/utils/either_extension.dart';
import 'package:darna/core/error/failures.dart';
import 'package:darna/core/error/exceptions.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import 'package:darna/core/constants/app_constants.dart';

class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository(this._firestore);

  @override
  FutureEither<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.productsCollection).get();
      final products = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
      return Right(products);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      if (categoryId == 'All') return getProducts();
      
      final snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .get();
          
      final products = snapshot.docs.map((doc) => _productFromDoc(doc)).toList();
      return Right(products);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  FutureEither<Product> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();
          
      if (!doc.exists) {
        return const Left(FirestoreFailure('Product not found'));
      }
      
      return Right(_productFromDoc(doc));
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _firestore.collection(AppConstants.productsCollection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => _productFromDoc(doc)).toList(),
    );
  }

  @override
  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    if (categoryId == 'All') return watchProducts();
    
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _productFromDoc(doc)).toList());
  }

  @override
  FutureEither<List<Product>> searchProducts(String query) async {
    // Note: Firestore basic search is limited. Ideally use Algolia or client-side filtering.
    // Implementing client-side filtering for simplicity on small datasets
    try {
      final snapshot = await _firestore.collection(AppConstants.productsCollection).get();
      final products = snapshot.docs
          .map((doc) => _productFromDoc(doc))
          .where((p) => 
            p.name.toLowerCase().contains(query.toLowerCase()) || 
            p.description.toLowerCase().contains(query.toLowerCase())
          ).toList();
      return Right(products);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  // Admin Methods
  @override
  FutureEither<Product> createProduct(Product product) async {
    try {
      // Create a reference with auto-ID if not provided
      final docRef = product.id.isEmpty 
          ? _firestore.collection(AppConstants.productsCollection).doc()
          : _firestore.collection(AppConstants.productsCollection).doc(product.id);
          
      final productWithId = product.copyWith(id: docRef.id);
      await docRef.set(_productToMap(productWithId));
      return Right(productWithId);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  FutureEither<Product> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(_productToMap(product));
      return Right(product);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  FutureEither<String> uploadProductImage({required String productId, required String imagePath}) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('products/$productId.jpg');
      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();
      return Right(url);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  // Helper Methods
  Product _productFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      nameFr: data['nameFr'] ?? '',
      description: data['description'] ?? '',
      descriptionFr: data['descriptionFr'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      isMoroccanSpecialty: data['isMoroccanSpecialty'] ?? true,
      calories: data['calories'] ?? 0,
      preparationTime: data['preparationTime'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      // Handle lists safely
      ingredients: List<String>.from(data['ingredients'] ?? []),
      allergens: List<String>.from(data['allergens'] ?? []),
    );
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'name': product.name,
      'nameFr': product.nameFr,
      'description': product.description,
      'descriptionFr': product.descriptionFr,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'categoryId': product.categoryId,
      'isMoroccanSpecialty': product.isMoroccanSpecialty,
      'calories': product.calories,
      'preparationTime': product.preparationTime,
      'rating': product.rating,
      'isAvailable': product.isAvailable,
      'ingredients': product.ingredients,
      'allergens': product.allergens,
    };
  }
}
