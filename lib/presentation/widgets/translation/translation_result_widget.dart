// lib/presentation/widgets/translation/translation_result_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/constants/app_spacing.dart';

class TranslationResultWidget extends StatelessWidget {
  final String translatedText;
  final bool isTranslating;
  final VoidCallback? onSpeak;

  const TranslationResultWidget({
    super.key,
    required this.translatedText,
    required this.isTranslating,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
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
                if (isTranslating) ...[
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
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(spaceMd),
            child: translatedText.isEmpty
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
                    translatedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: getTextPrimary(context),
                      height: 1.5,
                    ),
                  ),
          ),

          // Footer
          if (translatedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceSm,
              ),
              child: Row(
                children: [
                  Text(
                    '${translatedText.length} ký tự',
                    style: TextStyle(
                      fontSize: 12,
                      color: getTextThird(context),
                    ),
                  ),
                  const Spacer(),
                  if (onSpeak != null)
                    IconButton(
                      onPressed: onSpeak,
                      icon: Icon(Icons.volume_up, size: 24),
                      color: Colors.green.shade700,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
