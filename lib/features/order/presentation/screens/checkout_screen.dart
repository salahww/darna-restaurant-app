import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/cart/presentation/providers/cart_provider.dart';
import 'package:darna/features/order/presentation/providers/checkout_provider.dart';
import 'package:darna/features/order/presentation/screens/location_picker_screen.dart';
import 'package:darna/features/order/presentation/providers/location_provider.dart';
import 'package:darna/l10n/app_localizations.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController(); // Basic phone input
  String _paymentMethod = 'COD'; // Default to Cash on Delivery

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill address from Global Location Provider
    final savedLocation = ref.read(locationProvider);
    if (savedLocation.address != 'Select Location') {
      _addressController.text = savedLocation.address;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    // Call Provider
    await ref.read(checkoutProvider.notifier).placeOrder(
      deliveryAddress: '${_addressController.text} (Phone: ${_phoneController.text})',
      paymentMethod: _paymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = ref.watch(cartTotalProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final l10n = AppLocalizations.of(context)!;

    // Listen for success/error
    ref.listen(checkoutProvider, (previous, next) {
      if (next.status == CheckoutStatus.success) {
        // Navigate to Success Screen
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(l10n.orderPlacedTitle),
            content: Text(l10n.orderPlacedMsg),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close Checkout
                  // Ideally navigate to OrderTrackingScreen
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      } else if (next.status == CheckoutStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? l10n.error)),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.checkout, style: theme.textTheme.headlineSmall),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  _buildStep(theme, '1', l10n.deliveryAddress, true, false),
                  _buildStepLine(theme, true),
                  _buildStep(theme, '2', l10n.paymentMethod, true, false),
                  _buildStepLine(theme, false),
                  _buildStep(theme, '3', l10n.confirm, false, true),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),

            // 1. Delivery Address
            _buildSectionTitle(theme, l10n.deliveryAddress, Icons.location_on)
                .animate(delay: 100.ms).fadeIn().slideX(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.elevation1,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: l10n.enterAddressHint,
                      border: InputBorder.none,
                      icon: const Icon(Icons.home_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map, color: AppColors.deepTeal),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationPickerScreen(),
                            ),
                          );
                          if (result != null && result is String) {
                            setState(() {
                              _addressController.text = result; 
                            });
                          }
                        },
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const Divider(),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: l10n.phoneHint,
                      border: InputBorder.none,
                      icon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // 2. Payment Method
            _buildSectionTitle(theme, l10n.paymentMethod, Icons.payment)
              .animate(delay: 200.ms).fadeIn().slideX(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.elevation1,
              ),
              child: Column(
                children: [
                  _buildPaymentOption(
                    theme,
                    title: l10n.cod,
                    value: 'COD',
                    groupValue: _paymentMethod,
                    icon: Icons.money,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  const Divider(),
                  _buildPaymentOption(
                    theme,
                    title: '${l10n.creditCard} (${l10n.comingSoon})',
                    value: 'CARD', // Disabled logic visually
                    groupValue: _paymentMethod,
                    icon: Icons.credit_card,
                    onChanged: null, // Disabled
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // 3. Order Summary
            _buildSectionTitle(theme, l10n.orderSummary, Icons.receipt_long)
                .animate(delay: 300.ms).fadeIn().slideX(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.elevation1,
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.totalAmount, style: theme.textTheme.titleMedium),
                      Text(
                        '${total.toStringAsFixed(0)} DH',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.deepTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
             const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: checkoutState.status == CheckoutStatus.loading
                ? null
                : () {
                     if (_addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.enterAddressError)),
                        );
                        return;
                      }
                      _placeOrder(); // Call wrapper or direct provider call inside method
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: checkoutState.status == CheckoutStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    l10n.placeOrder,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepTeal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    ThemeData theme, {
    required String title,
    required String value,
    required String groupValue,
    required IconData icon,
    required ValueChanged<String?>? onChanged,
  }) {
    final isSelected = value == groupValue;
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.deepTeal,
      title: Text(
        title,
        style: TextStyle(
          color: onChanged == null ? AppColors.slate : AppColors.charcoal,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.deepTeal : AppColors.slate,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
  Widget _buildStep(ThemeData theme, String number, String label, bool isActive, bool isLast) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.deepTeal : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: isActive ? AppShadows.elevation1 : null,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? AppColors.deepTeal : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(ThemeData theme, bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20), // Align with circle
      color: isActive ? AppColors.deepTeal : Colors.grey[300],
    );
  }
}
