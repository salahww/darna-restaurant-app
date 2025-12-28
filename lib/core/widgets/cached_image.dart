import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/widgets/shimmer_loading.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    final isNetwork = imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isNetwork
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: placeholder ?? (context, url) => _buildPlaceholder(),
              errorWidget: errorWidget ?? (context, url, error) => _buildErrorWidget(context),
              maxHeightDiskCache: 1000,
              memCacheHeight: height != null ? (height! * 2).toInt() : null,
              memCacheWidth: width != null ? (width! * 2).toInt() : null,
              fadeInDuration: const Duration(milliseconds: 300),
            )
          : FutureBuilder(
              future: _loadAssetImage(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return errorWidget != null 
                        ? errorWidget!(context, imageUrl, snapshot.error) 
                        : _buildErrorWidget(context);
                  }
                  return Image.asset(
                    imageUrl,
                    width: width,
                    height: height,
                    fit: fit,
                    errorBuilder: (context, error, stackTrace) {
                      return errorWidget != null 
                          ? errorWidget!(context, imageUrl, error) 
                          : _buildErrorWidget(context);
                    },
                  );
                }
                return placeholder != null 
                    ? placeholder!(context, imageUrl)
                    : _buildPlaceholder();
              },
            ),
    );
  }

  Future<void> _loadAssetImage(BuildContext context) async {
    // Asynchronously load and precache the asset image
    final AssetImage assetImage = AssetImage(imageUrl);
    await precacheImage(assetImage, context);
  }

  Widget _buildPlaceholder() {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.image, 
              color: AppColors.primary.withValues(alpha: 0.5),
              size: (width != null && width! < 50) ? 16 : 24,
            ),
          ],
        ),
      ),
    );
  }
}
