// lib/presentation/pages/test/toeic_test_taking_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toeic_test_provider.dart';
import '../../layout/main_layout.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/toeic_test_session.dart';
import '../../../data/datasources/toeic_sample_data.dart';
import '../../../data/services/firebase_storage_service.dart';
import '../../../routes/app_routes.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import '../../widgets/test/translation_helper_dialog.dart';
import '../../widgets/toeic/shared_audio_player_widget.dart';
import '../../widgets/test/toeic_quiz_summary_widget.dart';
import '../../widgets/toeic/toeic_question_display_widget.dart';

/// ToeicTestTakingPage - Trang chính làm bài test TOEIC
///
/// Hỗ trợ:
/// - Full test (all 7 parts) hoặc Practice (selected parts)
/// - Timer với giới hạn thời gian tuỳ chọn
/// - Audio player cho listening parts
/// - Question display (single/group/image questions)
/// - Navigation giữa các câu hỏi
/// - Finish test & navigate to results page
class ToeicTestTakingPage extends StatefulWidget {
  final String testId; // Test ID
  final String testName; // Test name hiển thị
  final bool isFullTest; // true = full test (all 7 parts), false = practice
  final List<int> selectedParts; // Parts user chọn (e.g., [1,2,3])
  final int? timeLimit; // Thời gian giới hạn (phút), null = unlimited
  final List<ToeicQuestion>? questions; // Pre-loaded questions (optional)

  const ToeicTestTakingPage({
    super.key,
    required this.testId,
    required this.testName,
    required this.isFullTest,
    required this.selectedParts,
    this.timeLimit,
    this.questions,
  });

  @override
  State<ToeicTestTakingPage> createState() => _ToeicTestTakingPageState();
}

/// State class quản lý UI, timer, question navigation, và answer selection
class _ToeicTestTakingPageState extends State<ToeicTestTakingPage> {
  /// Cache Firebase image URLs để tránh reload liên tục
  static final Map<String, String?> _imageUrlCache = {};

  /// Widget keys để optimize rebuild, tránh re-render images
  final Map<String, ValueKey> _imageWidgetKeys = {};

  /// Lifecycle: Load test data sau frame đầu tiên render
  /// Tránh setState() trong build process
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTest();
    });
  }

  /// Load questions từ data source & khởi tạo test session với provider
  /// - Lấy questions từ parameter hoặc load từ JSON theo selected parts
  /// - Gọi provider.startTest() để khởi tạo session
  /// - Setup timer callback (onTimeUp → navigate to results)
  Future<void> _loadTest() async {
    final provider = context.read<ToeicTestProvider>();

    // Load questions: sử dụng questions có sẵn hoặc load từ JSON
    List<ToeicQuestion> questions;
    if (widget.questions != null) {
      // Sử dụng questions được truyền vào (từ practice mode)
      questions = widget.questions!;
    } else {
      // Load questions cho các parts được chọn từ data source
      questions = [];

      // Duyệt qua từng part và load questions
      for (int partNumber in widget.selectedParts) {
        final partQuestions = await ToeicSampleData.getQuestionsByPart(
          partNumber,
        );
        questions.addAll(partQuestions);
      }

      // Kiểm tra nếu không load được questions nào
      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No questions available for selected parts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: getErrorColor(context),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'RETRY',
                textColor: getSurfaceColor(context),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
        return;
      }
    }

    // Khởi tạo test session với provider
    provider.startTest(
      testId: widget.testId,
      testName: widget.testName,
      isFullTest: widget.isFullTest,
      selectedParts: widget.selectedParts,
      timeLimit: widget.timeLimit,
      questions: questions, // Sử dụng questions đã load
      onTimeUp: () {
        // Callback khi hết thời gian - tự động finish test
        final result = provider.finishTestAndGetResults();
        final session = provider.session;
        if (mounted) {
          _navigateToResults(context, result, session);
        }
        // Finish test sau khi navigate để không clear dữ liệu
        provider.finishTest();
      },
    );

    // Nếu là full test và có listening parts, chuẩn bị phát audio
    if (widget.isFullTest && widget.selectedParts.any((p) => p <= 4)) {
      // TODO: Implement full listening audio playback
      // provider.playAudio('full_listening_audio_url');
    }
  }

  /// Build main UI: Header (timer, finish button) + Question display + Navigation
  /// - Displays current question with options
  /// - Uses Selector to optimize rebuilds (only re-render when question changes)
  /// - ToeicQuestionDisplayWidget handles single/group/image question types
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.testName,
      currentIndex: -1,
      showBottomNav: false,
      child: Consumer<ToeicTestProvider>(
        builder: (context, provider, child) {
          final session = provider.session;
          final question = provider.currentQuestion;

          if (session == null || question == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: getBackgroundColor(context),
            child: Column(
              children: [
                _buildHeader(context, session, provider),
                Expanded(
                  child: Selector<ToeicTestProvider, ToeicQuestion?>(
                    selector: (context, provider) => provider.currentQuestion,
                    builder: (context, currentQuestion, child) {
                      if (currentQuestion == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: getCardBackground(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ToeicQuestionDisplayWidget(
                              imageWidgetKeys: _imageWidgetKeys,
                              imageUrlCache: _imageUrlCache,
                              buildOptions: _buildOptions,
                              buildSimpleOptions: _buildSimpleOptions,
                              buildNavigationButtons: _buildNavigationButtons,
                              buildAudioPlayer: _buildAudioPlayer,
                              buildImageContainer: (url, height) =>
                                  ImageContainerWidget(
                                    key: ValueKey('image_$url'),
                                    imageUrl: url,
                                    height: height,
                                    imageWidgetKeys: _imageWidgetKeys,
                                    imageUrlCache: _imageUrlCache,
                                  ),
                            ),

                            _buildNavigationButtons(provider),

                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Deprecated: Moved to ToeicQuestionDisplayWidget for refactoring
  @Deprecated('Use ToeicQuestionDisplayWidget instead')
  Widget _buildSingleQuestion(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    return Container();
  }

  /// Deprecated: Moved to ToeicQuestionDisplayWidget for refactoring
  @Deprecated('Use ToeicQuestionDisplayWidget instead')
  Widget _buildGroupQuestions(
    BuildContext context,
    ToeicTestProvider provider,
  ) {
    return Container();
  }

  /// Build header with timer (turns red when <5 min), finish button, question counter
  Widget _buildHeader(
    BuildContext context,
    ToeicTestSession session,
    ToeicTestProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        children: [
          // Time và btn finish - Tách timer riêng để tránh rebuild ảnh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (session.timeLimit != null)
                // Tách timer thành Consumer riêng để không ảnh hưởng tới ảnh
                Consumer<ToeicTestProvider>(
                  builder: (context, timerProvider, child) {
                    final remainingTime =
                        timerProvider.session?.remainingTime ?? Duration.zero;
                    return Text(
                      'Time: ${_formatDuration(remainingTime)}',
                      style: TextStyle(
                        color: remainingTime.inMinutes < 5
                            ? getErrorColor(context)
                            : getSurfaceColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                )
              else
                const SizedBox(), // Empty space if no time limit
              // Finish button - không phụ thuộc timer
              ElevatedButton(
                onPressed: () => _showFinishConfirmation(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.8),
                  foregroundColor: getSurfaceColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build audio player widget for listening parts
  /// Tạo audio player widget cho các part nghe (Part 1-4)
  ///
  /// Build audio player widget using SharedAudioPlayerWidget
  /// Phát audio cho listening parts
  Widget _buildAudioPlayer(ToeicTestProvider provider, String audioUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SharedAudioPlayerWidget(audioUrl: audioUrl, useProvider: true),
    );
  }

  /// Build question header: Q number + Part number
  /// Displays top info section for each question
  Widget _buildQuestionHeader(ToeicQuestion question) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Q${question.questionNumber}',
              style: TextStyle(
                color: getSurfaceColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Part ${question.partNumber}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build question image widget with height 250
  /// Displays images for Part 1-4 (Listening parts)
  Widget _buildQuestionImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }

  /// Build passage text widget for reading questions
  /// Displays passage text with grey background
  Widget _buildPassage(String passage) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: getSurfaceColor(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        passage,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: getTextPrimary(context),
        ),
      ),
    );
  }

  Widget _buildQuestionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Build answer options (A, B, C, D) with full text
  /// - Displays checkbox + option letter + option text
  /// - Highlight selected option
  /// - Call provider.selectAnswer() on tap
  Widget _buildOptions(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    final userAnswer = provider.getAnswer(question.questionNumber);

    return Column(
      children: question.options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final optionLetter = String.fromCharCode(65 + index);
        final optionText = entry.value;
        final isSelected = userAnswer == optionLetter;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              provider.selectAnswer(question.questionNumber, optionLetter);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : getDisabledColor(context),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: getSurfaceColor(context),
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: getTextPrimary(context),
                      ),
                      children: [
                        TextSpan(
                          text: '$optionLetter. ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: optionText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build simple A, B, C, D buttons (no text) for Part 1-2 listening
  /// - Only letter shown (option text is shown separately)
  /// - Grid layout (2 columns)
  Widget _buildSimpleOptions(
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    final userAnswer = provider.getAnswer(question.questionNumber);

    // Part 2 only has 3 options (A, B, C), Part 1 has 4 (A, B, C, D)
    final optionCount = question.partNumber == 2 ? 3 : 4;

    return Column(
      children: List.generate(optionCount, (index) {
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
        final isSelected = userAnswer == optionLetter;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              provider.selectAnswer(question.questionNumber, optionLetter);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context)
                              .primaryColor // Màu xanh dương khi chọn
                        : getDisabledColor(context), // Màu xám khi không chọn
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: getSurfaceColor(context),
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  '$optionLetter.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: getTextPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(ToeicTestProvider provider) {
    final currentQuestion = provider.currentQuestion;
    final isGroupQuestion =
        (currentQuestion?.partNumber == 3 ||
            currentQuestion?.partNumber == 4) ||
        (currentQuestion != null &&
            currentQuestion.partNumber >= 6 &&
            currentQuestion.groupId != null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Translation Helper Button - Hiển thị modal dialog với tính năng dịch
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: getSuccessColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const TranslationHelperDialog(),
              );
            },
            icon: Icon(
              Icons.translate,
              color: getSurfaceColor(context),
              size: 28,
            ),
            tooltip: 'Translation Helper',
          ),
        ),

        /// Next/Finish Button - Navigate to next question or finish test
        /// - Group questions: Jump to next group
        /// - Regular questions: Move to next question
        /// - Last question: Show finish confirmation
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {
              if (isGroupQuestion) {
                _moveToNextGroup(provider);
              } else if (provider.hasNextQuestion) {
                provider.nextQuestion();
              } else {
                _showFinishConfirmation(context, provider);
              }
            },
            icon: Icon(
              Icons.arrow_forward,
              color: getSurfaceColor(context),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  /// Jump to next question group (for Part 3, 6, 7)
  /// - Finds all questions in current group
  /// - Moves to first question after the group
  void _moveToNextGroup(ToeicTestProvider provider) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return;

    final currentGroupQuestions =
        provider.questions
            .where(
              (q) =>
                  q.partNumber == currentQuestion.partNumber &&
                  q.groupId == currentQuestion.groupId,
            )
            .toList()
          ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    if (currentGroupQuestions.isEmpty) {
      if (provider.hasNextQuestion) {
        provider.nextQuestion();
      } else {
        _showFinishConfirmation(context, provider);
      }
      return;
    }

    final lastQuestionInGroup = currentGroupQuestions.last;
    final lastQuestionIndex = provider.questions.indexWhere(
      (q) => q.questionNumber == lastQuestionInGroup.questionNumber,
    );

    if (lastQuestionIndex >= 0 &&
        lastQuestionIndex < provider.questions.length - 1) {
      provider.goToQuestion(lastQuestionIndex + 1);
    } else {
      _showFinishConfirmation(context, provider);
    }
  }

  /// Deprecated: Moved to ToeicQuizSummaryWidget
  @Deprecated('Use ToeicQuizSummaryWidget instead')
  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    return const ToeicQuizSummaryWidget();
  }

  /// Format duration to MM:SS or HH:MM:SS format
  /// - Returns MM:SS if less than 1 hour
  /// - Returns HH:MM:SS if 1 hour or more
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  /// Show exit confirmation dialog
  /// Warns user that progress will be lost
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Exit',
              style: TextStyle(color: getErrorColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Show finish test confirmation dialog
  /// - Warns about unanswered questions
  /// - User can review (cancel) or submit
  void _showFinishConfirmation(
    BuildContext context,
    ToeicTestProvider provider,
  ) {
    final session = provider.session;
    if (session == null) return;

    final unanswered = provider.totalQuestions - session.totalAnswered;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Test?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered questions. Do you want to submit?'
              : 'Are you ready to submit your test?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              try {
                final result = provider.finishTestAndGetResults();
                final session = provider.session;
                if (mounted) {
                  _navigateToResults(context, result, session);
                }
                provider.finishTest();
              } catch (e) {
                // Ignore errors when finishing test
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  /// Navigate to results page with test results
  /// - Saves questions & user answers before navigating
  /// - Passes all score data & session info to results page
  /// - Removes test page from navigation stack
  void _navigateToResults(
    BuildContext context,
    Map<String, dynamic> result,
    ToeicTestSession? session,
  ) {
    if (!mounted) return;

    final provider = context.read<ToeicTestProvider>();

    final questions = List<ToeicQuestion>.from(provider.questions);

    final userAnswers = <int, String>{};
    for (final question in questions) {
      final answer = provider.getAnswer(question.questionNumber);
      if (answer != null) {
        userAnswers[question.questionNumber] = answer;
      }
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.toeicResult,
      (route) => route.settings.name == AppRoutes.toeic,
      arguments: {
        'session': session,
        'testName': widget.testName,
        'listeningScore': result['listeningScore'] ?? 5,
        'readingScore': result['readingScore'] ?? 5,
        'totalScore': result['totalScore'] ?? 10,
        'listeningCorrect': result['listeningCorrect'] ?? 0,
        'listeningWrong': result['listeningWrong'] ?? 0,
        'listeningUnanswered': result['listeningUnanswered'] ?? 0,
        'readingCorrect': result['readingCorrect'] ?? 0,
        'readingWrong': result['readingWrong'] ?? 0,
        'readingUnanswered': result['readingUnanswered'] ?? 0,
        'listeningTotal': result['listeningTotal'] ?? 100,
        'readingTotal': result['readingTotal'] ?? 100,
        'questions': questions,
        'userAnswers': userAnswers,
        'sessionLog': [],
      },
    );
  }

  /// Helper widget to display image from Firebase Storage or local assets
  /// Auto-detects Firebase references
  Widget _buildImageWidget(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return ImageDisplayWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      imageWidgetKeys: _imageWidgetKeys,
      imageUrlCache: _imageUrlCache,
    );
  }
}

/// Widget wrapper cho image container - prevent rebuild hoàn toàn
/// StatelessWidget với const constructor để tránh widget recreation
class ImageContainerWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Map<String, ValueKey> imageWidgetKeys;
  final Map<String, String?> imageUrlCache;

  const ImageContainerWidget({
    super.key,
    required this.imageUrl,
    this.height = 200,
    required this.imageWidgetKeys,
    required this.imageUrlCache,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ValueKey('image_container_$imageUrl'),
      child: Container(
        height: height,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Builder(
            builder: (context) {
              return ImageDisplayWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                imageWidgetKeys: imageWidgetKeys,
                imageUrlCache: imageUrlCache,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Stateful widget to display images from Firebase or local
/// - Isolates image rendering to prevent page rebuilds
/// - Handles Firebase Storage URL conversion
/// - Caches resolved URLs
class ImageDisplayWidget extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Map<String, ValueKey> imageWidgetKeys;
  final Map<String, String?> imageUrlCache;

  const ImageDisplayWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    required this.imageWidgetKeys,
    required this.imageUrlCache,
  });

  @override
  State<ImageDisplayWidget> createState() => _ImageDisplayWidgetState();
}

class _ImageDisplayWidgetState extends State<ImageDisplayWidget> {
  /// Future to resolve Firebase image URL
  late Future<String?> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = _getCachedFirebaseUrl(widget.imageUrl ?? '');
  }

  /// Re-resolve URL if imageUrl changes
  @override
  void didUpdateWidget(ImageDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _urlFuture = _getCachedFirebaseUrl(widget.imageUrl ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null) return const SizedBox.shrink();

    // Handle Firebase Storage reference
    if (widget.imageUrl!.startsWith('firebase_image:')) {
      final widgetKey = widget.imageWidgetKeys.putIfAbsent(
        widget.imageUrl!,
        () {
          return ValueKey(widget.imageUrl);
        },
      );

      return FutureBuilder<String?>(
        key: widgetKey,
        future: _urlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: widget.width,
              height: widget.height,
              color: getBackgroundColor(context),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Container(
              width: widget.width,
              height: widget.height,
              color: getDisabledColor(context),
              child: const Center(child: Text('Error loading image')),
            );
          }

          // Load image từ Firebase Storage URL
          return RepaintBoundary(
            key: ValueKey('repaint_${snapshot.data!}'),
            child: Image.network(
              snapshot.data!,
              key: ValueKey('image_network_${snapshot.data!}'),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              cacheWidth:
                  (widget.width != null &&
                      widget.width!.isFinite &&
                      widget.width! > 0)
                  ? widget.width!.toInt()
                  : null,
              cacheHeight:
                  (widget.height != null &&
                      widget.height!.isFinite &&
                      widget.height! > 0)
                  ? widget.height!.toInt()
                  : null,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  width: widget.width,
                  height: widget.height,
                  color: getBackgroundColor(context),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: widget.width,
                  height: widget.height,
                  color: getDisabledColor(context),
                  child: const Center(child: Text('Error')),
                );
              },
            ),
          );
        },
      );
    }

    // Handle local assets
    return Image.asset(
      widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: getDisabledColor(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: getErrorColor(context), size: 48),
                const SizedBox(height: 8),
                Text(
                  'Asset image failed',
                  style: TextStyle(color: getErrorColor(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get Firebase image URL from cache or resolve from FirebaseStorageService
  /// - Returns cached URL if available
  /// - Otherwise resolves URL and caches it
  /// - Returns null if resolution fails
  Future<String?> _getCachedFirebaseUrl(String imageUrl) async {
    if (widget.imageUrlCache.containsKey(imageUrl)) {
      final cachedUrl = widget.imageUrlCache[imageUrl];
      if (cachedUrl != null) {
        return cachedUrl;
      }
    }

    try {
      final url = await FirebaseStorageService.resolveFirebaseUrl(imageUrl);
      widget.imageUrlCache[imageUrl] = url;
      return url;
    } catch (e) {
      widget.imageUrlCache[imageUrl] = null;
      return null;
    }
  }
}
