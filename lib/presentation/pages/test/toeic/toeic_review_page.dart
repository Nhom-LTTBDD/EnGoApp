import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../domain/entities/toeic_question.dart';
import '../../../../data/services/firebase_storage_service.dart';
import '../../../../core/theme/theme_helper.dart';

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
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  String? currentAudioFile;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  // Cache cho Firebase Storage URLs
  final Map<String, String> _imageUrlCache = {};
  final Map<String, String> _audioUrlCache = {};

  @override
  void initState() {
    super.initState();

    // Khởi tạo audio player để phát audio trong review
    audioPlayer = AudioPlayer();

    // Setup các listener để theo dõi trạng thái audio player

    // Listener cho trạng thái play/pause
    audioPlayer?.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listener cho vị trí hiện tại của audio (để update progress bar)
    audioPlayer?.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }
    });

    // Listener cho tổng thời lượng audio
    audioPlayer?.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    // Dừng audio và giải phóng resources khi thoát trang
    audioPlayer?.stop();
    audioPlayer?.dispose();
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

  // Phương thức phát audio cho câu hỏi listening
  Future<void> _playAudio(String audioUrl) async {
    try {
      // Lấy Firebase Storage URL từ cache hoặc resolve từ Firebase
      String firebaseUrl;
      if (_audioUrlCache.containsKey(audioUrl)) {
        firebaseUrl = _audioUrlCache[audioUrl]!;
      } else {
        // Resolve audio URL từ Firebase Storage
        final url = await FirebaseStorageService.getAudioDownloadUrl(audioUrl);
        if (url != null) {
          firebaseUrl = url;
          _audioUrlCache[audioUrl] = url;
        } else {
          throw Exception('Không thể tải audio từ Firebase Storage');
        }
      }

      // Kiểm tra nếu đang phát audio này thì pause, ngược lại thì play
      if (currentAudioFile == audioUrl && isPlaying) {
        await audioPlayer?.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        // Dừng audio hiện tại và phát audio từ Firebase URL
        await audioPlayer?.stop();
        await audioPlayer?.play(UrlSource(firebaseUrl));
        setState(() {
          isPlaying = true;
          currentAudioFile = audioUrl;
        });
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu không thể phát audio
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát audio: $e'),
            backgroundColor: getErrorColor(context),
          ),
        );
      }
    }
  }

  // Widget tạo nút phát audio với progress bar
  Widget _buildAudioButton() {
    final question = currentQuestion;
    // Nếu câu hỏi không có audio thì không hiển thị
    if (question?.audioUrl == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Nút Play/Pause
              Container(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () => _playAudio(question!.audioUrl!),
                  icon: Icon(
                    // Hiển thị icon pause nếu đang phát, ngược lại hiển thị play
                    isPlaying && currentAudioFile != null
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 28,
                    color: getTextPrimary(context),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 12),
              // Progress bar và time display
              Expanded(
                child: Column(
                  children: [
                    // Progress bar hiển thị tiến độ phát audio
                    LinearProgressIndicator(
                      value: totalDuration.inSeconds > 0
                          ? currentPosition.inSeconds / totalDuration.inSeconds
                          : 0.0,
                      backgroundColor: getBorderColor(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50), // Màu xanh progress bar
                      ),
                      minHeight: 8,
                    ),
                    SizedBox(height: 4),
                    // Hiển thị thời gian hiện tại và tổng thời gian
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style: TextStyle(
                            fontSize: 12,
                            color: getTextSecondary(context),
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: TextStyle(
                            fontSize: 12,
                            color: getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
      final url = await FirebaseStorageService.getImageDownloadUrl(imageUrl);
      if (url != null) {
        _imageUrlCache[imageUrl] = url;
      }
      return url;
    } catch (e) {
      print('Error loading Firebase image: $e');
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: getBorderColor(context)),
        ),
        child: _buildFirebaseImage(question!.imageUrl!),
      );
    }

    // Hiển thị multiple images nếu có imageUrls array
    if (question?.imageUrls != null && question!.imageUrls!.isNotEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 250,
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
                      // Reset audio state khi chuyển câu
                      isPlaying = false;
                      currentAudioFile = null;
                      currentPosition = Duration.zero;
                      totalDuration = Duration.zero;
                      audioPlayer?.stop();
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
                      // Reset audio state khi chuyển câu
                      isPlaying = false;
                      currentAudioFile = null;
                      currentPosition = Duration.zero;
                      totalDuration = Duration.zero;
                      audioPlayer?.stop();
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
                  SizedBox(height: 20),

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
