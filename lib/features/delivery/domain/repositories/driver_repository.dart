import 'package:fpdart/fpdart.dart' hide Order;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/core/error/failures.dart';
import 'package:darna/features/delivery/domain/entities/driver.dart';
import 'package:darna/features/order/domain/entities/order.dart' as order_entity;

/// Repository interface for driver-related operations
abstract class DriverRepository {
  /// Get driver by ID
  Future<Either<Failure, Driver>> getDriverById(String id);

  /// Update driver's current location
  Future<Either<Failure, void>> updateLocation(String driverId, LatLng location);

  /// Update driver's availability status
  Future<Either<Failure, void>> updateAvailability(String driverId, bool available);

  /// Get pending orders near driver's location
  Future<Either<Failure, List<order_entity.Order>>> getPendingOrders(LatLng driverLocation);

  /// Accept an order
  Future<Either<Failure, void>> acceptOrder(String driverId, String orderId);

  /// Update order status (picked up, on the way, delivered)
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    String status, {
    LatLng? driverLocation,
  });

  /// Stream driver location updates
  Stream<LatLng?> streamDriverLocation(String driverId);

  /// Get driver's active order
  Future<Either<Failure, order_entity.Order?>> getActiveOrder(String driverId);

  /// Set driver availability
  Future<Either<Failure, void>> setDriverAvailability(String driverId, bool isAvailable);

  /// Get completed orders for stats
  Future<Either<Failure, List<order_entity.Order>>> getCompletedOrders(String driverId);
}
