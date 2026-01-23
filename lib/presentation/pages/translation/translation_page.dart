// lib/presentation/pages/translation/translation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/constants/app_spacing.dart';
import '../../layout/main_layout.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final _translationService = TranslationService();
  final _sourceController = TextEditingController();

  String _translatedText = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  bool _isTranslating = false;
  String? _errorMessage;
  bool _autoDetect = true;

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _performTranslation() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _translatedText = '';
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      if (_autoDetect) {
        final result = await _translationService.autoTranslate(text);
        setState(() {
          _translatedText = result.translatedText;
          _sourceLanguage = result.sourceLanguage;
          _targetLanguage = result.targetLanguage;
          _isTranslating = false;
        });
      } else {
        final translated = await _translationService.translate(
          text: text,
          from: _sourceLanguage,
          to: _targetLanguage,
        );
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể dịch. Vui lòng thử lại.';
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    if (_autoDetect) return; // Không swap khi auto-detect

    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Swap text
      final tempText = _sourceController.text;
      _sourceController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã sao chép!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearText() {
    setState(() {
      _sourceController.clear();
      _translatedText = '';
      _errorMessage = null;
    });
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
                      // Header
                      _buildHeader(),
                      const SizedBox(height: spaceLg),

                      // Language Selector
                      _buildLanguageSelector(),
                      const SizedBox(height: spaceMd),

                      // Source Text Input
                      _buildSourceInput(),
                      const SizedBox(height: spaceMd),

                      // Translation Result
                      _buildTranslationResult(),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: spaceSm),
                        _buildErrorMessage(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.translate, color: Colors.blue.shade700, size: 28),
        ),
        const SizedBox(width: spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dịch Văn Bản',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getTextPrimary(context),
                ),
              ),
              Text(
                'Dịch giữa Tiếng Anh và Tiếng Việt',
                style: TextStyle(
                  fontSize: 14,
                  color: getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Column(
        children: [
          // Auto-detect switch
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: spaceSm),
              Text(
                'Tự động phát hiện ngôn ngữ',
                style: TextStyle(fontSize: 14, color: getTextPrimary(context)),
              ),
              const Spacer(),
              Switch(
                value: _autoDetect,
                onChanged: (value) {
                  setState(() {
                    _autoDetect = value;
                    if (value) {
                      _sourceLanguage = 'auto';
                    } else {
                      _sourceLanguage = 'en';
                    }
                  });
                },
                activeThumbColor: Colors.blue,
              ),
            ],
          ),

          if (!_autoDetect) ...[
            const SizedBox(height: spaceMd),
            Row(
              children: [
                // Source Language
                Expanded(
                  child: _buildLanguageButton(
                    language: _sourceLanguage,
                    isSource: true,
                  ),
                ),

                // Swap button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spaceSm),
                  child: IconButton(
                    onPressed: _swapLanguages,
                    icon: Icon(Icons.swap_horiz, color: Colors.blue.shade700),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                ),

                // Target Language
                Expanded(
                  child: _buildLanguageButton(
                    language: _targetLanguage,
                    isSource: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required bool isSource,
  }) {
    final languageMap = {
      'en': {'name': 'English', 'flag': '🇬🇧'},
      'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    };

    final langInfo = languageMap[language] ?? {'name': language, 'flag': '🌐'};

    return InkWell(
      onTap: () {
        setState(() {
          if (isSource) {
            _sourceLanguage = language == 'en' ? 'vi' : 'en';
          } else {
            _targetLanguage = language == 'en' ? 'vi' : 'en';
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(langInfo['flag']!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                langInfo['name']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceInput() {
    return Container(
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: spaceSm),
                Text(
                  'Nhập văn bản',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                if (_sourceController.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearText,
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Text field
          TextField(
            controller: _sourceController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Nhập hoặc dán văn bản cần dịch...',
              hintStyle: TextStyle(color: getTextThird(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(spaceMd),
            ),
            style: TextStyle(
              fontSize: 16,
              color: getTextPrimary(context),
              height: 1.5,
            ),
            onChanged: (_) => _performTranslation(),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: spaceMd,
              vertical: spaceSm,
            ),
            child: Row(
              children: [
                Text(
                  '${_sourceController.text.length} ký tự',
                  style: TextStyle(fontSize: 12, color: getTextThird(context)),
                ),
                const Spacer(),
                if (_sourceController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(_sourceController.text),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Sao chép'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationResult() {
    return Container(
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: spaceSm),
                Text(
                  'Bản dịch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getTextPrimary(context),
                  ),
                ),
                if (_isTranslating) ...[
                  const SizedBox(width: spaceSm),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Translation text
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 150),
            padding: const EdgeInsets.all(spaceMd),
            child: _translatedText.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.translate_outlined,
                          size: 48,
                          color: getTextThird(context),
                        ),
                        const SizedBox(height: spaceSm),
                        Text(
                          'Bản dịch sẽ xuất hiện ở đây',
                          style: TextStyle(
                            fontSize: 14,
                            color: getTextThird(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : SelectableText(
                    _translatedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: getTextPrimary(context),
                      height: 1.5,
                    ),
                  ),
          ),

          // Footer
          if (_translatedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceSm,
              ),
              child: Row(
                children: [
                  Text(
                    '${_translatedText.length} ký tự',
                    style: TextStyle(
                      fontSize: 12,
                      color: getTextThird(context),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(_translatedText),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Sao chép'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: spaceSm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
