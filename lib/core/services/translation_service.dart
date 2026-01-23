// lib/core/services/translation_service.dart
import 'package:translator/translator.dart';

/// Service để xử lý dịch thuật
/// Có thể tái sử dụng ở bất kỳ UI nào
class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// Dịch text từ ngôn ngữ nguồn sang ngôn ngữ đích
  ///
  /// [text]: Text cần dịch
  /// [from]: Ngôn ngữ nguồn (default: 'auto' - tự động phát hiện)
  /// [to]: Ngôn ngữ đích (default: 'vi' - Tiếng Việt)
  ///
  /// Returns: Text đã được dịch
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

  /// Phát hiện ngôn ngữ của text
  Future<String> detectLanguage(String text) async {
    try {
      if (text.trim().isEmpty) {
        return 'unknown';
      }

      final translation = await _translator.translate(text, from: 'auto');
      return translation.sourceLanguage.code;
    } catch (e) {
      return 'unknown';
    }
  }

  /// Dịch tự động (auto-detect language và swap)
  Future<TranslationResult> autoTranslate(String text) async {
    try {
      final detectedLang = await detectLanguage(text);

      String targetLang;
      if (detectedLang == 'vi') {
        targetLang = 'en';
      } else {
        targetLang = 'vi';
      }

      final translatedText = await translate(
        text: text,
        from: detectedLang,
        to: targetLang,
      );

      return TranslationResult(
        sourceText: text,
        translatedText: translatedText,
        sourceLanguage: detectedLang,
        targetLanguage: targetLang,
      );
    } catch (e) {
      throw TranslationException('Auto translation failed: ${e.toString()}');
    }
  }
}

/// Model cho kết quả dịch
class TranslationResult {
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;

  TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  String get sourceLanguageName {
    switch (sourceLanguage) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Vietnamese';
      default:
        return sourceLanguage;
    }
  }

  String get targetLanguageName {
    switch (targetLanguage) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Vietnamese';
      default:
        return targetLanguage;
    }
  }
}

/// Exception cho translation errors
class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);

  @override
  String toString() => message;
}
