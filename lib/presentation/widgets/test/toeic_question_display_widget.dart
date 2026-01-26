// lib/presentation/widgets/test/toeic_question_display_widget.dart
// Widget để hiển thị câu hỏi TOEIC (đơn hoặc group)
// Hỗ trợ Part 1-7 với các loại câu khác nhau (listening, reading, group, single)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../providers/toeic_test_provider.dart';
import 'toeic_quiz_summary_widget.dart';

/// Widget hiển thị câu hỏi TOEIC
/// Tự động chọn hiển thị single question hoặc group question dựa trên partNumber
class ToeicQuestionDisplayWidget extends StatelessWidget {
  final Map<String, ValueKey> imageWidgetKeys;
  final Map<String, String?> imageUrlCache;
  final Function(BuildContext, ToeicTestProvider, ToeicQuestion) buildOptions;
  final Function(ToeicTestProvider, ToeicQuestion) buildSimpleOptions;
  final Function(ToeicTestProvider) buildNavigationButtons;
  final Function(ToeicTestProvider, String) buildAudioPlayer;
  final Function(String, double) buildImageContainer;

  const ToeicQuestionDisplayWidget({
    super.key,
    required this.imageWidgetKeys,
    required this.imageUrlCache,
    required this.buildOptions,
    required this.buildSimpleOptions,
    required this.buildNavigationButtons,
    required this.buildAudioPlayer,
    required this.buildImageContainer,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ToeicTestProvider>(
      builder: (context, provider, _) {
        final currentQuestion = provider.currentQuestion;
        if (currentQuestion == null) return Container();

        // Phân biệt giữa single question (Part 1,2,5) và group question (Part 3,4,6,7)
        if ((currentQuestion.partNumber == 3 ||
                currentQuestion.partNumber == 4) ||
            (currentQuestion.partNumber >= 6 &&
                currentQuestion.groupId != null)) {
          // Group questions
          return _buildGroupQuestions(context, provider);
        } else {
          // Single questions
          return _buildSingleQuestion(context, provider, currentQuestion);
        }
      },
    );
  }

  /// Build UI cho single question (Part 1, 2, 5)
  /// Các parts này không có group, mỗi question hiển thị độc lập
  Widget _buildSingleQuestion(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị số thứ tự câu hỏi với font size lớn
            RepaintBoundary(
              key: ValueKey('question_header_${question.questionNumber}'),
              child: Text(
                '${question.questionNumber}.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: getTextPrimary(context),
                ),
              ),
            ),

            // Audio player cho listening parts (Part 1-4)
            if (question.audioUrl != null && question.partNumber <= 4)
              RepaintBoundary(
                key: ValueKey('audio_${question.questionNumber}'),
                child: buildAudioPlayer(provider, question.audioUrl!),
              ),

            // Hiển thị hình ảnh cho Part 1 và một số câu Part 3 có hình
            if (question.imageUrl != null &&
                (question.partNumber == 1 || question.partNumber == 3)) ...[
              buildImageContainer(question.imageUrl!, 200),
            ],

            // Question text (only for Part 3 and above)
            if (question.questionText != null && question.partNumber >= 3)
              RepaintBoundary(
                key: ValueKey('question_text_${question.questionNumber}'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    question.questionText!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            // Part 1 and 2: Only show simple A,B,C,D buttons
            if (question.partNumber <= 2)
              buildSimpleOptions(provider, question)
            // Part 3+: Show full options with text
            else
              buildOptions(context, provider, question),

            const SizedBox(height: 24),
            const ToeicQuizSummaryWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build UI for group questions (Part 3, 4, 6, 7 with groupId)
  Widget _buildGroupQuestions(
    BuildContext context,
    ToeicTestProvider provider,
  ) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return Container();

    // Tìm tất cả questions trong cùng group
    final groupQuestions =
        provider.questions
            .where(
              (q) =>
                  q.partNumber == currentQuestion.partNumber &&
                  q.groupId == currentQuestion.groupId,
            )
            .toList()
          ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    if (groupQuestions.isEmpty)
      return _buildSingleQuestion(context, provider, currentQuestion);

    // Find a question in the group that has images
    final questionWithImages = groupQuestions.firstWhere(
      (q) =>
          q.imageUrl != null ||
          (q.imageUrls != null && q.imageUrls!.isNotEmpty),
      orElse: () => groupQuestions.first,
    );

    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conversation header
            RepaintBoundary(
              key: ValueKey('header_group_${currentQuestion.groupId}'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Questions ${groupQuestions.first.questionNumber}-${groupQuestions.last.questionNumber}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

            // Audio player - for listening parts (Part 1-4)
            if (groupQuestions.first.audioUrl != null &&
                groupQuestions.first.partNumber <= 4)
              RepaintBoundary(
                key: ValueKey('audio_group_${currentQuestion.groupId}'),
                child: buildAudioPlayer(
                  provider,
                  groupQuestions.first.audioUrl!,
                ),
              ),

            // Images widget
            RepaintBoundary(
              key: ValueKey('images_group_${currentQuestion.groupId}'),
              child: Column(
                children: [
                  // Multiple images (Part 7 với array imageFiles)
                  if (questionWithImages.imageUrls != null &&
                      questionWithImages.imageUrls!.isNotEmpty)
                    ...questionWithImages.imageUrls!.asMap().entries.map(
                      (imageEntry) =>
                          buildImageContainer(imageEntry.value, 250),
                    )
                  // Single image
                  else if (questionWithImages.imageUrl != null)
                    buildImageContainer(questionWithImages.imageUrl!, 250),
                ],
              ),
            ),

            // Hiển thị tất cả câu hỏi trong group
            ...groupQuestions.asMap().entries.map((entry) {
              final question = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: getDividerColor(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText ??
                          'Question ${question.questionNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildOptions(context, provider, question),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            const ToeicQuizSummaryWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
