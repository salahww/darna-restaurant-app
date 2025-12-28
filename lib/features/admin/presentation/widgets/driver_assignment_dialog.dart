import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/delivery/domain/entities/driver.dart';
import 'package:darna/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:darna/features/admin/data/services/order_assignment_service.dart';
import 'package:darna/features/admin/presentation/providers/order_assignment_provider.dart';

class DriverAssignmentDialog extends ConsumerStatefulWidget {
  final String orderId;

  const DriverAssignmentDialog({super.key, required this.orderId});

  @override
  ConsumerState<DriverAssignmentDialog> createState() => _DriverAssignmentDialogState();
}

class _DriverAssignmentDialogState extends ConsumerState<DriverAssignmentDialog> {
  bool _isLoading = false;
  List<Driver> _drivers = [];
  bool _isFetchingDrivers = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    setState(() {
      _isFetchingDrivers = true;
      _error = null;
    });

    final result = await ref.read(driverRepositoryProvider).getAvailableDrivers();
    
    if (mounted) {
      result.fold(
        (failure) => setState(() => _error = failure.message),
        (drivers) => setState(() => _drivers = drivers),
      );
      setState(() => _isFetchingDrivers = false);
    }
  }

  Future<void> _assignDriver(String driverId) async {
    setState(() => _isLoading = true);
    
    // We reuse the acceptOrder method which assigns driver to order
    // It's effectively the same as "admin assigning driver"
    final result = await ref.read(driverRepositoryProvider).acceptOrder(driverId, widget.orderId);
    
    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: Colors.red),
        ),
        (_) {
          Navigator.of(context).pop(true); // Return success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver assigned successfully!'), backgroundColor: Colors.green),
          );
        },
      );
    }
  }
  
  Future<void> _autoAssign() async {
    setState(() => _isLoading = true);
    final success = await ref.read(orderAssignmentServiceProvider).autoAssignDriver(widget.orderId);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver auto-assigned successfully!'), backgroundColor: Colors.green),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to auto-assign. No drivers available?'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Driver'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 16),
            
            // Auto Assign Option
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _autoAssign,
                icon: const Icon(Icons.auto_mode),
                label: const Text('Auto-Assign Nearest Driver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 1),
            ),
            
            Text('Or Select Manually:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),

            // Drivers List
            Flexible(
              child: _isFetchingDrivers 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : _drivers.isEmpty 
                        ? const Center(child: Text('No available drivers found.'))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _drivers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final driver = _drivers[index];
                              return ListTile(
                                tileColor: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Theme.of(context).dividerColor),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.deepTeal.withOpacity(0.1),
                                  child: Icon(Icons.person, color: AppColors.deepTeal),
                                ),
                                title: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${driver.vehicleType} • ${driver.rating} ⭐'), 
                                trailing: ElevatedButton(
                                   onPressed: _isLoading ? null : () => _assignDriver(driver.id),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: AppColors.deepTeal,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   ),
                                   child: const Text('Assign'),
                                ),
                              );
                            },
                          ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
