import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/features/product/presentation/screens/product_detail_screen.dart';
import 'package:darna/core/constants/app_constants.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/core/utils/responsive_layout.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';
import 'package:darna/features/product/domain/entities/product.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/product/presentation/screens/all_products_screen.dart';
import 'package:darna/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:darna/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'package:darna/features/order/presentation/providers/location_provider.dart';
import 'package:darna/features/order/presentation/screens/location_picker_screen.dart';
import 'package:darna/features/order/presentation/screens/orders_screen.dart';
import 'package:darna/features/profile/presentation/screens/profile_screen.dart';
import 'package:darna/core/constants/app_icons.dart';
import 'package:darna/core/widgets/premium_product_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:darna/core/widgets/login_prompt_dialog.dart';
import 'package:darna/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:darna/core/services/image_cache_service.dart';

/// Modern premium home screen with Dribbble-inspired design
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final List<String> categories = [
    'All',
    'Tagines',
    'Couscous',
    'Pastilla',
    'Starters',
    'Grills',
    'Desserts',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Location Header
            SliverToBoxAdapter(
              child: _buildLocationHeader(theme, l10n),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(theme, l10n),
            ),
            
            // Promotional Banner
            const SliverToBoxAdapter(
              child: HomeBannerCarousel(),
            ),
            
            // Categories
            SliverToBoxAdapter(
              child: _buildCategoriesSection(theme, l10n),
            ),
            
            // Products
            SliverToBoxAdapter(
              child: _buildSectionHeader(theme, l10n.picksForYou, () {
                context.push('/products');
              }, l10n), // Fixed: passed l10n for consistency if needed in future
            ),
            
            // Products Grid with FutureBuilder
            SliverToBoxAdapter(
              child: FutureBuilder(
                future: ref.read(productRepositoryProvider).getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No data'),
                      ),
                    );
                  }
                  
                  return snapshot.data!.fold(
                    (failure) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Error: ${failure.message}'),
                      ),
                    ),
                    (products) {
                      // Pre-cache product images in background (only network images)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ImageCacheService.precacheProductImages(
                            context,
                            products,
                            onComplete: () {
                              debugPrint('✅ All product images cached!');
                            },
                          );
                        }
                      });
                      
                      // Filter products by category first
                      var filteredProducts = selectedCategory == 'All'
                          ? products
                          : products.where((p) => p.categoryId == selectedCategory).toList();
                      
                      // Then filter by search query
                      if (searchQuery.isNotEmpty) {
                        filteredProducts = filteredProducts.where((p) => 
                          p.name.toLowerCase().contains(searchQuery) ||
                          (p.description?.toLowerCase().contains(searchQuery) ?? false)
                        ).toList();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveLayout.isDesktop(context) 
                                  ? 4 
                                  : ResponsiveLayout.isTablet(context) ? 3 : 2,
                              childAspectRatio: 0.68, // Taller cards - guaranteed overflow-free 
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildEnhancedProductCard(
                              theme,
                              filteredProducts[index],
                              l10n
                            ).animate(delay: (50 * index).ms).fadeIn().slideY(begin: 0.2, end: 0);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(ThemeData theme, AppLocalizations l10n) {
    final locationState = ref.watch(locationProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            AppIcons.locationActive,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                 final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deliveringTo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          locationState.address, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        AppIcons.arrowDown,
                        color: theme.textTheme.bodyLarge?.color,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Notification icon
          GestureDetector(
            onTap: () async {
              final currentUser = ref.read(currentUserProvider).value;
              if (currentUser?.isGuest == true) {
                await LoginPromptDialog.show(
                  context,
                  feature: 'view your orders',
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.elevation1,
              ),
              child: Stack(
                children: [
                  Icon(AppIcons.notification, color: theme.colorScheme.onSurface),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.burgundy,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile icon
          GestureDetector(
            onTap: () async {
              final currentUser = ref.read(currentUserProvider).value;
              if (currentUser?.isGuest == true) {
                await LoginPromptDialog.show(
                  context,
                  feature: 'access your profile',
                );
                return;
              }
              context.push('/profile');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.elevation1,
              ),
              child: Icon(AppIcons.profile, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // Not used generally but updated signature just in case
  Future<void> _seedDatabase(ThemeData theme) async {
    // ... existing implementation remains same for dev tool
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white54 
                      : AppColors.slate,
                ),
                prefixIcon: Icon(
                  AppIcons.search, 
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white70 
                      : AppColors.slate, 
                  size: 20,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context, theme, l10n),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.goldGlow,
              ),
              child: Icon(
                AppIcons.filter,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        _buildSectionHeader(theme, l10n.categories, null, l10n, showSeeAll: false),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryKey = categories[index];
              final isSelected = selectedCategory == categoryKey;
              
              // Map key to localized string
              String displayCategory;
              switch (categoryKey) {
                case 'All': displayCategory = l10n.viewAll; break; // Reusing 'View All' or generic 'All'
                case 'Tagines': displayCategory = l10n.catTagines; break;
                case 'Couscous': displayCategory = l10n.catCouscous; break;
                case 'Pastilla': displayCategory = l10n.catPastilla; break;
                case 'Starters': displayCategory = l10n.catStarters; break;
                case 'Grills': displayCategory = l10n.catGrills; break;
                case 'Desserts': displayCategory = l10n.catDesserts; break;
                case 'Drinks': displayCategory = l10n.catDrinks; break;
                default: displayCategory = categoryKey;
              }
              // Special case for 'All' if 'View All' isn't appropriate context ('Menu' or similar might be better but View All works)
              // Actually, I don't have 'All' key. I'll use 'viewAll' for now.

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categoryKey;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.richGold.withValues(alpha: 0.1)
                              : theme.cardTheme.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.richGold 
                                : AppColors.slate.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? AppShadows.goldGlow : AppShadows.elevation1,
                        ),
                        child: Icon(
                          _getCategoryIcon(categoryKey),
                          color: isSelected 
                              ? AppColors.richGold 
                              : (theme.brightness == Brightness.dark ? Colors.white : AppColors.slate),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayCategory,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected 
                              ? AppColors.richGold 
                              : (theme.brightness == Brightness.dark ? Colors.white70 : AppColors.slate),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    // Keep existing logic
    switch (category) {
      case 'All': return AppIcons.allMenu;
      case 'Tagines': return AppIcons.tagine;
      case 'Couscous': return AppIcons.couscous;
      case 'Pastilla': return AppIcons.food; // Generic food icon for Pastilla if specific one missing
      case 'Starters': return AppIcons.appetizers;
      case 'Grills': return AppIcons.grills;
      case 'Desserts': return AppIcons.desserts;
      case 'Drinks': return AppIcons.drinks;
      default: return AppIcons.food;
    }
  }

  Widget _buildSectionHeader(ThemeData theme, String title, VoidCallback? onSeeAll, AppLocalizations l10n, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showSeeAll && onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                l10n.seeAll,
                style: TextStyle(color: AppColors.richGold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProductCard(ThemeData theme, Product product, AppLocalizations l10n) {
    final langCode = Localizations.localeOf(context).languageCode;
    // Helper to get description if available
    String getDescription() {
       // Since Product entity might not have getLocalizedDescription or description map exposed directly in this context 
       // if it's not standard, we'll try to use what's available or empty.
       // Assuming standard Product entity has localized fields.
       // For now, returning empty or generic text if not available.
       return product.getLocalizedDescription(langCode); 
    }

    return Consumer(
      builder: (context, ref, child) {
        final isFavorite = ref.watch(isFavoriteProvider(product.id));
        return PremiumProductCard(
          imageUrl: product.imageUrl,
          title: product.getLocalizedName(langCode),
          description: getDescription(),
          price: product.price,
          rating: product.rating,
          isFavorite: isFavorite,
          heroTag: 'product-${product.id}',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
          onAdd: () {
            // Add to cart logic here if needed directly or just open detail
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
          onFavorite: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(product.id);
            // Snackbar handled by widget? Or here? 
            // PremiumProductCard doesn't show snackbar, so we can do it here if we want feedback
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? l10n.removedFromFavorites : l10n.addedToFavorites,
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter Options',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text('Price Range', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Under 50 DH'), onSelected: (_) {}),
                FilterChip(label: const Text('50-100 DH'), onSelected: (_) {}),
                FilterChip(label: const Text('100+ DH'), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            Text('Rating', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('4+ ⭐'), onSelected: (_) {}),
                FilterChip(label: const Text('3+ ⭐'), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
