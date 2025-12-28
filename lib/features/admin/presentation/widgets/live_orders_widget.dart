import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/admin/presentation/widgets/order_card_admin.dart';
import 'package:darna/features/admin/presentation/providers/admin_data_providers.dart';

/// Widget showing live orders feed
class LiveOrdersWidget extends ConsumerWidget {
  const LiveOrdersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // TODO: Replace with real-time stream
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return _buildEmptyState(theme);
        }

        // Filter to show only active orders (not delivered/cancelled)
        final activeOrders = orders
            .where((order) => !order.isCompleted)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: activeOrders.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCardAdmin(order: order),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading orders: $error',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No active orders',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New orders will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
