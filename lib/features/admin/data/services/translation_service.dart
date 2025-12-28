import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for translating text using Gemini API
class TranslationService {
  late final GenerativeModel _model;

  TranslationService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
  }

  /// Translate text from English to French
  Future<String> translateToFrench(String text) async {
    try {
      final prompt = '''
Translate the following text from English to French. 
Return ONLY the translation, no explanations or additional text.

Text to translate: "$text"
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final translation = response.text?.trim() ?? text;
      
      return translation;
    } catch (e) {
      debugPrint('Translation error: $e');
      rethrow;
    }
  }

  /// Translate text from French to English
  Future<String> translateToEnglish(String text) async {
    try {
      final prompt = '''
Translate the following text from French to English. 
Return ONLY the translation, no explanations or additional text.

Text to translate: "$text"
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final translation = response.text?.trim() ?? text;
      
      return translation;
    } catch (e) {
      debugPrint('Translation error: $e');
      rethrow;
    }
  }
}


