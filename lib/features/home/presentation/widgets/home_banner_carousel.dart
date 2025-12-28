import 'dart:async';
import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/product/presentation/screens/product_detail_screen.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _bannerItems = [
    {
      'title': '⚽ CAN 2025 Special!',
      'subtitle': 'Cheer for Morocco! 🇲🇦\nFree delivery on Match Platters!',
      'imageUrl': 'assets/images/products/match_platter.png',
      'productId': '7',
    },
    {
      'title': '🔥 Grill Master!',
      'subtitle': 'Perfect for Match Day! 🦁\nLamb chops, cumin & fresh herbs.',
      'imageUrl': 'assets/images/products/lamb_chops.png',
      'productId': 'g2',
    },
     {
      'title': '🍖 Ultimate Feast',
      'subtitle': 'Fuel the Celebration! ✨\nOrder the mixed grill platter.',
      'imageUrl': 'assets/images/products/mixed_grill.png',
      'productId': 'g1',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerItems.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _bannerItems[_currentBannerIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey<int>(_currentBannerIndex),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient, // Or orange for CAN?
            // Let's use a special gradient for Match Day? 
            // Theme uses teal, but maybe orange/red for CAN? 
            // Keeping teal for brand consistency as per request "Premium"
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.elevation3,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Reduced to fit "⚽ CAN 2025 Special!" on 1 line
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['subtitle']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warmWhite.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => ProductDetailScreen(
                                 productId: item['productId']!,
                                 heroImage: item['imageUrl'], // Pass hero image
                               ),
                             ),
                           );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warmWhite,
                          foregroundColor: AppColors.deepTeal, 
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Order Now'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['imageUrl']!.startsWith('assets/') 
                      ? Image.asset(
                          item['imageUrl']!,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                        )
                      : Image.network(
                          item['imageUrl']!,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
                        ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 120,
      color: AppColors.deepTealDark,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.warmWhite,
        size: 48,
      ),
    );
  }
}
