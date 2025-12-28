import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:darna/l10n/app_localizations.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myOrders)),
        body: Center(child: Text(l10n.pleaseLoginOrders)),
      );
    }

    final ordersAsync = ref.watch(userOrdersProvider(userId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.myOrders, style: theme.textTheme.headlineSmall),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: AppColors.slate.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.noOrdersYet, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _OrderCard(order: orders[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = order.isCompleted;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.elevation1,
          border: Border.all(
            color: isCompleted ? Colors.transparent : AppColors.richGold.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderId(order.id.substring(0, 8).toUpperCase()),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              Divider(height: 24, color: theme.dividerColor),
              // Items Preview (first 2)
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.product.name, style: theme.textTheme.bodyMedium),
                        ),
                        Text(
                          '${item.subtotal.toStringAsFixed(0)} DH',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.moreItems(order.items.length - 2),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(height: 24, color: theme.dividerColor),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.total,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} DH',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String label;
    
    switch (status) {
      case OrderStatus.pending:
        label = l10n.statusPending;
        color = isDark ? Colors.white : Colors.orange.shade900;
        bg = Colors.orange.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.confirmed:
        label = l10n.statusConfirmed;
        color = isDark ? Colors.white : Colors.blue.shade900;
        bg = Colors.blue.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.preparing:
        label = l10n.statusPreparing;
        color = isDark ? Colors.white : Colors.orange.shade900;
        bg = Colors.orange.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.prepared:
        label = 'Ready'; // TODO: Add to l10n
        color = isDark ? Colors.white : AppColors.primary;
        bg = AppColors.primary.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.pickedUp:
        label = l10n.statusOutForDelivery; // Reusing "Out for Delivery" or new key
        color = isDark ? Colors.white : Colors.purple.shade900;
        bg = Colors.purple.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.delivered:
        label = l10n.statusDelivered;
        color = isDark ? Colors.white : AppColors.success;
        bg = AppColors.success.withOpacity(isDark ? 0.3 : 0.15);
        break;
      case OrderStatus.cancelled:
        label = l10n.statusCancelled;
        color = isDark ? Colors.white : AppColors.error;
        bg = AppColors.error.withOpacity(isDark ? 0.3 : 0.15);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Provider for user orders stream
final userOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  return ref.watch(orderRepositoryProvider).watchUserOrders(userId);
});
