import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:darna/features/order/domain/entities/order.dart'; // Ensure correct import
import 'package:darna/features/delivery/presentation/screens/active_delivery_screen.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    // Ideally check if already tracking or sync UI with Firestore 'isAvailable'
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       // Optional: Restore state from Firestore
    });
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    final locationService = ref.read(locationTrackingServiceProvider);
    
    if (value) {
      // Going Online
      final success = await locationService.startTracking();
      if (success) {
        setState(() => _isOnline = true);
        // Update Firestore availability
        final driverId = ref.read(currentDriverIdProvider);
        if (driverId != null) {
          await ref.read(driverRepositoryProvider).setDriverAvailability(driverId, true);
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required to go online')),
          );
        }
      }
    } else {
      // Going Offline
      await locationService.stopTracking();
      setState(() => _isOnline = false);
      
      final driverId = ref.read(currentDriverIdProvider);
      if (driverId != null) {
        await ref.read(driverRepositoryProvider).setDriverAvailability(driverId, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Watch pending orders and active order
    final pendingOrdersAsync = ref.watch(pendingOrdersProvider);
    final activeOrderAsync = ref.watch(activeOrderProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Driver Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/driver/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               ref.invalidate(pendingOrdersProvider);
               ref.invalidate(activeOrderProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
               await FirebaseAuth.instance.signOut();
               if (context.mounted) {
                 context.go('/auth/login');
               }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingOrdersProvider);
          return ref.read(pendingOrdersProvider.future);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Stats Section
              _buildStatsSection(theme),
              const SizedBox(height: 16),

              // Status Card
              _buildStatusCard(theme),
              const SizedBox(height: 24),
              
              // Active Delivery Section
              Text(
                'Active Delivery',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              activeOrderAsync.when(
                data: (activeOrder) => _buildActiveOrderSection(theme, activeOrder),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading active order: $e', style: TextStyle(color: AppColors.error)),
              ),

              const SizedBox(height: 24),
              
              // New Orders Section
              if (_isOnline && activeOrderAsync.value == null) ...[
                Text(
                  'New Orders',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                pendingOrdersAsync.when(
                  data: (orders) => _buildPendingOrdersList(theme, orders),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading orders: $e'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    // Watch real stats
    final statsAsync = ref.watch(driverStatsProvider);
    
    return statsAsync.when(
      data: (stats) => IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Today's Earnings",
                value: "${stats['earnings'].toStringAsFixed(0)} DH",
                icon: Icons.account_balance_wallet,
                color: AppColors.primary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: "Trips",
                value: "${stats['trips']}",
                icon: Icons.motorcycle,
                color: AppColors.deepTeal,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
             Expanded(
              child: _StatCard(
                title: "Rating",
                value: "${stats['rating']}",
                icon: Icons.star,
                color: AppColors.richGold,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox(), 
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.elevation2,
        border: Border.all(
          color: _isOnline ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
           Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isOnline ? AppColors.primary.withValues(alpha: 0.1) : theme.dividerColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isOnline ? Icons.wifi : Icons.wifi_off,
              color: _isOnline ? AppColors.primary : theme.disabledColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'You are Online' : 'You are Offline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isOnline 
                      ? 'Waiting for orders...' 
                      : 'Go online to start',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: _toggleOnlineStatus,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderSection(ThemeData theme, OrderEntity? activeOrder) {
    if (activeOrder == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.delivery_dining, size: 48, color: theme.disabledColor),
            const SizedBox(height: 12),
            Text(
              'No active deliveries',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor),
            ),
          ],
        ),
      );
    }
    
    return Card(
      color: theme.cardColor,
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    activeOrder.status.displayName,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${activeOrder.id.length > 6 ? activeOrder.id.substring(0, 6) : activeOrder.id}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activeOrder.deliveryAddress,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final driverRepo = ref.read(driverRepositoryProvider);
                  // Assuming user is driver if viewing this
                  
                  if (activeOrder.status == OrderStatus.prepared) {
                     // Pickup Order
                     await driverRepo.updateOrderStatus(activeOrder.id, 'pickedUp');
                     
                     // Force refresh of the active order UI
                     ref.invalidate(activeOrderProvider);
                     
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Order Picked Up!')),
                       );
                     }
                  } else {
                     // Default navigation
                     Navigator.push(
                       context, 
                       MaterialPageRoute(builder: (_) => ActiveDeliveryScreen(order: activeOrder))
                     );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  activeOrder.status == OrderStatus.prepared ? 'Pick Up Order' : 'View Delivery Details', 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOrdersList(ThemeData theme, List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No new orders available.', style: theme.textTheme.bodyMedium),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          color: theme.cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)} DH',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order.items.length} items',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Ignore/Decline logic
                        },
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        child: Text('Ignore', style: TextStyle(color: theme.colorScheme.onSurface)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                           final driverRepo = ref.read(driverRepositoryProvider);
                           final currentDriverId = ref.read(currentDriverIdProvider);
                           
                           if (currentDriverId != null) {
                             await driverRepo.acceptOrder(currentDriverId, order.id);
                             ref.invalidate(pendingOrdersProvider);
                             ref.invalidate(activeOrderProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order Accepted!')),
                                );
                              }
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          fixedSize: const Size.fromHeight(48),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           elevation: 0,
                        ),
                        child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
