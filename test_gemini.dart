import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('--- Gemini API Test ---');

  // 1. Read .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Error: .env file not found at ${envFile.absolute.path}');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (final line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  // 2. Validate Key
  if (apiKey == null || apiKey.isEmpty || apiKey.contains('YOUR_API_KEY')) {
    print('❌ Error: API Key not found or is placeholder in .env');
    print('Found: $apiKey');
    return;
  }

  print('🔑 Key found: ${apiKey.substring(0, 8)}... (Length: ${apiKey.length})');

  // 3. Test API
  try {
    print('📡 Connecting to gemini-1.5-flash-latest...');
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );
      final response = await model.generateContent([Content.text('Test')]);
      print('✅ SUCCESS with gemini-1.5-flash-latest!');
      print('>> ${response.text}');
      return; 
    } catch (e) {
      print('⚠️ gemini-1.5-flash-latest failed. Trying gemini-pro...');
    }

    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );

    final content = [Content.text('Respond with "Working!" if you receive this.')];
    final response = await model.generateContent(content);

    if (response.text != null) {
      print('✅ SUCCESS! Received response:');
      print('>> "${response.text}"');
    } else {
      print('⚠️ Response was empty.');
    }
  } catch (e) {
    print('❌ API Call Failed:');
    print(e);
  }
  print('-----------------------');
}
