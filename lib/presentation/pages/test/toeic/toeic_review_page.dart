import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../domain/entities/toeic_question.dart';

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
      // Chuyển đổi URL thành asset path để phát từ local assets
      String assetPath = audioUrl;
      if (!audioUrl.startsWith('audio/')) {
        // Nếu audioUrl là full path, extract chỉ filename
        final fileName = audioUrl.split('/').last;
        assetPath = 'audio/toeic_test1/$fileName';
      }

      // Kiểm tra nếu đang phát audio này thì pause, ngược lại thì play
      if (currentAudioFile == assetPath && isPlaying) {
        await audioPlayer?.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        // Dừng audio hiện tại và phát audio mới
        await audioPlayer?.stop();
        await audioPlayer?.play(AssetSource(assetPath));
        setState(() {
          isPlaying = true;
          currentAudioFile = assetPath;
        });
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu không thể phát audio
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát audio: $e'),
            backgroundColor: Colors.red,
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
                    color: Colors.grey[700],
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
                      backgroundColor: Colors.grey[300],
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
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            question!.imageUrl!,
            fit: BoxFit.contain,
            // Error handler nếu không load được hình
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Text('Không thể tải hình: ${question.imageUrl}'),
              );
            },
          ),
        ),
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
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  question.imageUrls![index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Không thể tải hình: ${question.imageUrls![index]}',
                      ),
                    );
                  },
                ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và tiêu đề
          Row(
            children: [
              Icon(Icons.mail_lock, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Transcript:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
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
              color: Colors.grey[800],
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
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green[700] : Colors.red[700],
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                isCorrect ? 'Đúng' : 'Sai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$userAnswer. ${_getOptionText(userAnswer!)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Chưa trả lời',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
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
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${question.correctAnswer}. ${_getOptionText(question.correctAnswer)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),
            Text(
              question.explanation!,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey[800],
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
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Không có dữ liệu câu hỏi để xem lại',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Có thể do lỗi kỹ thuật hoặc dữ liệu chưa được lưu đúng cách',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
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
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu ${question.questionNumber} - Part ${question.partNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        if (question.groupId != null) ...[
                          SizedBox(height: 5),
                          Text(
                            'Group: ${question.groupId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[600],
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        question.questionText!,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey[800],
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
      backgroundColor = Colors.green[100]!;
      borderColor = Colors.green[300]!;
      textColor = Colors.green[800]!;
    } else if (isUserAnswer) {
      backgroundColor = Colors.red[100]!;
      borderColor = Colors.red[300]!;
      textColor = Colors.red[800]!;
    } else {
      backgroundColor = Colors.grey[50]!;
      borderColor = Colors.grey[300]!;
      textColor = Colors.grey[800]!;
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
                  ? Colors.green[600]
                  : isUserAnswer
                  ? Colors.red[600]
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                optionLetter,
                style: TextStyle(
                  color: Colors.white,
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
