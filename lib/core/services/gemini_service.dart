import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:darna/features/product/domain/entities/product.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
    );
    
    _chat = _model.startChat();
    _isInitialized = true;
  }

  Future<String> sendMessage(String message, {List<Product>? products, String? userLocation, List<String>? favoriteItems}) async {
    if (!_isInitialized) await initialize();

    String contextPrompt = "";
    
    // Add User Location Context
    if (userLocation != null && userLocation.isNotEmpty) {
      contextPrompt += "\n[User Context] The user is located at: $userLocation. If they ask about delivery, tell them we deliver to their area (We serve both **Casablanca** and **Fès**).";
    }

    // Add User Favorites Context
    if (favoriteItems != null && favoriteItems.isNotEmpty) {
      contextPrompt += "\n[User Context] User's favorite dishes are: ${favoriteItems.join(', ')}. Recommend these or similar items if relevant.";
    }

    if (products != null && products.isNotEmpty) {
      contextPrompt += "\n\nAvailable Menu Items:\n";
      for (final product in products) {
        contextPrompt += "- ${product.name}: ${product.description} (${product.price} DH)\n";
      }
      contextPrompt += "\nSuggest items from this list if relevant.";
      contextPrompt += "\nIMPORTANT: We are a Halal restaurant. NEVER suggest alcohol (beer, wine, etc.), pork, or non-halal items. Respect Muslim dietary laws.";
      contextPrompt += "\nUse Markdown formatting: Use **bold** for dish names and prices. Use bullet points for lists. Be organized and concise.";
      
      // Cart Action Logic
      contextPrompt += "\n[CART FEATURE] If the user explicitly asks to order items or 'choose for me' and checkout, you can generate a Cart Action.";
      contextPrompt += "\nInstructions: Append the following JSON block at the very end of your response (hidden from user text):";
      contextPrompt += "\n<<<CART>>>{\"items\": [{\"name\": \"Exact Product Name\", \"quantity\": 1}]}<<<CART>>>";
      contextPrompt += "\nOnly do this if the user clearly wants to proceed with an order. If just discussing, do not output JSON.";
    }

    final content = Content.text(message + contextPrompt);
    final response = await _chat.sendMessage(content);
    return response.text ?? "I'm having trouble thinking right now.";
  }
}
