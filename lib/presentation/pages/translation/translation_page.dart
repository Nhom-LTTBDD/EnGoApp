// lib/presentation/pages/translation/translation_page.dart
import 'package:flutter/material.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/constants/app_spacing.dart';
import '../../layout/main_layout.dart';
import '../../widgets/translation/error_widget.dart';
import '../../widgets/translation/language_selector_widget.dart';
import '../../widgets/translation/source_input_widget.dart';
import '../../widgets/translation/translation_result_widget.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final _translationService = TranslationService();
  final _ttsService = TtsService();
  final _sourceController = TextEditingController();

  String _translatedText = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  bool _isTranslating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await _ttsService.initialize();
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _performTranslation() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _translatedText = '';
        errorMessage = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      errorMessage = null;
    });

    try {
      final translated = await _translationService.translate(
        text: text,
        from: _sourceLanguage,
        to: _targetLanguage,
      );
      setState(() {
        _translatedText = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể dịch. Vui lòng thử lại.';
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      _isTranslating = false;

      // Swap text
      final tempText = _sourceController.text;
      _sourceController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  void _handleLanguageChanged(String language, bool isSource) {
    setState(() {
      if (isSource) {
        _sourceLanguage = language == 'en' ? 'vi' : 'en';
      } else {
        _targetLanguage = language == 'en' ? 'vi' : 'en';
      }
    });
  }

  void _clearText() {
    setState(() {
      _sourceController.clear();
      _translatedText = '';
      errorMessage = null;
    });
  }

  void _speakText(String text, String language) {
    try {
      if (language == 'en') {
        _ttsService.speakEnglish(text);
      } else {
        _ttsService.speakVietnamese(text);
      }
    } catch (e) {
      debugPrint('Failed to speak text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể phát âm. Vui lòng thử lại.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _speakSourceText() {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;
    _speakText(text, _sourceLanguage); // Speak in SOURCE language
  }

  void _speakTranslatedText() {
    if (_translatedText.trim().isEmpty) return;
    _speakText(_translatedText, _targetLanguage); // Speak in TARGET language
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'TRANSLATION',
      currentIndex: -1,
      showBottomNav: false,
      child: Container(
        decoration: BoxDecoration(color: getBackgroundColor(context)),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Selector
                      LanguageSelectorWidget(
                        sourceLanguage: _sourceLanguage,
                        targetLanguage: _targetLanguage,
                        onSwapLanguages: _swapLanguages,
                        onLanguageChanged: _handleLanguageChanged,
                      ),
                      const SizedBox(height: spaceMd),

                      // Source Text Input
                      SourceInputWidget(
                        controller: _sourceController,
                        onClear: _clearText,
                        onSpeak: _speakSourceText,
                      ),
                      const SizedBox(height: spaceMd),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _performTranslation,
                          child: const Text(
                            'Dịch',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      if (_translatedText.isNotEmpty ||
                          _isTranslating ||
                          errorMessage != null) ...[
                        const SizedBox(height: spaceMd),
                        // Translation Result
                        TranslationResultWidget(
                          translatedText: _translatedText,
                          isTranslating: _isTranslating,
                          onSpeak: _speakTranslatedText,
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: spaceSm),
                          TranslationErrorWidget(errorMessage: errorMessage),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
