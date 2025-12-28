import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/ai/domain/entities/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:darna/features/cart/domain/entities/cart_item.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';
import 'package:darna/features/cart/presentation/screens/cart_screen.dart'; // To navigate

class MessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  Future<void> _handleAddToCart(BuildContext context, WidgetRef ref) async {
    final action = message.cartAction;
    if (action == null) return;
    
    // Show Loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adding items to cart...')),
    );

    try {
      final items = action['items'] as List;
      final cartNotifier = ref.read(cartProvider.notifier);
      final productRepo = ref.read(productRepositoryProvider);

      int addedCount = 0;

      for (var item in items) {
        final name = item['name'] as String;
        final qty = item['quantity'] as int? ?? 1;

        // Search for product by name
        final result = await productRepo.searchProducts(name);
        
        result.fold(
          (failure) => debugPrint('Item not found: $name'),
          (products) {
            if (products.isNotEmpty) {
              // Best match (first one)
              final product = products.first;
              
              // Check if exact match or loose?
              // searchProducts is loose. Let's assume top result is correct.
              
              // Check if exact match or loose?
              // searchProducts is loose. Let's assume top result is correct.
              
              cartNotifier.addToCart(
                 product: product,
                 quantity: qty,
                 portionSize: 'individual', // Default
                 spiceLevel: 'mild',        // Default
                 addons: [],                // Default
              );
              
              addedCount++;
            }
          }
        );
      }

      if (context.mounted) {
         if (addedCount > 0) {
           // Navigate to Cart
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const CartScreen()),
           );
         } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not find those items in the menu.')),
            );
         }
      }

    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process order.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final hasAction = message.cartAction != null;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmWhite,
                  height: 1.4,
                ),
              )
            else
              MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                  strong: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            
            // Cart Action Card
            if (hasAction) 
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart_checkout, color: AppColors.deepTeal, size: 20),
                        const SizedBox(width: 8),
                         Text(
                          'Ready to Order?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepTeal,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    // List Items Preview
                    Column(
                       children: (message.cartAction!['items'] as List).map<Widget>((item) {
                         return Padding(
                           padding: const EdgeInsets.only(bottom: 4),
                           child: Row(
                             children: [
                               Text('${item['quantity']}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                               const SizedBox(width: 8),
                               Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 12))),
                             ],
                           ),
                         );
                       }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleAddToCart(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Add to Cart & Checkout'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isUser ? AppColors.warmWhite.withOpacity(0.7) : AppColors.slate.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
