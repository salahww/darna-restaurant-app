/// Application-wide constants for the Darna restaurant app
class AppConstants {
  // ========== API KEYS ==========
  
  /// Gemini AI API Key
  static const String geminiApiKey = 'AIzaSyDqNIGvy8JeofNSydi29PXxCU4wv8wqbAU';
  
  /// Google Maps API Key
  static const String googleMapsApiKey = 'AIzaSyAcGHat5hpQeSZBhDgHPauf2_1uJBOyDIs';

  // ========== FIREBASE CONFIG ==========
  
  /// Firebase API Key
  static const String firebaseApiKey = 'AIzaSyB_Ts-oQ72JcpmIrKEEEKuezfruEEpJC9I';
  
  static const String firebaseAppId = '1:181903209686:web:21decbb4f351d8d7f80577';
  
  static const String firebaseMessagingSenderId = '181903209686';
  
  static const String firebaseProjectId = 'glclon';
  
  static const String firebaseAuthDomain = 'glclon.firebaseapp.com';
  
  static const String firebaseStorageBucket = 'glclon.firebasestorage.app';
  
  static const String firebaseMeasurementId = 'G-G9SZ9Y00ND';

  // ========== RESTAURANT INFO ==========
  
  /// Restaurant name in English
  static const String restaurantName = 'Darna';
  
  /// Restaurant name in Arabic
  static const String restaurantNameArabic = 'دارنا';
  
  /// Restaurant tagline
  static const String restaurantTagline = 'Our Home is Your Home';

  // ========== CURRENCY ==========
  
  /// Currency code
  static const String currency = 'DH';
  
  /// Currency symbol
  static const String currencySymbol = 'DH';
  
  /// Alternative currency symbol in Arabic
  static const String currencySymbolArabic = 'د.م.';

  // ========== PRICING ==========
  
  /// Delivery fee in DH
  static const double deliveryFee = 15.0;
  
  /// Minimum order amount in DH
  static const double minimumOrderAmount = 50.0;

  // ========== ADMIN CREDENTIALS ==========
  
  /// Admin email for restaurant management
  static const String adminEmail = 'admin@darna.ma';
  
  /// Admin password (Note: In production, this should not be hardcoded)
  static const String adminPassword = 'DarnaAdmin2024!';
  
  /// Restaurant role identifier
  static const String restaurantRole = 'restaurant';
  
  /// Client role identifier
  static const String clientRole = 'client';

  // ========== RESTAURANT DETAILS ==========
  
  /// Restaurant operating hours
  static const String operatingHours = '11:00 - 23:00 daily';
  
  /// Delivery area
  static const String deliveryArea = 'Casablanca area';
  
  /// Estimated delivery time
  static const String estimatedDeliveryTime = '30-60 min';
  
  /// Restaurant cuisine type
  static const String cuisineType = 'Traditional Moroccan';

  // ========== APP SETTINGS ==========
  
  /// Default language code
  static const String defaultLanguage = 'fr';
  
  /// Supported language codes
  static const List<String> supportedLanguages = ['fr', 'en'];
  
  /// Animation duration in milliseconds
  static const int animationDurationMs = 300;
  
  /// Shimmer loading duration in milliseconds
  static const int shimmerDurationMs = 1500;

  // ========== FIRESTORE COLLECTIONS ==========
  
  static const String restaurantCollection = 'restaurant';
  static const String categoriesCollection = 'categories';
  static const String productsCollection = 'products';
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
  static const String chatHistoryCollection = 'chat_history';

  // ========== GEMINI AI CONFIG ==========
  
  /// System prompt for Gemini AI chatbot
  static const String geminiSystemPrompt = '''
You are Darna's friendly AI assistant. You help customers discover authentic Moroccan cuisine.

Restaurant Info:
- Name: Darna (دارنا)
- Cuisine: Traditional Moroccan
- Hours: 11:00 - 23:00 daily
- Delivery: Casablanca area, 30-60 min
- Currency: Moroccan Dirham (DH)

You have access to the menu data from Firestore. Be warm, helpful, and recommend dishes based on user preferences.
If asked about orders, check the user's order history.
Always respond in the user's language (French or English).
Use emojis sparingly to make conversations friendly and engaging.
''';

  // ========== ASSET PATHS ==========
  
  static const String logoLightPath = 'assets/images/logo_light.png';
  static const String logoDarkPath = 'assets/images/logo_dark.png';
  static const String productsPath = 'assets/images/products/';

  // Private constructor to prevent instantiation
  AppConstants._();
}
