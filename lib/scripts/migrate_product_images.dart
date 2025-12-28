import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

/// Script to migrate product images from local assets to Firebase Storage
/// with compression for faster loading
void main() async {
  print('🚀 Starting product images migration...');
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  
  // Define the assets directory path
  final assetsDir = Directory('assets/images/products');
  
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory not found: ${assetsDir.path}');
    return;
  }
  
  print('📁 Found assets directory: ${assetsDir.path}');
  
  // Get all image files
  final imageFiles = assetsDir
      .listSync()
      .where((file) => file.path.endsWith('.png') || file.path.endsWith('.jpg'))
      .toList();
  
  print('📸 Found ${imageFiles.length} images to migrate');
  
  int successCount = 0;
  int errorCount = 0;
  
  for (var file in imageFiles) {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final productName = fileName.replaceAll('.png', '').replaceAll('.jpg', '');
      
      print('\n📤 Processing: $fileName');
      
      // Read and compress image
      final imageBytes = await File(file.path).readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        print('⚠️ Failed to decode: $fileName');
        errorCount++;
        continue;
      }
      
      // Resize to max 800px width (maintains aspect ratio)
      final resized = img.copyResize(
        image,
        width: image.width > 800 ? 800 : image.width,
      );
      
      // Encode as WebP with 80% quality (best balance)
      final compressedBytes = img.encodeWebP(resized, quality: 80);
      
      print('   📊 Original: ${imageBytes.length} bytes');
      print('   📊 Compressed: ${compressedBytes.length} bytes');
      print('   💾 Saved: ${((1 - compressedBytes.length / imageBytes.length) * 100).toStringAsFixed(1)}%');
      
      // Upload to Firebase Storage
      final storageRef = storage.ref().child('product_images/$productName.webp');
      
      await storageRef.putData(
        compressedBytes,
        SettableMetadata(
          contentType: 'image/webp',
          cacheControl: 'public, max-age=31536000', // Cache for 1 year
        ),
      );
      
      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      print('   ✅ Uploaded: $downloadUrl');
      
      // Update Firestore product with new URL
      // Find product by matching the old asset path
      final oldPath = 'assets/images/products/$fileName';
      final productsQuery = await firestore
          .collection('products')
          .where('imageUrl', isEqualTo: oldPath)
          .get();
      
      if (productsQuery.docs.isNotEmpty) {
        for (var doc in productsQuery.docs) {
          await doc.reference.update({'imageUrl': downloadUrl});
          print('   🔄 Updated Firestore: ${doc.id}');
        }
      } else {
        print('   ⚠️ No matching product found in Firestore');
      }
      
      successCount++;
      
    } catch (e) {
      print('   ❌ Error processing $file: $e');
      errorCount++;
    }
  }
  
  print('\n' + '=' * 50);
  print('✅ Migration complete!');
  print('   Success: $successCount');
  print('   Errors: $errorCount');
  print('=' * 50);
}
