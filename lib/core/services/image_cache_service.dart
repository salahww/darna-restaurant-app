import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Service to pre-cache product images for instant loading
class ImageCacheService {
  /// Pre-cache a list of image URLs
  /// This downloads images in the background and stores them in cache
  static Future<void> precacheImages(
    BuildContext context,
    List<String> imageUrls, {
    VoidCallback? onComplete,
  }) async {
    debugPrint('🖼️ Pre-caching ${imageUrls.length} images...');
    
    int cached = 0;
    int failed = 0;
    
    // Pre-cache all images
    await Future.wait(
      imageUrls.map((url) async {
        if (url.isEmpty || !url.startsWith('http')) {
          return; // Skip non-network images
        }
        
        try {
          await precacheImage(
            CachedNetworkImageProvider(url),
            context,
          );
          cached++;
          debugPrint('✅ Cached: $url');
        } catch (e) {
          failed++;
          debugPrint('❌ Failed to cache $url: $e');
        }
      }),
    );
    
    debugPrint('🎉 Image pre-caching complete! Cached: $cached, Failed: $failed');
    onComplete?.call();
  }
  
  /// Pre-cache product images from a list
  static Future<void> precacheProductImages(
    BuildContext context,
    List<dynamic> products, {
    VoidCallback? onComplete,
  }) async {
    final imageUrls = products
        .where((product) => product != null)
        .map((product) {
          // Handle both Product objects and maps
          if (product is Map) {
            return product['imageUrl'] as String? ?? '';
          }
          // Assume it has an imageUrl property
          try {
            return (product as dynamic).imageUrl as String? ?? '';
          } catch (e) {
            return '';
          }
        })
        .where((url) => url.isNotEmpty && url.startsWith('http'))
        .toList();
    
    if (imageUrls.isEmpty) {
      debugPrint('⚠️ No network images to pre-cache');
      onComplete?.call();
      return;
    }
    
    await precacheImages(context, imageUrls, onComplete: onComplete);
  }
  
  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      await CachedNetworkImage.evictFromCache('');
      debugPrint('🗑️ Image cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }
}
