import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/order/domain/entities/order.dart';
import 'package:darna/features/order/presentation/providers/order_repository_provider.dart';
import 'package:darna/features/order/presentation/screens/orders_screen.dart';
import 'package:darna/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:darna/features/order/presentation/screens/location_picker_screen.dart';
import 'package:darna/l10n/app_localizations.dart';
import 'package:darna/features/auth/presentation/widgets/login_dialog.dart';
import 'package:darna/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:darna/features/profile/presentation/providers/profile_picture_provider.dart';
import 'package:darna/core/constants/app_icons.dart';
import 'package:darna/core/widgets/login_prompt_dialog.dart';

/// Profile Screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profile, style: theme.textTheme.headlineSmall),
        actions: [
          if (userId != null)
            IconButton(
              icon: const Icon(AppIcons.edit),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                // Double check if it's an anonymous user/guest
                if (user?.isAnonymous == true) {
                  await LoginPromptDialog.show(
                    context,
                    feature: 'edit your profile',
                  );
                  return;
                }
                context.push('/edit-profile');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Picture Avatar
                    GestureDetector(
                      onTap: userId != null && FirebaseAuth.instance.currentUser?.isAnonymous != true
                          ? () async {
                              final profilePictureNotifier = ref.read(profilePictureProvider.notifier);
                              final currentUser = ref.read(userProfileProvider).value;
                              
                              final newUrl = await profilePictureNotifier.pickAndUploadImage(
                                userId,
                                currentUser?.profilePictureUrl,
                              );
                              
                              if (newUrl != null) {
                                // Refresh user profile
                                ref.invalidate(userProfileProvider);
                              }
                            }
                          : null,
                      child: Stack(
                        children: [
                          userProfileAsync.when(
                            data: (profile) {
                              if (profile?.profilePictureUrl != null && profile!.profilePictureUrl!.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(profile.profilePictureUrl!),
                                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                                );
                              }
                              return CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                                child: Text(
                                  profile?.name.isNotEmpty == true
                                      ? profile!.name[0].toUpperCase()
                                      : (userId != null ? 'U' : 'G'),
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              );
                            },
                            loading: () => CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                              child: Icon(
                                AppIcons.profile,
                                size: 40,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            error: (_, __) => CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                              child: Icon(
                                AppIcons.profile,
                                size: 40,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          // Camera icon overlay
                          if (userId != null && FirebaseAuth.instance.currentUser?.isAnonymous != true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    userProfileAsync.when(
                      data: (profile) => Text(
                        profile?.name ?? (userId != null ? l10n.signedIn : l10n.guestUser),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      loading: () => Text(
                        l10n.signedIn,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      error: (_, __) => Text(
                        userId != null ? l10n.signedIn : l10n.guestUser,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    userProfileAsync.when(
                      data: (profile) => Text(
                        profile?.email ?? (userId != null ? 'User' : l10n.guestEmail),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      loading: () => Text(
                        userId != null ? 'Loading...' : l10n.guestEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      error: (_, __) => Text(
                        userId != null ? 'User' : l10n.guestEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    if (userId == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showLoginDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Orders Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.elevation2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.myOrders,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (userId == null || FirebaseAuth.instance.currentUser?.isAnonymous == true) {
                            LoginPromptDialog.show(
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
                        child: Text(l10n.viewAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (userId == null)
                     Text(l10n.loginToSeeOrders, style: theme.textTheme.bodySmall)
                  else
                    StreamBuilder<List<Order>>(
                      stream: ref.watch(orderRepositoryProvider).watchUserOrders(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CircularProgressIndicator());
                        }
                        
                        final orders = snapshot.data ?? [];
                        if (orders.isEmpty) {
                           return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(AppIcons.orders, size: 40, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.noOrdersYet, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                      Text(l10n.orderHistoryMsg, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Show latest order brief
                        final latest = orders.first;
                        String statusLabel;
                        switch (latest.status) {
                          case OrderStatus.pending: statusLabel = l10n.statusPending; break;
                          case OrderStatus.confirmed: statusLabel = l10n.statusConfirmed; break;
                          case OrderStatus.preparing: statusLabel = l10n.statusPreparing; break;
                          case OrderStatus.prepared: statusLabel = 'Ready'; break; // TODO: L10n
                          case OrderStatus.pickedUp: statusLabel = l10n.statusOutForDelivery; break;
                          case OrderStatus.delivered: statusLabel = l10n.statusDelivered; break;
                          case OrderStatus.cancelled: statusLabel = l10n.statusCancelled; break;
                        }

                        return InkWell(
                           onTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => OrderTrackingScreen(order: latest),
                               ),
                             );
                           },
                           child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.deepTeal.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(AppIcons.package, color: AppColors.deepTeal),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${l10n.orderNum}${latest.id.substring(0, 5).toUpperCase()}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                      Text(statusLabel, style: TextStyle(color: AppColors.deepTeal, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Icon(AppIcons.chevronRight, color: AppColors.slate),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuItem(context, theme, icon: AppIcons.location, title: l10n.deliveryAddress, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationPickerScreen(),
                ),
              );
            }),
            _buildMenuItem(context, theme, icon: AppIcons.wallet, title: l10n.paymentMethod, onTap: () {
              _showPaymentMethodsDialog(context, theme);
            }),
            _buildMenuItem(context, theme, icon: AppIcons.settings, title: l10n.settings, onTap: () {
              context.push('/settings');
            }),
            _buildMenuItem(context, theme, icon: AppIcons.help, title: l10n.helpSupport, onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@darna.ma',
                queryParameters: {
                  'subject': 'Darna App Support Request',
                },
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open email client')),
                  );
                }
              }
            }),
            if (userId != null)
              _buildMenuItem(context, theme, icon: AppIcons.logout, title: l10n.logout, titleColor: AppColors.error, onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              }),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildMenuItem(
    // Added context to be safe if I need it later for navigation but kept simplified as per original
    BuildContext context, 
    ThemeData theme, {
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    // Overloaded to match my updated calls or keep simplistic.
    // Wait, previous code was simply _buildMenuItem(theme...
    // I should stick to that signature or update calls.
    // I updated calls above to pass context for consistency but let's see.
    // Original signature: Widget _buildMenuItem(ThemeData theme, { ... })
    // I'll stick to original signature for lines 268+ except where context needed?
    // Actually no context needed for just returning container.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.elevation1,
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppColors.deepTeal),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: titleColor)),
        trailing: Icon(AppIcons.chevronRight, color: AppColors.slate),
        onTap: onTap,
      ),
    );
  }
  
  // Helper to fix the calls above where I added context
  // Oh wait I can just update the method signature to accept context, it's safer.
  
  void _showPaymentMethodsDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(AppIcons.cash, color: AppColors.success),
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when your order arrives'),
              trailing: Icon(AppIcons.success, color: AppColors.success),
            ),
            const Divider(),
            ListTile(
              leading: Icon(AppIcons.creditCard, color: AppColors.slate),
              title: const Text('Credit/Debit Card'),
              subtitle: const Text('Coming soon'),
              trailing: Icon(AppIcons.lock, color: AppColors.slate),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
