// lib/presentation/widgets/test/translation_helper_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/theme_helper.dart';
import '../../widgets/test/translation_action_button.dart';

/// Compact translation helper dialog for TOEIC test
class TranslationHelperDialog extends StatefulWidget {
  const TranslationHelperDialog({super.key});

  @override
  State<TranslationHelperDialog> createState() =>
      _TranslationHelperDialogState();
}

class _TranslationHelperDialogState extends State<TranslationHelperDialog> {
  final TextEditingController _controller = TextEditingController();
  final TranslationService _translationService = TranslationService();
  final TtsService _ttsService = TtsService();

  String _translatedText = '';
  bool _isTranslating = false;
  bool _hasError = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    // Initialize TTS ngay khi dialog mở để tránh lag khi speak
    _ttsService.initialize();
  }

  @override
  void dispose() {
    // Stop TTS nếu đang phát khi đóng dialog
    _ttsService.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
      _hasError = false;
    });

    try {
      final result = await _translationService.translateEnglishToVietnamese(
        _controller.text.trim(),
      );
      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isTranslating = false;
        _translatedText = 'Lỗi dịch: ${e.toString()}';
      });
    }
  }

  Future<void> _speakEnglish() async {
    await _ttsService.stop();
    setState(() => _isSpeaking = true);
    await _ttsService.speakEnglish(_controller.text.trim());

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakVietnamese() async {
    await _ttsService.stop();
    setState(() => _isSpeaking = true);
    await _ttsService.speakVietnamese(_translatedText);

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _translatedText = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Translation Helper',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: getTextSecondary(context)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // English Input
            Container(
              decoration: BoxDecoration(
                color: getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getBorderColor(context)),
              ),
              child: Column(
                children: [
                  // Input field
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập từ hoặc cụm từ tiếng Anh...',
                      hintStyle: TextStyle(color: getTextSecondary(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: getTextPrimary(context),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && _translatedText.isEmpty) {
                        setState(() {}); // Refresh to show translate button
                      }
                    },
                  ),

                  // Actions row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: getBorderColor(context)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Speaker button
                        IconButton(
                          icon: Icon(
                            Icons.volume_up,
                            color: _controller.text.trim().isEmpty
                                ? Colors.grey
                                : Colors.blue,
                            size: 20,
                          ),
                          onPressed:
                              _controller.text.trim().isEmpty || _isSpeaking
                              ? null
                              : _speakEnglish,
                        ),

                        Row(
                          children: [
                            // Clear button
                            if (_controller.text.isNotEmpty)
                              ActionButton(
                                label: 'Xóa',
                                backgroundColor: Colors.red,
                                onPressed: _clear,
                              ),

                            const SizedBox(width: 8),

                            // Translate button
                            ActionButton(
                              label: _isTranslating ? '' : 'Dịch',
                              backgroundColor: Theme.of(context).primaryColor,
                              onPressed: _controller.text.trim().isEmpty
                                  ? null
                                  : _translate,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Translation Result
            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasError
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _hasError ? Icons.error : Icons.check_circle,
                              color: _hasError
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hasError ? 'Error' : 'Vietnamese',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _hasError
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (!_hasError)
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            onPressed: _isSpeaking ? null : _speakVietnamese,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: TextStyle(
                        fontSize: 14,
                        color: _hasError
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
