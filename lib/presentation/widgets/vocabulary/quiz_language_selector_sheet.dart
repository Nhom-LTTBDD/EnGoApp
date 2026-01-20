// lib/presentation/widgets/vocabulary/quiz_language_selector_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/quiz_language_mode.dart';

/// Bottom sheet widget để chọn ngôn ngữ cho quiz
class QuizLanguageSelectorSheet extends StatelessWidget {
  /// Chế độ ngôn ngữ hiện tại đang được chọn
  final QuizLanguageMode currentMode;

  /// Callback khi người dùng chọn mode mới
  final ValueChanged<QuizLanguageMode> onSelected;

  const QuizLanguageSelectorSheet({
    super.key,
    required this.currentMode,
    required this.onSelected,
  });

  /// Show bottom sheet helper method
  static Future<QuizLanguageMode?> show({
    required BuildContext context,
    required QuizLanguageMode currentMode,
  }) {
    return showModalBottomSheet<QuizLanguageMode>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuizLanguageSelectorSheet(
        currentMode: currentMode,
        onSelected: (mode) {
          Navigator.pop(context, mode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            _buildHandleBar(context),

            // Header
            _buildHeader(context),

            // Subtitle
            _buildSubtitle(context),

            const SizedBox(height: spaceMd),

            // Language options
            ...QuizLanguageMode.values.map(
              (mode) => _buildOption(context: context, mode: mode),
            ),

            const SizedBox(height: spaceMd),
          ],
        ),
      ),
    );
  }

  /// Handle bar at top of bottom sheet
  Widget _buildHandleBar(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: spaceSm),
      decoration: BoxDecoration(
        color: getTextThird(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Header title
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(spaceMd),
      child: Text(
        'Tùy chọn câu trả lời',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: getTextPrimary(context),
        ),
      ),
    );
  }

  /// Subtitle
  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: spaceMd),
      child: Text(
        'Trả lời bằng',
        style: TextStyle(fontSize: 14, color: getTextThird(context)),
      ),
    );
  }

  /// Language option row
  Widget _buildOption({
    required BuildContext context,
    required QuizLanguageMode mode,
  }) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () => onSelected(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.shortLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: getTextThird(context),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isSelected,
              onChanged: (_) => onSelected(mode),
              activeThumbColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
