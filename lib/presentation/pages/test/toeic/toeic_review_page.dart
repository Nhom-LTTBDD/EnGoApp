import 'package:flutter/material.dart';
import '../../../../domain/entities/toeic_question.dart';
import '../../../../data/services/firebase_storage_service.dart';
import '../../../../core/theme/theme_helper.dart';
import '../../../widgets/toeic/shared_audio_player_widget.dart';

class ToeicReviewPage extends StatefulWidget {
  final List<ToeicQuestion> questions;
  final Map<int, String> userAnswers;
  final List<dynamic> sessionLog;

  const ToeicReviewPage({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.sessionLog,
  });

  @override
  State<ToeicReviewPage> createState() => _ToeicReviewPageState();
}

class _ToeicReviewPageState extends State<ToeicReviewPage> {
  int currentQuestionIndex = 0;

  // Cache cho Firebase Storage URLs
  final Map<String, String> _imageUrlCache = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Getter để lấy câu hỏi hiện tại dựa trên index
  ToeicQuestion? get currentQuestion {
    if (widget.questions.isEmpty ||
        currentQuestionIndex >= widget.questions.length ||
        currentQuestionIndex < 0) {
      return null;
    }
    return widget.questions[currentQuestionIndex];
  }

  // Getter để lấy câu trả lời của user cho câu hiện tại
  String? get userAnswer {
    final question = currentQuestion;
    return question != null
        ? widget.userAnswers[question.questionNumber]
        : null;
  }

  // Getter để kiểm tra xem user trả lời đúng hay sai
  bool get isCorrect {
    final question = currentQuestion;
    return question != null &&
        userAnswer?.toLowerCase() == question.correctAnswer.toLowerCase();
  }

  // Widget tạo nút phát audio với progress bar
  Widget _buildAudioButton() {
    final question = currentQuestion;
    // Nếu câu hỏi không có audio thì không hiển thị
    if (question?.audioUrl == null) return SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: SharedAudioPlayerWidget(
        key: ValueKey('audio_${question!.audioUrl}'),
        audioUrl: question.audioUrl!,
        useProvider: false,
      ),
    );
  }

  // Widget hiển thị hình ảnh từ Firebase Storage
  Widget _buildFirebaseImage(String imageUrl, {double? width, double? height}) {
    return FutureBuilder<String?>(
      future: _getFirebaseImageUrl(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height ?? 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: getBorderColor(context)),
              color: getSurfaceColor(context).withOpacity(0.3),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: width,
            height: height ?? 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: getBorderColor(context)),
              color: getSurfaceColor(context).withOpacity(0.3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: getDisabledColor(context), size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Không thể tải hình',
                    style: TextStyle(color: getTextSecondary(context)),
                  ),
                ],
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Image.network(
              snapshot.data!,
              width: width,
              height: height ?? 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height ?? 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: getSurfaceColor(context).withOpacity(0.3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: getDisabledColor(context),
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Lỗi tải hình',
                          style: TextStyle(color: getTextSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper method để lấy Firebase Storage URL với cache
  Future<String?> _getFirebaseImageUrl(String imageUrl) async {
    if (_imageUrlCache.containsKey(imageUrl)) {
      return _imageUrlCache[imageUrl];
    }

    try {
      final url = await FirebaseStorageService.resolveFirebaseUrl(imageUrl);
      if (url != null) {
        _imageUrlCache[imageUrl] = url;
      }
      return url;
    } catch (e) {
      return null;
    }
  }

  // Widget hiển thị hình ảnh của câu hỏi (single image hoặc multiple images)
  Widget _buildImages() {
    final question = currentQuestion;

    // Hiển thị single image nếu có imageUrl
    if (question?.imageUrl != null) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 250,
        alignment: Alignment.center,
        child: _buildFirebaseImage(question!.imageUrl!),
      );
    }

    // Hiển thị multiple images nếu có imageUrls array
    if (question?.imageUrls != null && question!.imageUrls!.isNotEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 250,
        alignment: Alignment.center,
        // Horizontal scrollable list cho multiple images
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: question.imageUrls!.length,
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: getBorderColor(context)),
              ),
              alignment: Alignment.center,
              child: _buildFirebaseImage(
                question.imageUrls![index],
                width: 300,
                height: 250,
              ),
            );
          },
        ),
      );
    }

    // Trả về empty widget nếu không có hình
    return SizedBox.shrink();
  }

  // Widget hiển thị transcript (lời thoại) của audio nếu có
  Widget _buildTranscript() {
    final question = currentQuestion;
    // Không hiển thị nếu không có transcript
    if (question == null ||
        question.transcript == null ||
        question.transcript!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getSurfaceColor(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và tiêu đề
          Row(
            children: [
              Icon(
                Icons.mail_lock,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Transcript:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Nội dung transcript
          Text(
            question.transcript!,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    final question = currentQuestion;
    if (question == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? getSuccessColor(context).withOpacity(0.1)
            : getErrorColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? getSuccessColor(context).withOpacity(0.4)
              : getErrorColor(context).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect
                    ? getSuccessColor(context)
                    : getErrorColor(context),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                isCorrect ? 'Đúng' : 'Sai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? getSuccessColor(context)
                      : getErrorColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Câu trả lời của người dùng
          if (userAnswer != null) ...[
            Text(
              'Câu trả lời của bạn:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: getTextSecondary(context),
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCorrect
                    ? getSuccessColor(context).withOpacity(0.2)
                    : getErrorColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$userAnswer. ${_getOptionText(userAnswer!)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? getSuccessColor(context)
                      : getErrorColor(context),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: getWarningColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Chưa trả lời',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getWarningColor(context),
                ),
              ),
            ),
          ],
          SizedBox(height: 15),
          // Đáp án đúng
          Text(
            'Đáp án đúng:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: getTextSecondary(context),
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: getSuccessColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${question.correctAnswer}. ${_getOptionText(question.correctAnswer)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getSuccessColor(context),
              ),
            ),
          ),
          // Giải thích (nếu có)
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            SizedBox(height: 15),
            Text(
              'Giải thích:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: getTextSecondary(context),
              ),
            ),
            SizedBox(height: 5),
            Text(
              question.explanation!,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: getTextPrimary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Utility method để format duration thành MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Utility method để lấy text của option dựa trên letter (A, B, C, D)
  String _getOptionText(String optionLetter) {
    final question = currentQuestion;
    if (question == null) return '';

    switch (optionLetter.toUpperCase()) {
      case 'A':
        return question.options.isNotEmpty ? question.options[0] : '';
      case 'B':
        return question.options.length > 1 ? question.options[1] : '';
      case 'C':
        return question.options.length > 2 ? question.options[2] : '';
      case 'D':
        return question.options.length > 3 ? question.options[3] : '';
      default:
        return '';
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentQuestionIndex > 0
                ? () {
                    setState(() {
                      currentQuestionIndex--;
                    });
                  }
                : null,
            icon: Icon(Icons.arrow_back),
            label: Text('Câu trước'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          Text(
            '${currentQuestionIndex + 1}/${widget.questions.length}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: currentQuestionIndex < widget.questions.length - 1
                ? () {
                    setState(() {
                      currentQuestionIndex++;
                    });
                  }
                : null,
            icon: Icon(Icons.arrow_forward),
            label: Text('Câu sau'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;

    if (question == null || widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Xem lại bài làm'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: getSurfaceColor(context),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: getDisabledColor(context),
              ),
              SizedBox(height: 16),
              Text(
                'Không có dữ liệu câu hỏi để xem lại',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: getTextSecondary(context),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Có thể do lỗi kỹ thuật hoặc dữ liệu chưa được lưu đúng cách',
                style: TextStyle(fontSize: 14, color: getTextThird(context)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Xem lại bài làm'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: getSurfaceColor(context),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin câu hỏi
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu ${question.questionNumber} - Part ${question.partNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (question.groupId != null) ...[
                          SizedBox(height: 5),
                          Text(
                            'Group: ${question.groupId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Audio button
                  _buildAudioButton(),

                  // Images
                  _buildImages(),

                  // Transcript
                  _buildTranscript(),

                  // Câu hỏi
                  if (question.questionText != null &&
                      question.questionText!.isNotEmpty) ...[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: getBorderColor(context)),
                      ),
                      child: Text(
                        question.questionText!,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: getTextPrimary(context),
                        ),
                      ),
                    ),
                  ],

                  // Lựa chọn
                  if (question.options.isNotEmpty) ...[
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (question.options.length > 0)
                          _buildOption('A', question.options[0]),
                        if (question.options.length > 1)
                          _buildOption('B', question.options[1]),
                        if (question.options.length > 2)
                          _buildOption('C', question.options[2]),
                        if (question.options.length > 3)
                          _buildOption('D', question.options[3]),
                      ],
                    ),
                  ],

                  SizedBox(height: 20),

                  // Phần đáp án và giải thích
                  _buildAnswerSection(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildOption(String optionLetter, String optionText) {
    final question = currentQuestion;
    if (question == null) return SizedBox.shrink();

    bool isUserAnswer = userAnswer?.toUpperCase() == optionLetter;
    bool isCorrectAnswer = question.correctAnswer.toUpperCase() == optionLetter;

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrectAnswer) {
      backgroundColor = getSuccessColor(context).withOpacity(0.1);
      borderColor = getSuccessColor(context).withOpacity(0.4);
      textColor = getSuccessColor(context);
    } else if (isUserAnswer) {
      backgroundColor = getErrorColor(context).withOpacity(0.1);
      borderColor = getErrorColor(context).withOpacity(0.4);
      textColor = getErrorColor(context);
    } else {
      backgroundColor = getSurfaceColor(context);
      borderColor = getBorderColor(context);
      textColor = getTextPrimary(context);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? getSuccessColor(context)
                  : isUserAnswer
                  ? getErrorColor(context)
                  : getDisabledColor(context),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                optionLetter,
                style: TextStyle(
                  color: getSurfaceColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(fontSize: 16, color: textColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
