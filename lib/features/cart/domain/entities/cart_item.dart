import 'package:darna/features/product/domain/entities/product.dart';

/// Cart item entity representing a product with selected customizations
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String portionSize; // 'individual', 'sharing', 'family'
  final String spiceLevel; // 'mild', 'medium', 'spicy'
  final List<String> addons;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.portionSize,
    required this.spiceLevel,
    required this.addons,
  });

  /// Calculate subtotal based on quantity and selected options
  double get subtotal {
    double basePrice = product.price;
    
    // Add portion size multiplier
    double portionMultiplier = 1.0;
    switch (portionSize) {
      case 'sharing':
        portionMultiplier = 1.5;
        break;
      case 'family':
        portionMultiplier = 2.5;
        break;
      default:
        portionMultiplier = 1.0;
    }
    
    // Add-on prices (each add-on adds 15 MAD)
    double addonPrice = addons.length * 15.0;
    
    return (basePrice * portionMultiplier + addonPrice) * quantity;
  }

  /// Get formatted options summary
  String get optionsSummary {
    final parts = <String>[];
    
    // Portion size
    parts.add(portionSize[0].toUpperCase() + portionSize.substring(1));
    
    // Spice level
    if (spiceLevel != 'mild') {
      parts.add(spiceLevel[0].toUpperCase() + spiceLevel.substring(1));
    }
    
    // Add-ons
    if (addons.isNotEmpty) {
      parts.add('+ ${addons.length} add-on${addons.length > 1 ? 's' : ''}');
    }
    
    return parts.join(' • ');
  }

  /// Create a copy with modified fields
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? portionSize,
    String? spiceLevel,
    List<String>? addons,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      portionSize: portionSize ?? this.portionSize,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      addons: addons ?? this.addons,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CartItem &&
        other.id == id &&
        other.product == product &&
        other.quantity == quantity &&
        other.portionSize == portionSize &&
        other.spiceLevel == spiceLevel &&
        _listEquals(other.addons, addons);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      product,
      quantity,
      portionSize,
      spiceLevel,
      addons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(), // Assuming Product has toMap
      'quantity': quantity,
      'portionSize': portionSize,
      'spiceLevel': spiceLevel,
      'addons': addons,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      product: Product.fromMap(
          map['product'] != null && map['product'] is Map
              ? Map<String, dynamic>.from(map['product'])
              : {}),
      quantity: map['quantity']?.toInt() ?? 1,
      portionSize: map['portionSize'] ?? 'individual',
      spiceLevel: map['spiceLevel'] ?? 'mild',
      addons: List<String>.from(map['addons'] ?? []),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
