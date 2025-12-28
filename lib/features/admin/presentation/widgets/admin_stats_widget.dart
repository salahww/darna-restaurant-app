import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:darna/features/admin/presentation/providers/admin_data_providers.dart';
import 'package:darna/features/order/domain/entities/order.dart';

/// Statistics cards for admin dashboard
class AdminStatsWidget extends ConsumerWidget {
  const AdminStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) {
        final today = DateTime.now();
        final todayOrders = orders.where((order) {
          return order.createdAt.year == today.year &&
              order.createdAt.month == today.month &&
              order.createdAt.day == today.day;
        }).toList();

        final activeOrders = orders.where((order) => !order.isCompleted).length;
        
        final validTodayOrders = todayOrders.where((o) => o.status != OrderStatus.cancelled);
        
        final todayRevenue = validTodayOrders.fold<double>(
          0,
          (sum, order) => sum + order.totalAmount,
        );

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  title: "Today's Orders",
                  value: todayOrders.length.toString(),
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total Active',
                  value: activeOrders.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.deepTeal,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Revenue',
                  value: '${todayRevenue.toInt()} DH',
                  icon: Icons.attach_money,
                  color: AppColors.richGold,
                  theme: theme,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox(height: 100),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
