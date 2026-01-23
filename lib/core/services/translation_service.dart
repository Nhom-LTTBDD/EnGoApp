// lib/core/services/translation_service.dart
import 'package:translator/translator.dart';

// Service để xử lý dịch thuật
// Có thể tái sử dụng ở bất kỳ UI nào
class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  // Dịch text từ ngôn ngữ nguồn sang ngôn ngữ đích
  //
  // [text]: Text cần dịch
  // [from]: Ngôn ngữ nguồn (default: 'auto' - tự động phát hiện)
  // [to]: Ngôn ngữ đích (default: 'vi' - Tiếng Việt)
  //
  // Returns: Text đã được dịch
  Future<String> translate({
    required String text,
    String from = 'auto',
    String to = 'vi',
  }) async {
    try {
      if (text.trim().isEmpty) {
        return '';
      }

      final translation = await _translator.translate(text, from: from, to: to);

      return translation.text;
    } catch (e) {
      throw TranslationException('Translation failed: ${e.toString()}');
    }
  }

  /// Dịch từ Tiếng Anh sang Tiếng Việt
  Future<String> translateEnglishToVietnamese(String text) async {
    return translate(text: text, from: 'en', to: 'vi');
  }

  /// Dịch từ Tiếng Việt sang Tiếng Anh
  Future<String> translateVietnameseToEnglish(String text) async {
    return translate(text: text, from: 'vi', to: 'en');
  }
}

/// Exception cho translation errors
class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);

  @override
  String toString() => message;
}
