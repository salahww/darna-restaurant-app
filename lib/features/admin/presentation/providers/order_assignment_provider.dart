import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/admin/data/services/order_assignment_service.dart';

/// Provider for order assignment service
final orderAssignmentServiceProvider = Provider<OrderAssignmentService>((ref) {
  return OrderAssignmentService();
});
