import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a delivery driver in the system
class Driver {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleType; // 'motorcycle', 'car', 'bicycle'
  final String licensePlate;
  final bool isAvailable;
  final LatLng? currentLocation;
  final String? activeOrderId;
  final double rating;
  final int totalDeliveries;
  final String? profilePictureUrl; // Profile picture from Firebase Storage

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.licensePlate,
    required this.isAvailable,
    this.currentLocation,
    this.activeOrderId,
    required this.rating,
    required this.totalDeliveries,
    this.profilePictureUrl,
  });

  /// Create Driver from Firestore document
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      vehicleType: json['vehicleType'] as String,
      licensePlate: json['licensePlate'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool,
      currentLocation: json['currentLocation'] != null
          ? LatLng(
              json['currentLocation']['latitude'] as double,
              json['currentLocation']['longitude'] as double,
            )
          : null,
      activeOrderId: json['activeOrderId'] as String?,
      rating: (json['rating'] as num).toDouble(),
      totalDeliveries: json['totalDeliveries'] as int,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  /// Convert Driver to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'isAvailable': isAvailable,
      'currentLocation': currentLocation != null
          ? {
              'latitude': currentLocation!.latitude,
              'longitude': currentLocation!.longitude,
            }
          : null,
      'activeOrderId': activeOrderId,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  /// Create a copy with updated fields
  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? vehicleType,
    String? licensePlate,
    bool? isAvailable,
    LatLng? currentLocation,
    String? activeOrderId,
    double? rating,
    int? totalDeliveries,
    String? profilePictureUrl,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLocation: currentLocation ?? this.currentLocation,
      activeOrderId: activeOrderId ?? this.activeOrderId,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
