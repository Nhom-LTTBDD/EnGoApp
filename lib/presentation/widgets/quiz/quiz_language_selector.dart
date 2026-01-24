import 'package:en_go_app/core/theme/theme_helper.dart';
import 'package:en_go_app/domain/entities/quiz_language_mode.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class QuizLanguageSelector extends StatelessWidget {
  final QuizLanguageMode questionLanguage;
  final QuizLanguageMode answerLanguage;
  final VoidCallback onSelectQuestionLanguage;

  const QuizLanguageSelector({
    super.key,
    required this.questionLanguage,
    required this.answerLanguage,
    required this.onSelectQuestionLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelectQuestionLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: spaceSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trả lời bằng',
                  style: TextStyle(
                    fontSize: 16,
                    color: getTextPrimary(context),
                  ),
                ),
                Text(
                  _getLanguageModeText(answerLanguage),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: getTextThird(context)),
          ],
        ),
      ),
    );
  }
}

String _getLanguageModeText(QuizLanguageMode mode) {
  return mode.displayText;
}
