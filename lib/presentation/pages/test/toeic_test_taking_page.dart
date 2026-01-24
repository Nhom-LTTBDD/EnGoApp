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
        // Hiển thị error message với hướng dẫn khắc phục
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
                  SizedBox(height: 4),
                  Text(
                    'Please check:\n• Internet connection\n• Firebase setup\n• JSON file availability',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
        return; // Dừng xử lý nếu không có questions
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
      child:
          Selector<
            ToeicTestProvider,
            ({ToeicTestSession? session, ToeicQuestion? question})
          >(
            // Sử dụng Selector thay vì Consumer để tránh rebuild không cần thiết
            selector: (context, provider) =>
                (session: provider.session, question: provider.currentQuestion),
            builder: (context, data, child) {
              final session = data.session; // Lấy session hiện tại
              final question = data.question; // Lấy câu hỏi hiện tại

              // Hiển thị loading spinner nếu chưa sẵn sàng
              if (session == null || question == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Container(
                color: getBackgroundColor(context),
                child: Column(
                  children: [
                    _buildHeader(
                      context,
                      session,
                      context.read<ToeicTestProvider>(),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: getCardBackground(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logic phân biệt loại question để render UI phù hợp
                            if ((question.partNumber == 3 ||
                                    question.partNumber == 4) ||
                                (question.partNumber >= 6 &&
                                    question.groupId != null)) ...[
                              // Group questions: Part 3,4,6,7 có nhiều câu chung context
                              _buildGroupQuestions(
                                context,
                                context.read<ToeicTestProvider>(),
                              ),
                            ] else ...[
                              // Single questions: Part 1,2,5 mỗi câu độc lập
                              _buildSingleQuestion(
                                context,
                                context.read<ToeicTestProvider>(),
                                question,
                              ),
                            ],

                            const SizedBox(
                              height: 16,
                            ), // Khoảng cách trước navigation
                            // Navigation buttons để chuyển câu tiếp theo
                            _buildNavigationButtons(
                              context.read<ToeicTestProvider>(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Build UI cho single question (Part 1, 2, 5)
  // Các parts này không có group, mỗi question hiển thị độc lập
  Widget _buildSingleQuestion(
    BuildContext context,
    ToeicTestProvider provider,
    ToeicQuestion question,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        // Cho phép scroll khi content dài
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị số thứ tự câu hỏi với font size lớn
            Text(
              '${question.questionNumber}.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: getTextPrimary(context), // Màu text từ theme
              ),
            ),

            // Debug: Check all questions for imageUrl
            Builder(
              builder: (context) {
                if (question.questionNumber == 62 ||
                    question.questionNumber == 63 ||
                    question.questionNumber == 64 ||
                    question.questionNumber == 66 ||
                    question.questionNumber == 69) {
                  // Debug info đã được xóa để clean up code
                }
                return const SizedBox.shrink();
              },
            ),

            // Audio player cho listening parts (Part 1-4)
            // Chỉ hiển thị khi question có audioUrl và thuộc listening parts
            if (question.audioUrl != null && question.partNumber <= 4)
              _buildAudioPlayer(provider, question.audioUrl!),

            // Hiển thị hình ảnh cho Part 1 và một số câu Part 3 có hình
            if (question.imageUrl != null &&
                (question.partNumber == 1 || question.partNumber == 3)) ...[
              Container(
                height: 200, // Chiều cao cố định cho image
                width: double.infinity, // Chiều rộng full width
                margin: const EdgeInsets.only(bottom: 16), // Margin dưới
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // Bo góc
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(
                    question.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain, // Hiển thị toàn bộ image không crop
                  ),
                ),
              ),
            ],

            // Question text (only for Part 3 and above)
            if (question.questionText != null && question.partNumber >= 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  question.questionText!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            // Part 1 and 2: Only show simple A,B,C,D buttons
            if (question.partNumber <= 2)
              _buildSimpleOptions(provider, question)
            // Part 3+: Show full options with text
            else
              _buildOptions(context, provider, question),

            const SizedBox(height: 24),
            // Question grid - moved to scrollable area
            _buildQuestionGrid(provider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Build UI for group questions (Part 3, 4, 6, 7 with groupId)
  Widget _buildGroupQuestions(
    BuildContext context,
    ToeicTestProvider provider,
  ) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return Container();

    // Tìm tất cả questions trong cùng group (Part 3, 4, 6, 7)
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
            Container(
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

            // Audio player - for listening parts (Part 1-4)
            // Audio player cho listening parts của group questions
            // Kiểm tra audioUrl từ question đầu tiên trong group
            if (groupQuestions.first.audioUrl != null &&
                groupQuestions.first.partNumber <= 4)
              _buildAudioPlayer(provider, groupQuestions.first.audioUrl!),

            // Kiểm tra và hiển thị hình ảnh cho group questions
            // Bao gồm cả single image và multiple images
            if (questionWithImages.imageUrl != null ||
                (questionWithImages.imageUrls != null &&
                    questionWithImages.imageUrls!.isNotEmpty)) ...[
              // Multiple images (Part 7 với array imageFiles)
              // Tạo column chứa danh sách hình ảnh nếu có nhiều hình
              if (questionWithImages.imageUrls != null &&
                  questionWithImages.imageUrls!.isNotEmpty)
                Column(
                  children: questionWithImages.imageUrls!
                      .map(
                        (imageUrl) => Container(
                          height: 250, // Chiều cao container cho mỗi image
                          width: double.infinity, // Chiều rộng full width
                          margin: const EdgeInsets.only(
                            bottom: 16,
                          ), // Margin giữa các images
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Bo góc container
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImageWidget(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit
                                  .contain, // Hiển thị toàn bộ image không crop
                            ),
                          ),
                        ),
                      )
                      .toList(), // Chuyển đổi map thành list widgets
                )
              // Single image (for Part 3, Part 6 with single imageFile)
              // Hiển thị một hình ảnh duy nhất cho các part khác
              else if (questionWithImages.imageUrl != null)
                Container(
                  height: 250, // Chiều cao cố định cho single image
                  width: double.infinity, // Chiều rộng full width
                  margin: const EdgeInsets.only(
                    bottom: 16,
                  ), // Margin dưới image
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Bo góc container
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(
                      questionWithImages.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain, // Hiển thị toàn bộ image không crop
                    ),
                  ),
                ),
            ],

            // Hiển thị tất cả câu hỏi trong group (thường là 3 câu)
            // Sử dụng asMap().entries để có cả index và question object
            ...groupQuestions.asMap().entries.map((entry) {
              final index = entry.key; // Index của câu hỏi trong group
              final question = entry.value; // Object câu hỏi

              return Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                ), // Margin giữa các câu hỏi
                padding: const EdgeInsets.all(
                  16,
                ), // Padding bên trong container
                decoration: BoxDecoration(
                  border: Border.all(
                    color: getDividerColor(context),
                  ), // Border với theme color
                  borderRadius: BorderRadius.circular(8), // Bo góc container
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align trái
                  children: [
                    // Hiển thị số câu hỏi và text câu hỏi
                    Text(
                      question.questionText ??
                          'Question ${question.questionNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // Font weight semibold
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ), // Spacing giữa question và options
                    // Hiển thị các lựa chọn A, B, C, D cho câu hỏi này
                    _buildOptions(context, provider, question),
                  ],
                ),
              );
            }), // Convert map thành list widgets

            const SizedBox(height: 24), // Spacing trước question grid
            // Question grid - di chuyển vào scrollable area
            _buildQuestionGrid(provider),
            const SizedBox(height: 16), // Spacing cuối
          ],
        ),
      ),
    );
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
                            ? Colors.red
                            : Colors.white,
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
                  foregroundColor: Colors.white,
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
      margin: const EdgeInsets.only(bottom: 16), // Margin dưới audio player
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align trái
        children: [
          // Hiển thị thông tin debug audio URL khi ở debug mode
          Consumer<ToeicTestProvider>(
            builder: (context, audioProvider, child) {
              // Debug logs
              print('🎵 Audio Player State: ${audioProvider.isAudioPlaying}');
              print(
                '🎵 Audio Duration: ${audioProvider.audioDuration.inSeconds}s',
              );
              print(
                '🎵 Audio Position: ${audioProvider.audioPosition.inSeconds}s',
              );

              return Row(
                children: [
                  // Play/Pause button - Nút phát/tạm dừng audio
                  SizedBox(
                    width: 40, // Chiều rộng cố định cho button
                    height: 40, // Chiều cao cố định cho button
                    child: IconButton(
                      onPressed: () {
                        // Toggle phát/tạm dừng audio khi nhấn nút
                        if (audioProvider.isAudioPlaying) {
                          audioProvider.pauseAudio(); // Tạm dừng nếu đang phát
                        } else {
                          audioProvider.playAudio(
                            audioUrl,
                          ); // Phát audio nếu đang dừng
                        }
                      },
                      icon: Icon(
                        // Hiển thị icon tương ứng với trạng thái audio
                        audioProvider.isAudioPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 30, // Kích thước icon
                        color: Colors.grey[400], // Màu xanh khi đang phát
                      ),
                      padding: EdgeInsets.zero, // Không có padding
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ), // Khoảng cách giữa button và progress bar
                  // Thanh hiển thị tiến trình audio
                  Expanded(
                    child: LinearProgressIndicator(
                      // Tính giá trị progress dựa trên thời gian hiện tại và tổng thời gian
                      value: audioProvider.audioDuration.inSeconds > 0
                          ? audioProvider.audioPosition.inSeconds /
                                audioProvider.audioDuration.inSeconds
                          : 0.0, // Giá trị 0 khi chưa có audio
                      backgroundColor: Colors.grey[300], // Màu nền progress bar
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50), // Màu xanh lá cho progress
                      ),
                      minHeight: 8, // Chiều cao minimum của progress bar
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
        color: const Color(0xFF1E90FF).withOpacity(0.1), // Màu nền xanh nhạt
        borderRadius: BorderRadius.circular(8), // Bo góc
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Padding cho number container
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF), // Màu xanh dương
              borderRadius: BorderRadius.circular(8), // Bo góc
            ),
            child: Text(
              'Q${question.questionNumber}', // Hiển thị số câu hỏi
              style: const TextStyle(
                color: Colors.white, // Màu chữ trắng
                fontWeight: FontWeight.bold, // Font weight đậm
              ),
            ),
          ),
          const SizedBox(width: 10), // Khoảng cách giữa number và part info
          Text(
            'Part ${question.partNumber}', // Hiển thị số part
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600, // Font weight semibold
              color: Color(0xFF1E90FF), // Màu xanh dương
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(passage, style: const TextStyle(fontSize: 15, height: 1.5)),
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
                        ? const Color(0xFF1E90FF) // Màu xanh dương khi chọn
                        : Colors.grey[400], // Màu xám khi không chọn
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
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
                        ? const Color(0xFF1E90FF) // Màu xanh dương khi chọn
                        : Colors.grey[400], // Màu xám khi không chọn
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  '$optionLetter.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
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
            color: const Color(0xFF4CAF50), // Green color for translation
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
            icon: const Icon(Icons.translate, color: Colors.white, size: 28),
            tooltip: 'Translation Helper',
          ),
        ),

        // Next/Finish Button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6B8CAE),
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
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
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
  /// Đây là phần review với 200 ô số câu, hiển thị trạng thái đã trả lời/chưa trả lời
  /// Logic: Tạo grid layout 9 cột x nhiều hàng để hiển thị tối đa 200 câu hỏi
  ///
  /// [provider] - ToeicTestProvider chứa danh sách câu hỏi và trạng thái
  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    const itemsPerRow = 9; // Số câu hỏi trên mỗi hàng - cố định 9 cột
    final questions =
        provider.questions; // Lấy danh sách tất cả câu hỏi từ provider
    if (questions.isEmpty)
      return Container(); // Trả về container rỗng nếu không có câu hỏi

    // Lấy danh sách số thứ tự câu hỏi thực tế từ các câu hỏi đã load
    final questionNumbers = questions.map((q) => q.questionNumber).toList()
      ..sort(); // Sắp xếp theo thứ tự tăng dần
    final minQuestion = questionNumbers.first; // Câu hỏi đầu tiên (thường là 1)
    final maxQuestion =
        questionNumbers.last; // Câu hỏi cuối cùng (thường là 200)
    final totalQuestions = questions.length; // Tổng số câu hỏi

    final rows = (totalQuestions / itemsPerRow)
        .ceil(); // Tính số hàng cần thiết (làm tròn lên)

    return Container(
      child: Column(
        children: List.generate(rows, (rowIndex) {
          // Tạo từng hàng
          final startIndex =
              rowIndex * itemsPerRow; // Index bắt đầu của hàng này

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 6,
            ), // Khoảng cách 6px giữa các hàng
            child: Row(
              children: List.generate(itemsPerRow, (colIndex) {
                // Tạo 9 cột cho mỗi hàng
                final questionIndex =
                    startIndex + colIndex; // Index câu hỏi hiện tại
                if (questionIndex >= totalQuestions) {
                  return Expanded(
                    child: Container(),
                  ); // Container rỗng nếu vượt quá số câu hỏi
                }

                // Sử dụng số thứ tự câu hỏi thực tế từ danh sách đã load
                final actualQuestionNumber = questionNumbers[questionIndex];
                final isAnswered =
                    provider.getAnswer(actualQuestionNumber) !=
                    null; // Kiểm tra đã trả lời chưa
                final isCurrent =
                    questionIndex ==
                    provider.currentIndex; // Kiểm tra có phải câu hiện tại

                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.goToQuestion(
                      questionIndex,
                    ), // Chuyển đến câu hỏi khi tap
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ), // Margin ngang 2px mỗi bên
                      height: 36, // Chiều cao cố định 36px cho mỗi ô
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(
                                0xFF1E90FF,
                              ) // Màu xanh dương cho câu hiện tại
                            : isAnswered
                            ? Colors.grey[400] // Màu xám cho câu đã trả lời
                            : Colors.white, // Màu trắng cho câu chưa trả lời
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ), // Viền xám nhạt dày 1px
                        borderRadius: BorderRadius.circular(6), // Bo góc 6px
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.1,
                            ), // Màu bóng đen trong suốt 10%
                            offset: const Offset(
                              0,
                              2,
                            ), // Độ lệch bóng: 0px ngang, 2px dọc
                            blurRadius: 2, // Độ mờ của bóng 2px
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          actualQuestionNumber
                              .toString(), // Hiển thị số thứ tự câu hỏi thực tế
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : Colors
                                      .black87, // Màu chữ: trắng nếu đang chọn, đen nếu không
                            fontWeight:
                                FontWeight.w600, // Độ đậm font: semibold
                            fontSize: 14, // Cỡ chữ 14px
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
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
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
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
                // Log lỗi nếu có vấn đề khi finish test
                debugPrint('Error finishing test: $e');
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

    // ⚠️ IMPORTANT: Lưu dữ liệu TRƯỚC KHI provider.finishTest() clear hết!
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
    if (imageUrl == null) return const SizedBox.shrink();

    // Handle Firebase Storage reference
    if (imageUrl.startsWith('firebase_image:')) {
      // Tạo key duy nhất cho widget để tránh rebuild không cần thiết
      final widgetKey = _imageWidgetKeys.putIfAbsent(
        imageUrl,
        () => ValueKey(imageUrl),
      );

      return FutureBuilder<String?>(
        key: widgetKey,
        future: _getCachedFirebaseUrl(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Error loading image from Firebase',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          // Load image từ Firebase Storage URL với cache tốt hư
          return RepaintBoundary(
            key: ValueKey('repaint_${snapshot.data!}'),
            child: Image.network(
              snapshot.data!,
              key: ValueKey('image_${snapshot.data!}'),
              width: width,
              height: height,
              fit: fit,
              cacheWidth: (width != null && width.isFinite && width > 0)
                  ? width.toInt()
                  : null,
              cacheHeight: (height != null && height.isFinite && height > 0)
                  ? height.toInt()
                  : null,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Network image failed',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    // Handle local assets
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text('Asset image failed', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Cache Firebase URL để tránh gọi API liên tục gây giật ảnh
  Future<String?> _getCachedFirebaseUrl(String imageUrl) async {
    // Kiểm tra cache trước - return ngay nếu có
    if (_imageUrlCache.containsKey(imageUrl)) {
      final cachedUrl = _imageUrlCache[imageUrl];
      if (cachedUrl != null) {
        return cachedUrl;
      }
    }

    // Chỉ gọi API một lần và lưu kết quả
    try {
      final url = await FirebaseStorageService.resolveFirebaseUrl(imageUrl);
      _imageUrlCache[imageUrl] = url; // Cache kể cả null
      return url;
    } catch (e) {
      _imageUrlCache[imageUrl] = null; // Cache lỗi để không retry liên tục
      return null;
    }
  }
}
