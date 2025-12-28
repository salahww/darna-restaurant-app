import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:darna/features/order/presentation/screens/checkout_screen.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'package:darna/core/constants/app_icons.dart';
import 'package:darna/features/home/presentation/providers/main_navigation_provider.dart';
import 'package:darna/core/widgets/login_prompt_dialog.dart';
import 'package:darna/features/admin/presentation/providers/admin_auth_provider.dart';

/// Shopping cart screen
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Was AppColors.cream
      appBar: AppBar(
        title: Text(l10n.shoppingCart, style: theme.textTheme.headlineSmall),
        backgroundColor: theme.appBarTheme.backgroundColor, // Was AppColors.warmWhite (or null for default)
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearCartDialog(context, cartNotifier, l10n);
              },
              child: Text(
                l10n.clear,
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty ? _buildEmptyState(context, ref, theme, l10n) : _buildCartContent(context, ref, cartItems, cartNotifier, l10n),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, ThemeData theme, AppLocalizations l10n) {
    // Empty state code... 
    // The gradient container with AppColors.warmWhite icon is fine because it's a specific design element (white icon on orange gradient)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.cart,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.yourCartIsEmpty,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.addItemsToCartMsg,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🛒 Browse Menu button tapped - navigating to Home');
              // Switch to Home tab (index 0) in MainNavigationScreen
              ref.read(mainNavigationIndexProvider.notifier).state = 0;
              debugPrint('✅ Provider state set to 0');
            },
            icon: const Icon(AppIcons.allMenu),
            label: Text(l10n.browseMenu),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    List cartItems,
    CartNotifier cartNotifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final subtotal = cartNotifier.subtotal;
    final deliveryFee = cartNotifier.deliveryFee;
    final total = cartNotifier.total;

    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemCard(
                item: item,
                onRemove: () => cartNotifier.removeFromCart(item.id),
                onIncrement: () => cartNotifier.incrementQuantity(item.id),
                onDecrement: () => cartNotifier.decrementQuantity(item.id),
              );
            },
          ),
        ),

        // Price Breakdown & Checkout
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor, // Was AppColors.warmWhite
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: AppShadows.elevation3,
          ),
          child: SafeArea( // Keep SafeArea for bottom padding
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtotal
                _buildPriceRow(
                  theme,
                  label: l10n.subtotal,
                  amount: subtotal,
                  isSubtle: true,
                ),
                
                const SizedBox(height: 8),
                
                // Delivery Fee
                _buildPriceRow(
                  theme,
                  label: l10n.deliveryFee,
                  amount: deliveryFee,
                  isSubtle: true,
                  isFree: deliveryFee == 0,
                  l10n: l10n,
                ),
                
                if (subtotal < 200) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.info,
                          size: 16,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.freeDeliveryMsg((200 - subtotal).toStringAsFixed(0)),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                Divider(color: AppColors.divider),
                
                const SizedBox(height: 12),
                
                // Total
                _buildPriceRow(
                  theme,
                  label: l10n.total,
                  amount: total,
                  isSubtle: false,
                ),
                
                const SizedBox(height: 20),
                
                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Checkout
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.warmWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(AppIcons.cartActive),
                        const SizedBox(width: 8),
                        Text(
                          l10n.proceedToCheckout,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.warmWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    ThemeData theme, {
    required String label,
    required double amount,
    required bool isSubtle,
    bool isFree = false,
    AppLocalizations? l10n,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isSubtle
              ? theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate)
              : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        isFree
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n?.freeDelivery ?? 'FREE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Text(
                '${amount.toStringAsFixed(0)} DH',
                style: isSubtle
                    ? theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
              ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartNotifier cartNotifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCartConfirmTitle),
        content: Text(l10n.clearCartConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              cartNotifier.clearCart();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.discount,
                color: AppColors.warmWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.comingSoon)),
          ],
        ),
        content: Text(
          l10n.checkoutComingSoonMsg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }
}
