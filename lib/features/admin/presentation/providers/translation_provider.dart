import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:darna/features/admin/data/services/translation_service.dart';

/// Provider for translation service
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});
