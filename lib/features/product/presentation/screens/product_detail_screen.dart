import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/features/product/domain/entities/product.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'dart:ui';
import 'package:darna/core/constants/app_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/core/widgets/login_prompt_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darna/core/widgets/shimmer_loading.dart';

/// Premium product details screen with customization options
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? heroImage;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroImage,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  // Customization state
  int _quantity = 1;
  PortionSize _portionSize = PortionSize.individual;
  SpiceLevel? _spiceLevel;
  final Set<String> _selectedAddOns = {};
  final TextEditingController _instructionsController = TextEditingController();

  // Product state
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProductById(widget.productId);
    
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        }
      },
      (product) {
        if (mounted) {
          setState(() {
            _product = product;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  double _calculateTotalPrice(Product product) {
    double basePrice = product.price * _portionSize.priceMultiplier;
    double addOnsPrice = _selectedAddOns.length * 10.0; // Simplified for now
    return (basePrice + addOnsPrice) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure l10n is available (might be null if context not ready, but usually not in build)
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return _buildLoadingState(l10n);
    }

    if (_errorMessage != null || _product == null) {
      return _buildErrorState(l10n);
    }

    return _buildProductDetail(context, theme, _product!, l10n);
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.deepTeal),
            SizedBox(height: 16),
            Text(l10n.loadingDishDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.error)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.error, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text(l10n.failedToLoadProduct),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }



  // Helper to get current locale
  String _getLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  // ...

  Widget _buildProductDetail(BuildContext context, ThemeData theme, Product product, AppLocalizations l10n) {
    final langCode = _getLanguageCode(context);
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Image with App Bar
          _buildHeroImage(product, l10n, langCode), // Pass langCode if needed, or just product

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ProductInfo Header
                _buildProductHeader(theme, product, l10n, langCode),

                // Description
                _buildDescription(theme, product, l10n, langCode),

                // Ingredients
                _buildIngredients(theme, product, l10n),
// ...

                // Nutritional Info
                _buildNutritionalInfo(theme, product, l10n),

                // Portion Size Selector
                _buildPortionSelector(theme, l10n),

                // Spice Level (conditional)
                if (_shouldShowSpiceLevel(product))
                  _buildSpiceLevelSelector(theme, l10n),

                // Add-ons
                _buildAddOns(theme, l10n),

                // Special Instructions
                _buildSpecialInstructions(theme, l10n),

                SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAddToCartBar(theme, product, l10n),
    );
  }

  Widget _buildHeroImage(Product product, AppLocalizations l10n, String langCode) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      backgroundColor: _showTitle ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        child: Text(
          product.getLocalizedName(langCode),
          style: TextStyle(
            color: _showTitle ? null : Colors.white,
          ),
        ),
      ),
      // ... (keep iconTheme and actions) 
      iconTheme: IconThemeData(
        color: _showTitle ? null : Colors.white,
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final isFavorite = ref.watch(isFavoriteProvider(product.id));
            return IconButton(
              icon: Icon(
                isFavorite ? AppIcons.favoritesActive : AppIcons.favorites,
                color: _showTitle ? (isFavorite ? AppColors.error : null) : (isFavorite ? AppColors.error : Colors.white),
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user?.isAnonymous == true) {
                  await LoginPromptDialog.show(
                    context,
                    feature: 'save favorites',
                  );
                  return;
                }
                ref.read(favoritesProvider.notifier).toggleFavorite(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite ? l10n.removedFromFavorites : l10n.addedToFavorites,
                      ),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        bottom: 20,
                        left: 16,
                        right: 16,
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'product-${product.id}',
              child: (widget.heroImage ?? product.imageUrl).startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: widget.heroImage ?? product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoading(
                        child: _ImagePlaceholder(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.deepTeal.withOpacity(0.1),
                        child: Icon(AppIcons.food, size: 64, color: AppColors.deepTeal),
                      ),
                    )
                  : Image.asset(
                      widget.heroImage ?? product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.deepTeal.withOpacity(0.1),
                          child: Icon(AppIcons.food, size: 64, color: AppColors.deepTeal),
                        );
                      },
                    ),
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(ThemeData theme, Product product, AppLocalizations l10n, String langCode) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.categoryId,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.deepTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12),

          // Product Name
          Text(
            product.getLocalizedName(langCode),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),

          // Rating & Price Row
          Row(
            children: [
              // Rating
              Row(
                children: [
                  Icon(AppIcons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text(
                    product.rating.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(${(product.rating * 47).toInt()} ${l10n.reviews})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Price
              Text(
                '${product.price.toInt()} DH',
                style: AppTheme.priceStyle(
                  brightness: theme.brightness,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Quick Info
          Row(
            children: [
              _buildInfoChip(AppIcons.clock, '${product.preparationTime} min'),
              SizedBox(width: 12),
              _buildInfoChip(AppIcons.grills, '${product.calories} cal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.deepTeal),
          SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, Product product, AppLocalizations l10n, String langCode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.description,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            product.getLocalizedDescription(langCode),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(ThemeData theme, Product product, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ingredients,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: 24),
              itemCount: product.ingredients.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.slate.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    product.ingredients[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalInfo(ThemeData theme, Product product, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: ExpansionTile(
        title: Text(
          l10n.nutritionalInfo,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNutrientRow(l10n.calories, '${product.calories} kcal'),
                _buildNutrientRow(l10n.protein, '~${(product.calories * 0.15 / 4).toInt()}g'),
                _buildNutrientRow(l10n.carbs, '~${(product.calories * 0.50 / 4).toInt()}g'),
                _buildNutrientRow(l10n.fats, '~${(product.calories * 0.35 / 9).toInt()}g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPortionSelector(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.portionSize,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...PortionSize.values.map((size) {
            final isSelected = _portionSize == size;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.deepTeal : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? AppColors.deepTeal.withValues(alpha: 0.1) : null,
              ),
              child: RadioListTile<PortionSize>(
                value: size,
                groupValue: _portionSize,
                onChanged: (value) => setState(() => _portionSize = value!),
                title: Text(size.label),
                subtitle: Text('×${size.priceMultiplier}'),
                activeColor: AppColors.deepTeal,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  bool _shouldShowSpiceLevel(Product product) {
    return product.categoryId == 'Tagines' || product.categoryId == 'Couscous';
  }

  Widget _buildSpiceLevelSelector(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spiceLevelOptional,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: SpiceLevel.values.map((level) {
              final isSelected = _spiceLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _spiceLevel = level),
                  child: Container(
                    margin: EdgeInsets.only(right: level != SpiceLevel.hot ? 8 : 0),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.deepTeal : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.deepTeal.withValues(alpha: 0.1) : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          level.icon,
                          style: TextStyle(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 8),
                        Text(
                          level.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAddOns(ThemeData theme, AppLocalizations l10n) {
    final addOns = [
      {'id': '1', 'name': 'Extra Bread', 'price': 5},
      {'id': '2', 'name': 'Mixed Olives', 'price': 10},
      {'id': '3', 'name': 'Harissa Sauce', 'price': 3},
    ];

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addOns,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...addOns.map((addon) {
            final id = addon['id'] as String;
            final isSelected = _selectedAddOns.contains(id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _selectedAddOns.add(id);
                  } else {
                    _selectedAddOns.remove(id);
                  }
                });
              },
              title: Text(addon['name'] as String),
              subtitle: Text('+${addon['price']} DH'),
              activeColor: AppColors.deepTeal,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.specialInstructions,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _instructionsController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: l10n.specialInstructionsHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartBar(ThemeData theme, Product product, AppLocalizations l10n) {
    final totalPrice = _calculateTotalPrice(product);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(AppIcons.minus),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text(
                    _quantity.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart
                  final cartNotifier = ref.read(cartProvider.notifier);
                  cartNotifier.addToCart(
                    product: product,
                    portionSize: _portionSize.name,
                    spiceLevel: _spiceLevel?.name ?? 'mild',
                    addons: _selectedAddOns.toList(),
                  );
                  
                  // Show success feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(AppIcons.success, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.addedProductToCart(product.getLocalizedName(Localizations.localeOf(context).languageCode)),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: l10n.viewCart,
                        textColor: Colors.white,
                        onPressed: () {
                          context.push('/cart');
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.cart, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '${l10n.addToCart} - ${totalPrice.toInt()} DH',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).shimmer(duration: 2.seconds, delay: 3.seconds, color: Colors.white.withValues(alpha: 0.2)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for product image loading
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.deepTeal.withOpacity(0.05),
      child: Center(
        child: Icon(
          AppIcons.food,
          size: 80,
          color: AppColors.deepTeal.withOpacity(0.2),
        ),
      ),
    );
  }
}

// Enums for customization
enum PortionSize {
  individual('Individual', 1.0),
  sharing('For 2 People', 1.8),
  family('Family (4-6)', 3.0);

  final String label;
  final double priceMultiplier;

  const PortionSize(this.label, this.priceMultiplier);
}

enum SpiceLevel {
  mild('Mild', '🌶️'),
  medium('Medium', '🌶️🌶️'),
  hot('Hot', '🌶️🌶️🌶️');

  final String label;
  final String icon;

  const SpiceLevel(this.label, this.icon);
}
