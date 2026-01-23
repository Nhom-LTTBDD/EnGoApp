// lib/presentation/widgets/translation/language_selector_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/constants/app_spacing.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback onSwapLanguages;
  final Function(String language, bool isSource) onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSwapLanguages,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Row(
        children: [
          // Source Language
          Expanded(
            child: _LanguageButton(
              language: sourceLanguage,
              isSource: true,
              onTap: () => onLanguageChanged(sourceLanguage, true),
            ),
          ),

          // Swap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spaceSm),
            child: IconButton(
              onPressed: onSwapLanguages,
              icon: Icon(Icons.swap_horiz, color: Colors.blue.shade700),
              style: IconButton.styleFrom(backgroundColor: Colors.blue.shade50),
            ),
          ),

          // Target Language
          Expanded(
            child: _LanguageButton(
              language: targetLanguage,
              isSource: false,
              onTap: () => onLanguageChanged(targetLanguage, false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String language;
  final bool isSource;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.language,
    required this.isSource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageMap = {
      'en': {'name': 'English', 'flag': '🇬🇧'},
      'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    };

    final langInfo = languageMap[language] ?? {'name': language, 'flag': '🌐'};

    return InkWell(
      onTap: onTap,
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
}
