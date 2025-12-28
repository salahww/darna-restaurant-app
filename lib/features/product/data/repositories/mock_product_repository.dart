import 'package:darna/features/product/domain/repositories/product_repository.dart';
import 'package:darna/features/product/domain/entities/product.dart';
import 'package:darna/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800)); 
    return right(_mockProducts);
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final products = _mockProducts.where((p) => p.categoryId == categoryId).toList();
    return right(products);
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final product = _mockProducts.firstWhere((p) => p.id == id);
      return right(product);
    } catch (e) {
      return left(ServerFailure('Product not found'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();
    final results = _mockProducts.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) || 
      p.description.toLowerCase().contains(lowerQuery)
    ).toList();
    return right(results);
  }

  @override
  Stream<List<Product>> watchProducts() {
    return Stream.value(_mockProducts);
  }

  @override
  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return Stream.value(
      _mockProducts.where((p) => p.categoryId == categoryId).toList()
    );
  }

  // --- Admin Stubs ---
  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    return left(ServerFailure('Mock: Create not supported'));
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    return left(ServerFailure('Mock: Update not supported'));
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    return left(ServerFailure('Mock: Delete not supported'));
  }

  @override
  Future<Either<Failure, String>> uploadProductImage({required String productId, required String imagePath}) async {
    return left(ServerFailure('Mock: Upload not supported'));
  }

  Future<Either<Failure, List<String>>> getCategories() async {
    return right(['Starters', 'Tagines', 'Couscous', 'Pastilla', 'Grills', 'Drinks', 'Desserts']);
  }
  
  Future<Either<Failure, List<Product>>> getPopularProducts() async {
    // Return a mix of top rated items
    return right(_mockProducts.where((p) => p.rating >= 4.9).take(6).toList());
  }

  static final List<Product> _mockProducts = [
    // ================== STARTERS (5 items) ==================
    const Product(
      id: 's1',
      name: 'Harira Soup',
      nameFr: 'Harira',
      description: 'Classic hearty tomato, lentil, and chickpea soup served with dates.',
      descriptionFr: 'Soupe traditionnelle aux tomates, lentilles et pois chiches.',
      price: 30.0,
      imageUrl: 'assets/images/products/harira_soup.png',
      categoryId: 'Starters',
      rating: 4.8,
      calories: 250,
      preparationTime: 10,
      ingredients: ['Tomatoes', 'Lentils', 'Chickpeas', 'Celery', 'Coriander'],
      isAvailable: true,
    ),
    const Product(
      id: 's2',
      name: 'Briouat Chicken',
      nameFr: 'Briouates Poulet',
      description: 'Crispy pastry triangles stuffed with spiced chicken and vermicelli.',
      descriptionFr: 'Triangles croustillants au poulet et vermicelles.',
      price: 45.0,
      imageUrl: 'assets/images/products/briouat_chicken.png',
      categoryId: 'Starters',
      rating: 4.7,
      calories: 420,
      preparationTime: 15,
      ingredients: ['Pastry', 'Chicken', 'Vemicelli', 'Spices'],
      isAvailable: true,
    ),
    const Product(
      id: 's3',
      name: 'Zaalouk',
      nameFr: 'Zaalouk',
      description: 'Roasted eggplant and tomato salad cooked with olive oil and garlic.',
      descriptionFr: 'Salade d\'aubergines et tomates confites.',
      price: 25.0,
      imageUrl: 'assets/images/products/zaalouk.png',
      categoryId: 'Starters',
      rating: 4.6,
      calories: 180,
      preparationTime: 10,
      ingredients: ['Eggplant', 'Tomato', 'Garlic', 'Olive Oil', 'Cumin'],
      isAvailable: true,
    ),
    const Product(
      id: 's4',
      name: 'Taktouka',
      nameFr: 'Taktouka',
      description: 'Cooked salad of roasted green peppers and tomatoes.',
      descriptionFr: 'Salade cuite de poivrons et tomates.',
      price: 25.0,
      imageUrl: 'assets/images/products/taktouka.png',
      categoryId: 'Starters',
      rating: 4.5,
      calories: 150,
      preparationTime: 10,
      ingredients: ['Green Peppers', 'Tomatoes', 'Garlic', 'Paprika'],
      isAvailable: true,
    ),
    const Product(
      id: 's5',
      name: 'Moroccan Salad',
      nameFr: 'Salade Marocaine',
      description: 'Finely chopped tomatoes, cucumber, and onions with vinaigrette.',
      descriptionFr: 'Tomates, concombres et oignons finement coupés.',
      price: 20.0,
      imageUrl: 'assets/images/products/moroccan_salad.png',
      categoryId: 'Starters',
      rating: 4.4,
      calories: 100,
      preparationTime: 10,
      ingredients: ['Tomato', 'Cucumber', 'Onion', 'Parsley'],
      isAvailable: true,
    ),

    // ================== TAGINES (5 items) ==================
    const Product(
      id: 't1',
      name: 'Lamb Tagine Prunes',
      nameFr: 'Tagine Agneau Pruneaux',
      description: 'Tender lamb slow-cooked with prunes, toasted almonds, and sesame seeds.',
      descriptionFr: 'Agneau tendre mijoté aux pruneaux et amandes.',
      price: 120.0,
      imageUrl: 'assets/images/products/lamb_tagine_prunes.png',
      categoryId: 'Tagines',
      rating: 4.9,
      calories: 850,
      preparationTime: 45,
      ingredients: ['Lamb', 'Prunes', 'Almonds', 'Onions', 'Sesame'],
      isAvailable: true,
    ),
    const Product(
      id: 't2',
      name: 'Chicken Lemon Tagine',
      nameFr: 'Tagine Poulet Citron',
      description: 'Roasted chicken with preserved lemons and olives in a ginger saffron sauce.',
      descriptionFr: 'Poulet rôti aux citrons confits et olives.',
      price: 95.0,
      imageUrl: 'assets/images/products/chicken_lemon_tagine.png',
      categoryId: 'Tagines',
      rating: 4.7,
      calories: 720,
      preparationTime: 40,
      ingredients: ['Chicken', 'Olives', 'Confited Lemon', 'Saffron', 'Ginger'],
      isAvailable: true,
    ),
    const Product(
      id: 't3',
      name: 'Kefta Tagine',
      nameFr: 'Tagine Kefta',
      description: 'Seasoned meatballs in rich tomato sauce topped with poached eggs.',
      descriptionFr: 'Boulettes de viande sauce tomate et œufs.',
      price: 85.0,
      imageUrl: 'assets/images/products/kefta_tagine.png',
      categoryId: 'Tagines',
      rating: 4.8,
      calories: 650,
      preparationTime: 30,
      ingredients: ['Beef Mince', 'Tomato', 'Eggs', 'Cumin', 'Paprika'],
      isAvailable: true,
    ),
    const Product(
      id: 't4',
      name: 'Vegetable Tagine',
      nameFr: 'Tagine Légumes',
      description: 'Assortment of seasonal vegetables slow-cooked in a clay pot.',
      descriptionFr: 'Mélange de légumes de saison mijotés.',
      price: 70.0,
      imageUrl: 'assets/images/products/vegetable_tagine.png',
      categoryId: 'Tagines',
      rating: 4.5,
      calories: 450,
      preparationTime: 35,
      ingredients: ['Potatoes', 'Carrots', 'Peas', 'Zucchini', 'Turnips'],
      isAvailable: true,
    ),
    const Product(
      id: 't5',
      name: 'Fish Tagine',
      nameFr: 'Tagine de Poisson',
      description: 'White fish fillet marinated in charmoula with peppers and potatoes.',
      descriptionFr: 'Filet de poisson mariné à la charmoula.',
      price: 110.0,
      imageUrl: 'assets/images/products/fish_tagine.png',
      categoryId: 'Tagines',
      rating: 4.6,
      calories: 550,
      preparationTime: 30,
      ingredients: ['White Fish', 'Bell Peppers', 'Tomatoes', 'Potatoes', 'Charmoula'],
      isAvailable: true,
    ),

    // ================== COUSCOUS (5 items) ==================
    const Product(
      id: 'c1',
      name: 'Royal Couscous',
      nameFr: 'Couscous Royal',
      description: 'The ultimate Friday feast with lamb, chicken, merguez, and 7 vegetables.',
      descriptionFr: 'Le festin ultime avec agneau, poulet, merguez et 7 légumes.',
      price: 150.0,
      imageUrl: 'assets/images/products/royal_couscous.png',
      categoryId: 'Couscous',
      rating: 5.0,
      calories: 950,
      preparationTime: 60,
      ingredients: ['Semolina', 'Lamb', 'Chicken', 'Merguez', 'Carrots', 'Zucchini', 'Pumpkin'],
      isAvailable: true,
    ),
    const Product(
      id: 'c2',
      name: 'Couscous Tfaya',
      nameFr: 'Couscous Tfaya',
      description: 'Sweet and savory couscous with caramelized onions, raisins and cinnamon.',
      descriptionFr: 'Couscous sucré-salé aux oignons caramélisés et raisins secs.',
      price: 110.0,
      imageUrl: 'assets/images/products/couscous_tfaya.png',
      categoryId: 'Couscous',
      rating: 4.9,
      calories: 820,
      preparationTime: 50,
      ingredients: ['Semolina', 'Chicken/Lamb', 'Onions', 'Raisins', 'Cinnamon', 'Almonds'],
      isAvailable: true,
    ),
    const Product(
      id: 'c3',
      name: 'Vegetable Couscous',
      nameFr: 'Couscous Légumes',
      description: 'Light and fluffy couscous topped with seven fresh garden vegetables.',
      descriptionFr: 'Couscous aux sept légumes frais.',
      price: 80.0,
      imageUrl: 'assets/images/products/vegetable_couscous.png',
      categoryId: 'Couscous',
      rating: 4.6,
      calories: 540,
      preparationTime: 40,
      ingredients: ['Semolina', 'Carrots', 'Turnips', 'Pumpkin', 'Cabbage', 'Zucchini', 'Chickpeas'],
      isAvailable: true,
    ),
    const Product(
      id: 'c4',
      name: 'Belboula Couscous',
      nameFr: 'Couscous Belboula',
      description: 'Healthy barley couscous served with vegetables and dried meat (Gueddid).',
      descriptionFr: 'Couscous d\'orge aux légumes.',
      price: 90.0,
      imageUrl: 'assets/images/products/belboula_couscous.png',
      categoryId: 'Couscous',
      rating: 4.7,
      calories: 600,
      preparationTime: 50,
      ingredients: ['Barley Semolina', 'Vegetables', 'Olive Oil'],
      isAvailable: true,
    ),
    const Product(
      id: 'c5',
      name: 'Chicken Couscous',
      nameFr: 'Couscous Poulet',
      description: 'Delicious couscous with farm chicken and vegetables.',
      descriptionFr: 'Couscous au poulet fermier et légumes.',
      price: 100.0,
      imageUrl: 'assets/images/products/chicken_couscous.png',
      categoryId: 'Couscous',
      rating: 4.8,
      calories: 750,
      preparationTime: 45,
      ingredients: ['Semolina', 'Chicken', 'Vegetables', 'Smen'],
      isAvailable: true,
    ),

    // ================== PASTILLA (5 items) ==================
    const Product(
      id: 'p1',
      name: 'Chicken Pastilla',
      nameFr: 'Pastilla Poulet',
      description: 'Famous sweet and savory pie with chicken, almonds, and phyllo dough.',
      descriptionFr: 'Tourte sucrée-salée au poulet et amandes.',
      price: 130.0,
      imageUrl: 'assets/images/products/chicken_pastilla.png',
      categoryId: 'Pastilla',
      rating: 5.0,
      calories: 850,
      preparationTime: 40,
      ingredients: ['Phyllo', 'Chicken', 'Almonds', 'Sugar', 'Cinnamon', 'Eggs'],
      isAvailable: true,
    ),
    const Product(
      id: 'p2',
      name: 'Seafood Pastilla',
      nameFr: 'Pastilla Fruits de Mer',
      description: 'Spicy savory pie filled with shrimp, calamari, white fish and vermicelli.',
      descriptionFr: 'Pastilla aux fruits de mer et vermicelles.',
      price: 150.0,
      imageUrl: 'assets/images/products/seafood_pastilla.png',
      categoryId: 'Pastilla',
      rating: 4.9,
      calories: 780,
      preparationTime: 40,
      ingredients: ['Phyllo', 'Shrimp', 'Calamari', 'Fish', 'Vermicelli', 'Harissa'],
      isAvailable: true,
    ),
    const Product(
      id: 'p3',
      name: 'Minced Meat Pastilla',
      nameFr: 'Pastilla Viande Hachée',
      description: 'Crispy pie filled with seasoned ground beef and cheese.',
      descriptionFr: 'Pastilla à la viande hachée.',
      price: 120.0,
      imageUrl: 'assets/images/products/meat_pastilla.png',
      categoryId: 'Pastilla',
      rating: 4.7,
      calories: 800,
      preparationTime: 35,
      ingredients: ['Phyllo', 'Ground Beef', 'Onions', 'Cheese'],
      isAvailable: true,
    ),
    const Product(
      id: 'p4',
      name: 'Vegetable Pastilla',
      nameFr: 'Pastilla Légumes',
      description: 'Vegetarian version with sautéed vegetables and goat cheese.',
      descriptionFr: 'Pastilla végétarienne au fromage de chèvre.',
      price: 90.0,
      imageUrl: 'assets/images/products/vegetable_pastilla.png',
      categoryId: 'Pastilla',
      rating: 4.5,
      calories: 600,
      preparationTime: 35,
      ingredients: ['Phyllo', 'Spinach', 'Cheese', 'Mushrooms'],
      isAvailable: true,
    ),
    const Product(
      id: 'p5',
      name: 'Mini Pastillas Trio',
      nameFr: 'Trio Mini Pastillas',
      description: 'Assortment of 3 mini pastillas: Chicken, Seafood, and Cheese.',
      descriptionFr: 'Assortiment de 3 mini pastillas.',
      price: 100.0,
      imageUrl: 'assets/images/products/mini_pastillas.png',
      categoryId: 'Pastilla',
      rating: 4.8,
      calories: 700,
      preparationTime: 30,
      ingredients: ['Asscription', 'Mixed'],
      isAvailable: true,
    ),

    // ================== GRILLS (5 items) ==================
    const Product(
      id: '7', // Kept original ID for reference
      name: 'CAN 2025 Match Platter',
      nameFr: 'Plateau Match CAN 2025',
      description: 'Review the match with our special BBQ platter! Includes lamb chops, kofta skewers, and merguez.',
      descriptionFr: 'Plateau BBQ spécial !',
      price: 250.0,
      imageUrl: 'assets/images/products/match_platter.png',
      categoryId: 'Grills',
      rating: 5.0,
      calories: 1200,
      preparationTime: 25,
      ingredients: ['Lamb Chops', 'Kofta', 'Merguez', 'Fries', 'Salad'],
      isAvailable: true,
    ),
    const Product(
      id: 'g1',
      name: 'Mixed Grill',
      nameFr: 'Grillade Mixte',
      description: 'Assortiment de brochettes et kefta.',
      descriptionFr: 'Assortiment de brochettes et kefta.',
      price: 140.0,
      imageUrl: 'assets/images/products/mixed_grill.png',
      categoryId: 'Grills',
      rating: 4.8,
      calories: 890,
      preparationTime: 20,
      ingredients: ['Beef', 'Chicken', 'Kefta', 'Onions'],
      isAvailable: true,
    ),
    const Product(
      id: 'g2',
      name: 'Lamb Chops',
      nameFr: 'Côtelettes d\'Agneau',
      description: 'Succulent lamb chops grilled with cumin and fresh herbs.',
      descriptionFr: 'Côtelettes d\'agneau grillées au cumin.',
      price: 160.0,
      imageUrl: 'assets/images/products/lamb_chops.png',
      categoryId: 'Grills',
      rating: 4.9,
      calories: 750,
      preparationTime: 20,
      ingredients: ['Lamb Chops', 'Cumin', 'Parsley', 'Paprika'],
      isAvailable: true,
    ),
    const Product(
      id: 'g3',
      name: 'Chicken Skewers',
      nameFr: 'Brochettes de Poulet',
      description: 'Marinated chicken breast skewers grilled to perfection.',
      descriptionFr: 'Brochettes de poitrine de poulet marinées.',
      price: 90.0,
      imageUrl: 'assets/images/products/chicken_skewers.png',
      categoryId: 'Grills',
      rating: 4.7,
      calories: 550,
      preparationTime: 15,
      ingredients: ['Chicken Breast', 'Lemon', 'Garlic', 'Spices'],
      isAvailable: true,
    ),
    const Product(
      id: 'g4',
      name: 'Liver Skewers',
      nameFr: 'Boulfaf',
      description: 'Traditional grilled liver wrapped in fat lace (crépine). A delicacy.',
      descriptionFr: 'Foie grillé enveloppé de crépine.',
      price: 110.0,
      imageUrl: 'assets/images/products/liver_skewers.png',
      categoryId: 'Grills',
      rating: 4.8,
      calories: 650,
      preparationTime: 20,
      ingredients: ['Liver', 'Fat Lace', 'Salt', 'Cumin'],
      isAvailable: true,
    ),

    // ================== DRINKS (5 items) ==================
    const Product(
      id: 'd1',
      name: 'Avocado Smoothie',
      nameFr: 'Jus d\'Avocat',
      description: 'Rich and creamy Moroccon Avocado juice blended with milk and topped with almonds and honey.',
      descriptionFr: 'Jus d\'avocat onctueux au lait, amandes et miel.',
      price: 35.0,
      imageUrl: 'assets/images/products/avocado_smoothie.png',
      categoryId: 'Drinks',
      rating: 4.9,
      calories: 320,
      preparationTime: 5,
      ingredients: ['Avocado', 'Milk', 'Almonds', 'Honey'],
      isAvailable: true,
    ),
    const Product(
      id: 'd2',
      name: 'Moroccan Mint Tea',
      nameFr: 'Thé à la Menthe',
      description: 'Traditional gunpowder tea with fresh mint leaves and sugar. Small Pot.',
      descriptionFr: 'Thé vert traditionnel à la menthe. Petite théière.',
      price: 20.0,
      imageUrl: 'assets/images/products/mint_tea.png',
      categoryId: 'Drinks',
      rating: 4.8,
      calories: 120,
      preparationTime: 10,
      ingredients: ['Green Tea', 'Fresh Mint', 'Sugar', 'Water'],
      isAvailable: true,
    ),
    const Product(
      id: 'd3',
      name: 'Orange Juice',
      nameFr: 'Jus d\'Orange',
      description: 'Freshly squeezed Moroccan oranges, naturally sweet.',
      descriptionFr: 'Oranges marocaines fraîchement pressées.',
      price: 25.0,
      imageUrl: 'assets/images/products/orange_juice.png',
      categoryId: 'Drinks',
      rating: 4.7,
      calories: 110,
      preparationTime: 5,
      ingredients: ['Oranges'],
      isAvailable: true,
    ),
    const Product(
      id: 'd4',
      name: 'Panaché',
      nameFr: 'Panaché',
      description: 'Mixed fruit smoothie with apple, banana, and orange juice.',
      descriptionFr: 'Smoothie aux fruits mélangés.',
      price: 30.0,
      imageUrl: 'assets/images/products/panache.png',
      categoryId: 'Drinks',
      rating: 4.6,
      calories: 210,
      preparationTime: 8,
      ingredients: ['Milk', 'Banana', 'Apple', 'Orange'],
      isAvailable: true,
    ),
    const Product(
      id: 'd5',
      name: 'Nous Nous Coffee',
      nameFr: 'Café Nous Nous',
      description: 'Half milk, half espresso coffee. A Moroccan classic.',
      descriptionFr: 'Moitié lait, moitié expresso.',
      price: 18.0,
      imageUrl: 'assets/images/products/nous_nous.png',
      categoryId: 'Drinks',
      rating: 4.8,
      calories: 80,
      preparationTime: 5,
      ingredients: ['Espresso', 'Milk'],
      isAvailable: true,
    ),

    // ================== DESSERTS (5 items) ==================
    const Product(
      id: 'de1',
      name: 'Pastilla au Lait',
      nameFr: 'Pastilla au Lait',
      description: 'Crispy fried pastry layers with custard cream, toasted almonds, and orange blossom.',
      descriptionFr: 'Couches de pâte croustillante à la crème et amandes.',
      price: 50.0,
      imageUrl: 'assets/images/products/pastilla_lait.png',
      categoryId: 'Desserts',
      rating: 4.9,
      calories: 550,
      preparationTime: 15,
      ingredients: ['Pastry', 'Milk', 'Almonds', 'Orange Blossom'],
      isAvailable: true,
    ),
    const Product(
      id: 'de2',
      name: 'Sliced Oranges',
      nameFr: 'Oranges à la Cannelle',
      description: 'Simple sliced oranges with cinnamon and sugar.',
      descriptionFr: 'Oranges tranchées à la cannelle.',
      price: 20.0,
      imageUrl: 'assets/images/products/orange_cinnamon.png',
      categoryId: 'Desserts',
      rating: 4.5,
      calories: 120,
      preparationTime: 5,
      ingredients: ['Oranges', 'Cinnamon', 'Sugar'],
      isAvailable: true,
    ),
    const Product(
      id: 'de3',
      name: 'Chebakia Plate',
      nameFr: 'Assiette Chebakia',
      description: 'Honey-coated sesame cookies, traditionally served with Harira.',
      descriptionFr: 'Gâteaux au sésame enrobés de miel.',
      price: 35.0,
      imageUrl: 'assets/images/products/chebakia.png',
      categoryId: 'Desserts',
      rating: 4.7,
      calories: 450,
      preparationTime: 0,
      ingredients: ['Flour', 'Sesame', 'Honey', 'Anise'],
      isAvailable: true,
    ),
    const Product(
      id: 'de4',
      name: 'Moroccan Cookies',
      nameFr: 'Duo Ghriba & Fekkas',
      description: 'Duo of traditional Moroccan cookies (Ghriba and Fekkas).',
      descriptionFr: 'Duo de gâteaux marocains.',
      price: 30.0,
      imageUrl: 'assets/images/products/moroccan_cookies.png',
      categoryId: 'Desserts',
      rating: 4.6,
      calories: 380,
      preparationTime: 0,
      ingredients: ['Almonds', 'Flour', 'Sugar', 'Butter'],
      isAvailable: true,
    ),
    const Product(
      id: 'de5',
      name: 'Sellou',
      nameFr: 'Sellou',
      description: 'Nutty, unbaked sweet made from toasted flour, sesame seeds, and almonds.',
      descriptionFr: 'Mélange énergétique de farine grillée, sésame et amandes.',
      price: 45.0,
      imageUrl: 'assets/images/products/sellou.png',
      categoryId: 'Desserts',
      rating: 4.8,
      calories: 600,
      preparationTime: 0,
      ingredients: ['Flour', 'Sesame', 'Almonds', 'Honey'],
      isAvailable: true,
    ),
  ];
}
