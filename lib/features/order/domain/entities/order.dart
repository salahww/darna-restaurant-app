import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:darna/features/cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  prepared, // New status: Food ready in kitchen
  pickedUp, // Renamed from outForDelivery
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.prepared: return 'Ready for Pickup';
      case OrderStatus.pickedUp: return 'Picked Up';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}

typedef Order = OrderEntity;

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String contactPhone;
  final DateTime createdAt;
  final String paymentMethod;
  
  // Driver-related fields
  final String? driverId;
  final LatLng? driverLocation;
  final DateTime? estimatedArrival;
  final DateTime? driverAcceptedAt;
  final DateTime? pickedUpAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.contactPhone,
    required this.createdAt,
    required this.paymentMethod,
    this.driverId,
    this.driverLocation,
    this.estimatedArrival,
    this.driverAcceptedAt,
    this.pickedUpAt,
  });

  bool get isCompleted => status == OrderStatus.delivered || status == OrderStatus.cancelled;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'deliveryAddress': deliveryAddress,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'driverId': driverId,
      'driverLocation': driverLocation != null
          ? {
              'latitude': driverLocation!.latitude,
              'longitude': driverLocation!.longitude,
            }
          : null,
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'driverAcceptedAt': driverAcceptedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
    };
  }

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    return OrderEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List?)
              ?.where((x) => x != null && x is Map)
              .map((x) => CartItem.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () {
            if (map['status'] == 'outForDelivery') return OrderStatus.pickedUp;
            return OrderStatus.pending;
          }),
      deliveryAddress: map['deliveryAddress'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      paymentMethod: map['paymentMethod'] ?? 'COD',
      driverId: map['driverId'] as String?,
      driverLocation: map['driverLocation'] != null
          ? LatLng(
              (map['driverLocation']['latitude'] as num).toDouble(),
              (map['driverLocation']['longitude'] as num).toDouble(),
            )
          : null,
      estimatedArrival: _parseNullableDateTime(map['estimatedArrival']),
      driverAcceptedAt: _parseNullableDateTime(map['driverAcceptedAt']),
      pickedUpAt: _parseNullableDateTime(map['pickedUpAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now(); // Default fallback or null handling? Ideally nullable. 
    // For createdAt we enforce non-null in entity but it's nullable in map logic above (defaulting to now).
    // Let's stick to returning DateTime? if allowed, but createdAt is required.
    
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    // Handle Firestore Timestamp
    if (value.runtimeType.toString() == 'Timestamp') {
      // Dynamic access to .toDate() since we don't import cloud_firestore here to keep clean architecture
      // reflection or just 'dynamic' call
      try {
        return (value as dynamic).toDate();
      } catch (_) {}
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value.runtimeType.toString() == 'Timestamp') {
      try {
        return (value as dynamic).toDate();
      } catch (_) {}
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        status,
        deliveryAddress,
        contactPhone,
        createdAt,
        paymentMethod,
        driverId,
        driverLocation,
        estimatedArrival,
        driverAcceptedAt,
        pickedUpAt,
      ];
}
