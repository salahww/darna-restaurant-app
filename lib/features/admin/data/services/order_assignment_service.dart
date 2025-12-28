import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darna/features/delivery/domain/repositories/driver_repository.dart';
import 'package:darna/features/delivery/data/repositories/firestore_driver_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

/// Service for automatic order assignment to drivers
class OrderAssignmentService {
  final FirebaseFirestore _firestore;
  final DriverRepository _driverRepository;

  // Restaurant location (Darna - Fes)
  static const LatLng restaurantLocation = LatLng(34.0181, -5.0078);

  OrderAssignmentService({
    FirebaseFirestore? firestore,
    DriverRepository? driverRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _driverRepository = driverRepository ?? FirestoreDriverRepository();

  /// Automatically assign order to nearest available driver
  Future<bool> autoAssignDriver(String orderId) async {
    try {
      // Get order details first
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        debugPrint('Order not found');
        return false;
      }
      final orderData = orderDoc.data()!;
      final customerId = orderData['customerId'] as String? ?? 'unknown_customer';
      
      // Get available drivers
      final driversSnapshot = await _firestore
          .collection('drivers')
          .where('isAvailable', isEqualTo: true)
          .where('activeOrderId', isNull: true)
          .get();

      if (driversSnapshot.docs.isEmpty) {
        debugPrint('No available drivers found');
        return false;
      }

      // Find nearest driver to restaurant
      String? nearestDriverId;
      String? driverName;
      double minDistance = double.infinity;

      for (final doc in driversSnapshot.docs) {
        final data = doc.data();
        final location = data['currentLocation'];
        
        if (location != null) {
          final driverLocation = LatLng(
            (location['latitude'] as num).toDouble(),
            (location['longitude'] as num).toDouble(),
          );
          
          final distance = _calculateDistance(restaurantLocation, driverLocation);
          
          if (distance < minDistance) {
            minDistance = distance;
            nearestDriverId = doc.id;
            driverName = data['name'] as String?;
          }
        }
      }

      // If no driver has location, just pick the first one
      if (nearestDriverId == null) {
        nearestDriverId = driversSnapshot.docs.first.id;
        driverName = driversSnapshot.docs.first.data()['name'] as String?;
      }

      // Assign order to driver
      final result = await _driverRepository.acceptOrder(nearestDriverId, orderId);
      
      return result.fold(
        (failure) {
          debugPrint('Failed to assign driver: ${failure.message}');
          return false;
        },
        (_) async {
          debugPrint('Order $orderId assigned to driver $nearestDriverId');
          
          // Import notification helper locally to avoid circular dependencies
          // Notify customer about driver assignment
          debugPrint('📤 Notifying customer $customerId about driver assignment');
          debugPrint('📤 Notifying driver $nearestDriverId about new order');
          
          // TODO: Add actual notification calls here
          // This requires importing order_notification_helper
          // await OrderNotificationHelper.notifyDriverAssignment(...);
          
          return true;
        },
      );
    } catch (e) {
      debugPrint('Error auto-assigning driver: $e');
      return false;
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km

    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final dLat = (point2.latitude - point1.latitude) * pi / 180;
    final dLon = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}


