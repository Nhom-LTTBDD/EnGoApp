// lib/presentation/pages/test/toeic_test_taking_page.dart
// Trang chính để thực hiện bài test TOEIC
// Hỗ trợ: full test, test theo parts, audio player, timer, navigation

// Debug utilities
import 'package:flutter/foundation.dart';
// Flutter core widgets
import 'package:flutter/material.dart';
// State management
import 'package:provider/provider.dart';
// Provider quản lý state của TOEIC test
import '../../providers/toeic_test_provider.dart';
// Layout chính của app
import '../../layout/main_layout.dart';
// Domain entities
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/toeic_test_session.dart';
// Data source để load questions
import '../../../data/datasources/toeic_sample_data.dart';
// Firebase Storage service để handle images/audio
import '../../../data/services/firebase_storage_service.dart';
// App routing
import '../../../routes/app_routes.dart';
// Theme helpers
import 'package:en_go_app/core/theme/theme_helper.dart';
// Translation helper widget
import '../../widgets/test/translation_helper_dialog.dart';
// Shared audio player widget
import '../../widgets/toeic/shared_audio_player_widget.dart';
// Quiz summary widget
import '../../widgets/test/toeic_quiz_summary_widget.dart';
// Question display widget
import '../../widgets/toeic/toeic_question_display_widget.dart';

// StatefulWidget cho trang làm bài test TOEIC
// Hỗ trợ cả full test (7 parts) và test riêng lẻ theo parts
class ToeicTestTakingPage extends StatefulWidget {
  // ID của test
  final String testId;
  // Tên hiển thị của test
  final String testName;
  // Flag xác định có phải full test không
  final bool isFullTest;
  // Danh sách parts được chọn để test
  final List<int> selectedParts;
  // Giới hạn thời gian (seconds), null = không giới hạn
  final int? timeLimit;
  // Questions có sẵn (optional, sẽ load từ data source nếu null)
  final List<ToeicQuestion>? questions;

  // Constructor với tất cả parameters cần thiết
  const ToeicTestTakingPage({
    super.key,
    required this.testId, // Test ID bắt buộc
    required this.testName, // Tên test bắt buộc
    required this.isFullTest, // Flag full test bắt buộc
    required this.selectedParts, // Parts được chọn bắt buộc
    this.timeLimit, // Thời gian tùy chọn
    this.questions, // Questions tùy chọn
  });

  @override
  State<ToeicTestTakingPage> createState() => _ToeicTestTakingPageState();
}

// State class quản lý UI và logic của test taking page
class _ToeicTestTakingPageState extends State<ToeicTestTakingPage> {
  // Cache cho Firebase image URLs để tránh load liên tục
  static final Map<String, String?> _imageUrlCache = {};
  // Keys cho widgets để tránh rebuild không cần thiết
  final Map<String, ValueKey> _imageWidgetKeys = {};

  // Lifecycle method được gọi khi widget được khởi tạo
  @override
  void initState() {
    super.initState();
    // Đợi frame đầu tiên render xong rồi mới load test
    // Tránh setState trong build process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTest(); // Load test data và khởi tạo session
    });
  }

  // Method chính để load test data và khởi tạo test session
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

  // Main build method - tạo UI chính cho trang test
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.testName, // Hiển thị tên test trên header
      currentIndex: -1, // Không highlight bottom nav item nào
      showBottomNav: false, // Ẩn bottom navigation trong test
      child: Consumer<ToeicTestProvider>(
        builder: (context, provider, child) {
          final session = provider.session;
          final question = provider.currentQuestion;

          // Hiển thị loading spinner nếu chưa sẵn sàng
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
                    // Chỉ select question, không select session
                    // Để tránh rebuild khi selectAnswer() thay đổi session
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
                            // Question display widget - handles both single and group questions
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

                            // Navigation buttons
                            _buildNavigationButtons(provider),

                            const SizedBox(
                              height: 16,
                            ), // Spacing before navigation
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

  /// NOTE: _buildSingleQuestion has been moved to ToeicQuestionDisplayWidget
  /// Keep this method for backward compatibility
  @Deprecated('Use ToeicQuestionDisplayWidget instead')
  Widget _buildSingleQuestion(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    return Container();
  }

  /// NOTE: _buildGroupQuestions has been moved to ToeicQuestionDisplayWidget
  /// Keep this method for backward compatibility
  @Deprecated('Use ToeicQuestionDisplayWidget instead')
  Widget _buildGroupQuestions(
    BuildContext context,
    ToeicTestProvider provider,
  ) {
    return Container();
  }

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
  /// [provider] - ToeicTestProvider để quản lý trạng thái audio
  /// [audioUrl] - Đường dẫn tới file audio cần phát
  Widget _buildAudioPlayer(ToeicTestProvider provider, String audioUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SharedAudioPlayerWidget(audioUrl: audioUrl, useProvider: true),
    );
  }

  /// Build question header widget
  /// Tạo header cho từng câu hỏi hiển thị thông tin cơ bản
  ///
  /// [question] - Object ToeicQuestion chứa thông tin câu hỏi
  Widget _buildQuestionHeader(ToeicQuestion question) {
    return Container(
      padding: const EdgeInsets.all(10), // Padding bên trong container
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).primaryColor.withOpacity(0.1), // Màu nền xanh nhạt
        borderRadius: BorderRadius.circular(8), // Bo góc
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Padding cho number container
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Màu xanh dương
              borderRadius: BorderRadius.circular(8), // Bo góc
            ),
            child: Text(
              'Q${question.questionNumber}', // Hiển thị số câu hỏi
              style: TextStyle(
                color: getSurfaceColor(context), // Màu chữ trắng
                fontWeight: FontWeight.bold, // Font weight đậm
              ),
            ),
          ),
          const SizedBox(width: 10), // Khoảng cách giữa number và part info
          Text(
            'Part ${question.partNumber}', // Hiển thị số part
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Font weight semibold
              color: Theme.of(context).primaryColor, // Màu xanh dương
            ),
          ),
        ],
      ),
    );
  }

  /// Build question image widget
  /// Tạo widget hiển thị hình ảnh câu hỏi
  ///
  /// [imageUrl] - Đường dẫn tới file hình ảnh
  Widget _buildQuestionImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15), // Margin trên dưới
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }

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

  Widget _buildOptions(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    final userAnswer = provider.getAnswer(question.questionNumber);

    return Column(
      children: question.options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
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

  // Build simple A,B,C,D options for Part 1 and 2 (no text content)
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
        // Translation Helper Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: getSuccessColor(context), // Green color for translation
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

        // Next/Finish Button
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
                // For group questions (Part 3, 6, 7), jump to next group
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

  void _moveToNextGroup(ToeicTestProvider provider) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return;

    // Find all questions in current group (for any part with groups)
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

    // Find the index of the last question in this group
    final lastQuestionInGroup = currentGroupQuestions.last;
    final lastQuestionIndex = provider.questions.indexWhere(
      (q) => q.questionNumber == lastQuestionInGroup.questionNumber,
    );

    // Move to next question after the group (or finish if no more questions)
    if (lastQuestionIndex >= 0 &&
        lastQuestionIndex < provider.questions.length - 1) {
      provider.goToQuestion(lastQuestionIndex + 1);
    } else {
      _showFinishConfirmation(context, provider);
    }
  }

  /// Build question grid widget - Tạo lưới hiển thị tất cả câu hỏi
  /// NOTE: Đã tách ra thành ToeicQuizSummaryWidget trong file toeic_quiz_summary_widget.dart
  /// Hãy sử dụng widget đó thay vì method này
  @Deprecated('Use ToeicQuizSummaryWidget instead')
  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    return const ToeicQuizSummaryWidget();
  }

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
                // Lấy results và session data trước khi clear
                final result = provider.finishTestAndGetResults();
                final session = provider.session;
                // QUAN TRỌNG: Navigate trước khi finishTest() để giữ data
                if (mounted) {
                  _navigateToResults(context, result, session);
                }
                // Clear test state sau khi đã navigate
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

  void _navigateToResults(
    BuildContext context,
    Map<String, dynamic> result,
    ToeicTestSession? session,
  ) {
    if (!mounted) return;

    final provider = context.read<ToeicTestProvider>();

    // IMPORTANT: Lưu dữ liệu TRƯỚC KHI provider.finishTest() clear hết!
    final questions = List<ToeicQuestion>.from(provider.questions);

    // Lưu tất cả user answers vào Map để truyền sang results page
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
        'questions': questions, // Sử dụng dữ liệu đã lưu
        'userAnswers': userAnswers, // Sử dụng dữ liệu đã lưu
        'sessionLog': [],
      },
    );
  }

  /// Helper widget để hiển thị image từ Firebase Storage hoặc local assets
  /// Tự động detect và handle Firebase Storage references
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

/// Widget riêng để hiển thị image - isolate image khỏi rebuild của page
/// Mục đích: Tránh rebuild _buildImageWidget khi question selection thay đổi
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
  late Future<String?> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = _getCachedFirebaseUrl(widget.imageUrl ?? '');
  }

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
