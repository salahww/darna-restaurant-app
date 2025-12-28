import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:darna/core/theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDarkMode ? const Color(0xFF2D2427) : const Color(0xFFE0E0E0),
      highlightColor: isDarkMode 
          ? AppColors.secondary.withValues(alpha: 0.1) 
          : AppColors.secondary.withValues(alpha: 0.2),
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final ShapeBorder? shapeBorder;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
    this.shapeBorder,
  });

  const ShimmerPlaceholder.circular({
    super.key,
    required this.width,
    required this.height,
  }) : radius = 0, shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: shapeBorder != null 
            ? ShapeDecoration(
                color: Colors.black,
                shape: shapeBorder!,
              )
            : BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(radius),
              ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const Expanded(
            flex: 5,
            child: ShimmerPlaceholder(height: double.infinity, radius: 16),
          ),
          
          // Content skeleton
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerPlaceholder(width: 40, height: 12),
                  const SizedBox(height: 8),
                  const ShimmerPlaceholder(width: 120, height: 16),
                  const SizedBox(height: 4),
                  const ShimmerPlaceholder(width: 80, height: 12),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                       ShimmerPlaceholder(width: 60, height: 20),
                       ShimmerPlaceholder(width: 32, height: 32, radius: 10),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const ShimmerPlaceholder(width: 60, height: 60, radius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerPlaceholder(width: double.infinity, height: 16),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
