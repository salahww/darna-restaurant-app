import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:darna/core/services/gemini_service.dart';
import 'package:darna/features/ai/domain/entities/chat_message.dart';
import 'package:darna/features/product/presentation/providers/product_repository_provider.dart';
import 'package:darna/features/order/presentation/providers/location_provider.dart';
import 'package:darna/features/favorites/presentation/providers/favorites_provider.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return ChatNotifier(geminiService, ref);
});

final loadStateProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;
  final Ref _ref;
  final _uuid = const Uuid();

  ChatNotifier(this._geminiService, this._ref) : super([]) {
    clearChat();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    // Set loading state
    _ref.read(loadStateProvider.notifier).state = true;

    try {
      // creating context from products
      final productsResult = await _ref.read(productRepositoryProvider).getProducts();
      final products = productsResult.fold(
          (failure) => null,
          (productList) => productList
      );

      // Get User Location
      final locationState = _ref.read(locationProvider);
      final userAddress = locationState.address;
      
      // Get User Favorites
      final favoriteIds = _ref.read(favoritesProvider);
      List<String> favoriteNames = [];
      if (products != null) {
        favoriteNames = products
            .where((p) => favoriteIds.contains(p.id))
            .map((p) => p.name)
            .toList();
      }

      var responseText = await _geminiService.sendMessage(
        text, 
        products: products, 
        userLocation: userAddress != 'Select Location' ? userAddress : null,
        favoriteItems: favoriteNames
      );
      
      Map<String, dynamic>? cartAction;
      
      // Parse <<<CART>>> JSON
      if (responseText.contains('<<<CART>>>')) {
        try {
          final parts = responseText.split('<<<CART>>>');
          if (parts.length >= 3) {
             // parts[0] = text, parts[1] = json, parts[2] = empty/text
             responseText = parts[0].trim(); // Keep only the text part
             String jsonStr = parts[1].trim();
             cartAction = jsonDecode(jsonStr);
          }
        } catch (e) {
          debugPrint('Error parsing Cart JSON: $e');
        }
      }

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        cartAction: cartAction,
      );
      state = [...state, aiMessage];
    } catch (e) {
      final errorText = e.toString().contains('API_KEY') 
          ? "I'm missing my API key. Please add GEMINI_API_KEY to the .env file."
          : "Sorry, I'm having trouble connecting to the kitchen. ($e)";
      
      debugPrint('Gemini Chat Error: $e');

      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: errorText,
        isUser: false,
        timestamp: DateTime.now(),
      );
       state = [...state, errorMessage];
    } finally {
      _ref.read(loadStateProvider.notifier).state = false;
    }
  }

  void clearChat() {
    state = [
      ChatMessage(
        id: _uuid.v4(),
        text: "Salam! I'm your Darna AI chef. I can help you choose the perfect Moroccan dish or answer questions about our menu. What are you craving today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}
