import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/core/error/failures.dart';
import 'package:darna/features/delivery/domain/entities/driver.dart';
import 'package:darna/features/delivery/domain/repositories/driver_repository.dart';
import 'package:darna/features/order/domain/entities/order.dart' as order_entity;

class FirestoreDriverRepository implements DriverRepository {
  final FirebaseFirestore _firestore;

  FirestoreDriverRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, Driver>> getDriverById(String id) async {
    try {
      final doc = await _firestore.collection('drivers').doc(id).get();
      
      if (!doc.exists) {
        return Left(ServerFailure('Driver not found'));
      }
      
      final driver = Driver.fromJson(doc.data()!);
      return Right(driver);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation(
    String driverId,
    LatLng location,
  ) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'currentLocation': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      });
      
      // Also update the driver's location in their active order
      final driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      final activeOrderId = driverDoc.data()?['activeOrderId'] as String?;
      
      if (activeOrderId != null) {
        await _firestore.collection('orders').doc(activeOrderId).update({
          'driverLocation': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
        });
      }
      
      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAvailability(
    String driverId,
    bool available,
  ) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'isAvailable': available,
      });
      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<order_entity.Order>>> getPendingOrders(
    LatLng driverLocation,
  ) async {
    try {
      // Get orders that are confirmed but not yet assigned to a driver
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'confirmed')
          .where('driverId', isNull: true)
          .limit(10)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => order_entity.OrderEntity.fromMap(doc.data()))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptOrder(
    String driverId,
    String orderId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update order with driver info
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {
        'driverId': driverId,
        'status': 'preparing',
        'driverAcceptedAt': DateTime.now().toIso8601String(),
      });

      // Update driver with active order
      final driverRef = _firestore.collection('drivers').doc(driverId);
      batch.update(driverRef, {
        'activeOrderId': orderId,
        'isAvailable': false,
      });

      await batch.commit();
      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    String status, {
    LatLng? driverLocation,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };

      if (status == 'pickedUp' || status == 'outForDelivery') {
        updateData['pickedUpAt'] = DateTime.now().toIso8601String();
      }

      if (driverLocation != null) {
        updateData['driverLocation'] = {
          'latitude': driverLocation.latitude,
          'longitude': driverLocation.longitude,
        };
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      // If order is delivered, free up the driver
      if (status == 'delivered') {
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        final driverId = orderDoc.data()?['driverId'] as String?;
        
        if (driverId != null) {
          await _firestore.collection('drivers').doc(driverId).update({
            'activeOrderId': null,
            'isAvailable': true,
          });
        }
      }

      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<LatLng?> streamDriverLocation(String driverId) {
    return _firestore
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data();
      final location = data?['currentLocation'];
      
      if (location == null) return null;
      
      return LatLng(
        location['latitude'] as double,
        location['longitude'] as double,
      );
    });
  }

  @override
  Future<Either<Failure, order_entity.Order?>> getActiveOrder(String driverId) async {
    try {
      final driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      final activeOrderId = driverDoc.data()?['activeOrderId'] as String?;
      
      if (activeOrderId == null) {
        return right(null);
      }
      
      final orderDoc = await _firestore.collection('orders').doc(activeOrderId).get();
      
      if (!orderDoc.exists) {
        return right(null);
      }
      
      final order = order_entity.OrderEntity.fromMap(orderDoc.data()!);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> setDriverAvailability(String driverId, bool isAvailable) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'isAvailable': isAvailable,
      });
      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, List<order_entity.Order>>> getCompletedOrders(String driverId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'delivered')
          .orderBy('createdAt', descending: true)
          .limit(20) // Limit to recent history for stats
          .get();

      final orders = querySnapshot.docs
          .map((doc) {
             final data = doc.data();
             data['id'] = doc.id;
             return order_entity.OrderEntity.fromMap(data);
          })
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
