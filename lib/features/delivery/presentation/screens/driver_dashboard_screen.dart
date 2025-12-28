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
    // Logic moved to build method via ref.listen/ref.watch
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    debugPrint('🔘 Toggle Online Status: $value');
    final locationService = ref.read(locationTrackingServiceProvider);
    
    if (value) {
      // Going Online
      debugPrint('📍 Starting location tracking...');
      final success = await locationService.startTracking();
      debugPrint('📍 Tracking start result: $success');
      
      if (success) {
        setState(() => _isOnline = true);
        // Update Firestore availability
        final driverId = ref.read(currentDriverIdProvider);
        debugPrint('👤 Driver ID: $driverId');
        
        if (driverId != null) {
          debugPrint('🔄 Updating Firestore availability to TRUE for $driverId');
          final result = await ref.read(driverRepositoryProvider).setDriverAvailability(driverId, true);
          result.fold(
            (l) => debugPrint('❌ Failed to update availability: ${l.message}'),
            (r) => debugPrint('✅ Availability updated to TRUE'),
          );
        } else {
          debugPrint('❌ Driver ID is NULL - cannot update availability');
        }
      } else {
        debugPrint('❌ Location tracking failed to start');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required to go online')),
          );
        }
      }
    } else {
      // Going Offline
      debugPrint('📍 Stopping location tracking');
      await locationService.stopTracking();
      setState(() => _isOnline = false);
      
      final driverId = ref.read(currentDriverIdProvider);
      debugPrint('👤 Driver ID (offline): $driverId');
      
      if (driverId != null) {
        debugPrint('🔄 Updating Firestore availability to FALSE for $driverId');
        await ref.read(driverRepositoryProvider).setDriverAvailability(driverId, false);
        debugPrint('✅ Availability updated to FALSE');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch driver ID to ensure we can update status
    final driverId = ref.watch(currentDriverIdProvider);
    
    // Listen to database connection status for driver availability
    ref.listen(driverAvailabilityProvider, (previous, next) {
      next.whenData((isAvailable) async {
        if (_isOnline != isAvailable) {
           setState(() => _isOnline = isAvailable);
           
           final locationService = ref.read(locationTrackingServiceProvider);
           if (isAvailable) {
             await locationService.startTracking();
           } else {
             await locationService.stopTracking();
           }
        }
      });
    });
    
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
               ref.invalidate(driverStatsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
               // Navigate first to prevent flash of guest home screen
               context.go('/auth/onboarding');
               await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingOrdersProvider);
          ref.invalidate(driverStatsProvider); // Refresh stats on pull-to-refresh
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
              _buildStatusCard(theme, driverId),
              const SizedBox(height: 24),
              
              // Active Delivery Section
              Text(
                'Active Delivery',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              activeOrderAsync.when(
                data: (activeOrder) => _buildActiveOrderSection(theme, activeOrder),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                error: (e, _) => Text('Error loading active order: $e', style: TextStyle(color: AppColors.error)),
              ),

              // Show pending orders only if online and no active order
              if (_isOnline && activeOrderAsync.value == null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Orders',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    pendingOrdersAsync.when(
                      data: (orders) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${orders.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                pendingOrdersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(Icons.access_time, size: 48, color: theme.disabledColor),
                              const SizedBox(height: 16),
                              Text(
                                'No orders waiting',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ],
                          ),
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
                        return _buildOrderCard(theme, order);
                      },
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
                  error: (e, stack) => Text('Error: $e'),
                ),
              ],
              
              if (!_isOnline) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.offline_bolt_outlined, size: 64, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text(
                        'You are currently offline',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Go online to start receiving orders',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 80), // Bottom padding
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

  Widget _buildStatusCard(ThemeData theme, String? driverId) {
    final isLoading = driverId == null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                      isLoading
                          ? 'Loading profile...'
                          : (_isOnline ? 'You are Online' : 'You are Offline'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isLoading
                          ? 'Please wait...'
                          : (_isOnline 
                              ? 'Waiting for orders...' 
                              : 'Go online to start'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: _isOnline,
                  onChanged: _toggleOnlineStatus,
                  activeColor: AppColors.primary,
                ),
            ],
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
                     await Navigator.push(
                       context, 
                       MaterialPageRoute(builder: (_) => ActiveDeliveryScreen(order: activeOrder))
                     );
                     // Refresh all data when returning from delivery screen (potentially delivered)
                     ref.invalidate(activeOrderProvider);
                     ref.invalidate(driverStatsProvider);
                     ref.invalidate(pendingOrdersProvider);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeOrder.status == OrderStatus.prepared ? AppColors.primary : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  activeOrder.status == OrderStatus.prepared ? 'Pick Up Order' : 'View Delivery Details', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.richGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${order.totalAmount.toStringAsFixed(2)} MAD',
                  style: TextStyle(
                    color: AppColors.richGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: theme.disabledColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
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
                 try {
                   final driverRepo = ref.read(driverRepositoryProvider);
                   final driverId = ref.read(currentDriverIdProvider);
                   
                   if (driverId == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Error: Driver profile not loaded')),
                     );
                     return;
                   }

                   // Assign order to driver
                   final result = await driverRepo.acceptOrder(driverId, order.id);
                   
                   result.fold(
                     (failure) {
                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Failed to accept order: ${failure.message}')),
                         );
                       }
                     },
                     (_) {
                       if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Order Accepted!')),
                         );
                         // Refresh data
                         ref.invalidate(activeOrderProvider);
                         ref.invalidate(pendingOrdersProvider);
                       }
                     },
                   );
                 } catch (e) {
                   debugPrint('Error accepting order: $e');
                 }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Accept Delivery'),
            ),
          ),
        ],
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
