import 'package:equatable/equatable.dart';

/// Product extra/customization option
class ProductExtra extends Equatable {
  final String id;
  final String name;
  final String nameFr;
  final double price;

  const ProductExtra({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, nameFr, price];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameFr': nameFr,
      'price': price,
    };
  }

  factory ProductExtra.fromMap(Map<String, dynamic> map) {
    return ProductExtra(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameFr: map['nameFr'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Product entity representing a menu item
class Product extends Equatable {
  final String id;
  final String name;
  final String nameFr;
  final String description;
  final String descriptionFr;
  final double price; // in DH
  final String imageUrl;
  final String categoryId;
  final bool isMoroccanSpecialty;
  final int calories;
  final int preparationTime; // in minutes
  final List<String> ingredients;
  final List<String> allergens;
  final List<ProductExtra> extras;
  final double rating;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.description,
    required this.descriptionFr,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.isMoroccanSpecialty = true,
    this.calories = 0,
    this.preparationTime = 0,
    this.ingredients = const [],
    this.allergens = const [],
    this.extras = const [],
    this.rating = 0.0,
    this.isAvailable = true,
  });

  /// Get localized name
  String getLocalizedName(String languageCode) {
    return languageCode == 'fr' ? nameFr : name;
  }

  /// Get localized description
  String getLocalizedDescription(String languageCode) {
    return languageCode == 'fr' ? descriptionFr : description;
  }

  /// Copy with method
  Product copyWith({
    String? id,
    String? name,
    String? nameFr,
    String? description,
    String? descriptionFr,
    double? price,
    String? imageUrl,
    String? categoryId,
    bool? isMoroccanSpecialty,
    int? calories,
    int? preparationTime,
    List<String>? ingredients,
    List<String>? allergens,
    List<ProductExtra>? extras,
    double? rating,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFr: nameFr ?? this.nameFr,
      description: description ?? this.description,
      descriptionFr: descriptionFr ?? this.descriptionFr,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      isMoroccanSpecialty: isMoroccanSpecialty ?? this.isMoroccanSpecialty,
      calories: calories ?? this.calories,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      extras: extras ?? this.extras,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameFr': nameFr,
      'description': description,
      'descriptionFr': descriptionFr,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'isMoroccanSpecialty': isMoroccanSpecialty,
      'calories': calories,
      'preparationTime': preparationTime,
      'ingredients': ingredients,
      'allergens': allergens,
      'extras': extras.map((x) => x.toMap()).toList(),
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameFr: map['nameFr'] ?? '',
      description: map['description'] ?? '',
      descriptionFr: map['descriptionFr'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      categoryId: map['categoryId'] ?? '',
      isMoroccanSpecialty: map['isMoroccanSpecialty'] ?? true,
      calories: map['calories']?.toInt() ?? 0,
      preparationTime: map['preparationTime']?.toInt() ?? 0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      allergens: List<String>.from(map['allergens'] ?? []),
      extras: (map['extras'] as List<dynamic>?)
              ?.map((x) => ProductExtra.fromMap(x))
              .toList() ??
          [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameFr,
        description,
        descriptionFr,
        price,
        imageUrl,
        categoryId,
        isMoroccanSpecialty,
        calories,
        preparationTime,
        ingredients,
        allergens,
        extras,
        rating,
        isAvailable,
      ];
}
