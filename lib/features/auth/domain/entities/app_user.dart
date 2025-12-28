import 'package:equatable/equatable.dart';

/// User roles in the system
enum UserRole {
  customer,
  driver,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.driver:
        return 'Delivery Driver';
      case UserRole.admin:
        return 'Restaurant Admin';
    }
  }
}

/// User entity representing customers, drivers, and restaurant admins
class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String preferredLanguage; // 'fr' or 'en'
  final List<String> favoriteProductIds;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    required this.role,
    this.preferredLanguage = 'fr',
    this.favoriteProductIds = const [],
    this.createdAt,
  });

  /// Check if user is a restaurant admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is a delivery driver
  bool get isDriver => role == UserRole.driver;

  /// Check if user is a customer
  bool get isCustomer => role == UserRole.customer;

  /// Legacy compatibility
  bool get isRestaurant => isAdmin;
  bool get isClient => isCustomer;

  /// Copy with method for immutability
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? preferredLanguage,
    List<String>? favoriteProductIds,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create from Firestore document
  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Parse createdAt - handle both String and Timestamp
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      final createdAtValue = json['createdAt'];
      if (createdAtValue is String) {
        parsedCreatedAt = DateTime.parse(createdAtValue);
      } else if (createdAtValue.toString().contains('Timestamp')) {
        // It's a Firestore Timestamp
        parsedCreatedAt = (createdAtValue as dynamic).toDate();
      }
    }
    
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'fr',
      favoriteProductIds: List<String>.from(json['favoriteProductIds'] ?? []),
      createdAt: parsedCreatedAt,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'preferredLanguage': preferredLanguage,
      'favoriteProductIds': favoriteProductIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        role,
        preferredLanguage,
        favoriteProductIds,
        createdAt,
      ];
}
