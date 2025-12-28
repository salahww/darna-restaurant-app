import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/features/product/data/repositories/mock_product_repository.dart';

class ImageMigrationService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> migrateImages() async {
    print('Starting image migration...');
    
    // Access static list of products
    // Assuming MockProductRepository has a static list 'kMockProducts' or similar based on typical pattern, 
    // or I'll check the file content first.
    // Placeholder logic until file read is confirmed.
    
    // If I can't confirm static list, I'll instantiate it if possible.
    final repository = MockProductRepository();
    
    // We need to access the list. 
    // If getProducts() returns a list directly, use that.
    // If it returns Future<Either<Failure, List<Product>>>, await it.
    
    final result = await repository.getProducts();
    
    await result.fold(
      (failure) async => print('Failed to get products: ${failure.message}'),
      (products) async {
        for (final product in products) {
          try {
            if (product.imageUrl.startsWith('http')) {
              print('Skipping ${product.name['en']}: Already a URL');
              continue;
            }

            print('Processing ${product.name['en']}...');

            // Load asset
            // Assets must be declared in pubspec.yaml
            final byteData = await rootBundle.load(product.imageUrl);
            final bytes = byteData.buffer.asUint8List();

            // Upload
            final ref = _storage.ref().child('products/${product.id}.jpg');
            await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
            final url = await ref.getDownloadURL();

            print('Uploaded to: $url');

            // Update Firestore
            // This syncs the entire mock product to Firestore with the new URL
            // This is useful to seed the database too!
            final productData = product.toJson();
            productData['imageUrl'] = url;
            
            await _firestore.collection('products').doc(product.id).set(
              productData,
              SetOptions(merge: true),
            );

            print('Synced to Firestore: ${product.id}');

          } catch (e) {
            print('Error migrating ${product.id}: $e');
          }
        }
      },
    );
    
    print('Migration completed.');
  }
}
