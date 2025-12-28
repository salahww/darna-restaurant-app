import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:darna/features/admin/data/services/order_assignment_service.dart';
import 'package:darna/features/admin/presentation/providers/order_assignment_provider.dart';
import 'package:darna/features/admin/presentation/providers/admin_data_providers.dart';
import 'package:darna/core/services/order_notification_helper.dart';
import 'package:darna/features/admin/presentation/widgets/driver_assignment_dialog.dart';

/// Order card for admin with assignment controls
class OrderCardAdmin extends ConsumerWidget {
  final Order order;

  const OrderCardAdmin({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(order.status).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${order.totalAmount.toInt()} DH',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order details
          Text(
            'Order #${order.id.length >= 8 ? order.id.substring(0, 8) : order.id}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.items.length} items • ${order.paymentMethod}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          if (order.status == OrderStatus.pending)
            _buildPendingActions(context, ref, theme)
          else if (order.status == OrderStatus.confirmed)
            _buildConfirmedActions(context, ref, theme)
          else if (order.status == OrderStatus.preparing)
             _buildPreparingActions(context, ref, theme)
          else if (order.status == OrderStatus.prepared)
             _buildPreparedActions(context, ref, theme)
          else if (order.driverId != null)
            _buildDriverInfo(theme),
        ],
      ),
    );
  }

  Widget _buildPendingActions(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              // Reject order
              await ref.read(orderRepositoryProvider).updateOrderStatus(
                order.id,
                OrderStatus.cancelled,
              );
              // ref.invalidate(ordersProvider); // Not needed with stream
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            child: const Text('Reject'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () async {
              // Confirm order
              await ref.read(orderRepositoryProvider).updateOrderStatus(
                order.id,
                OrderStatus.confirmed,
              );
              
              // Notify customer
              await OrderNotificationHelper.notifyOrderStatusChange(
                customerId: order.userId,
                orderId: order.id,
                status: OrderStatus.confirmed.name,
              );
              
              // Optional: Auto-assign driver logic here if needed
              // await ref.read(orderAssignmentServiceProvider).autoAssignDriver(order.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActions(BuildContext context, WidgetRef ref, ThemeData theme) {
     return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await ref.read(orderRepositoryProvider).updateOrderStatus(
                order.id,
                OrderStatus.preparing,
              );
              
              // Notify customer
              await OrderNotificationHelper.notifyOrderStatusChange(
                customerId: order.userId,
                orderId: order.id,
                status: OrderStatus.preparing.name,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              fixedSize: const Size.fromHeight(48), // Strict fixed height
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0, // Remove shadow difference
            ),
            child: const Text('Start Preparing', textAlign: TextAlign.center),
          ),
        ),
        if (order.driverId == null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                 showDialog(
                   context: context,
                   builder: (_) => DriverAssignmentDialog(orderId: order.id),
                 );
              },
              style: OutlinedButton.styleFrom(
                fixedSize: const Size.fromHeight(48), // Strict fixed height
                side: BorderSide(color: theme.dividerColor, width: 1.5), // Visible border
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Assign Driver', textAlign: TextAlign.center),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildPreparingActions(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(orderRepositoryProvider).updateOrderStatus(
            order.id,
            OrderStatus.prepared,
          );
          
          // Notify customer order is ready
          await OrderNotificationHelper.notifyOrderStatusChange(
            customerId: order.userId,
            orderId: order.id,
            status: OrderStatus.prepared.name,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: const Text('Mark Prepared'),
      ),
    );
  }

  Widget _buildPreparedActions(BuildContext context, WidgetRef ref, ThemeData theme) {
     return Column(
       children: [
         Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(
             color: AppColors.primary.withValues(alpha: 0.1),
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: AppColors.primary),
           ),
           child: Row(
             children: [
               Icon(Icons.restaurant, color: AppColors.primary),
               const SizedBox(width: 8),
               Expanded(child: Text('Food is ready. Waiting for driver.', style: theme.textTheme.bodySmall)),
             ],
           ),
         ),
         if (order.driverId == null) ...[
             const SizedBox(height: 8),
             SizedBox(
               width: double.infinity,
               child: OutlinedButton(
                 onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DriverAssignmentDialog(orderId: order.id),
                    );
                 },
                 style: OutlinedButton.styleFrom(
                    fixedSize: const Size.fromHeight(48),
                    side: BorderSide(color: theme.dividerColor, width: 1.5),
                 ),
                 child: const Text('Assign Driver'),
               ),
             ),
         ],
       ],
     );
  }

  Widget _buildAssignDriverButton(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await ref.read(orderAssignmentServiceProvider).autoAssignDriver(order.id);
          ref.invalidate(ordersProvider);
        },
        icon: const Icon(Icons.delivery_dining),
        label: const Text('Auto-Assign Driver'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDriverInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, color: AppColors.deepTeal, size: 20),
          const SizedBox(width: 8),
          Text(
            'Driver assigned',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.deepTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return AppColors.deepTeal;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.prepared:
        return AppColors.primary;
      case OrderStatus.pickedUp:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
