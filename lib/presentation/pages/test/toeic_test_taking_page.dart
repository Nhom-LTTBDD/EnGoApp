// lib/presentation/pages/test/toeic_test_taking_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toeic_test_provider.dart';
import '../../layout/main_layout.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/toeic_test_session.dart';

class ToeicTestTakingPage extends StatefulWidget {
  final String testId;
  final String testName;
  final bool isFullTest;
  final List<int> selectedParts;
  final int? timeLimit;
  final List<ToeicQuestion>? questions;

  const ToeicTestTakingPage({
    Key? key,
    required this.testId,
    required this.testName,
    required this.isFullTest,
    required this.selectedParts,
    this.timeLimit,
    this.questions,
  }) : super(key: key);

  @override
  State<ToeicTestTakingPage> createState() => _ToeicTestTakingPageState();
}

class _ToeicTestTakingPageState extends State<ToeicTestTakingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTest();
    });
  }

  Future<void> _loadTest() async {
    final provider = context.read<ToeicTestProvider>();

    // Use passed questions or fallback to mock data
    final questions = widget.questions ?? _generateMockQuestions();

    provider.startTest(
      testId: widget.testId,
      testName: widget.testName,
      isFullTest: widget.isFullTest,
      selectedParts: widget.selectedParts,
      timeLimit: widget.timeLimit,
      questions: questions, // Use real questions
    );

    // If full test with listening, play full audio
    if (widget.isFullTest && widget.selectedParts.any((p) => p <= 4)) {
      // TODO: Play full listening audio
      // provider.playAudio('full_listening_audio_url');
    }
  }

  List<ToeicQuestion> _generateMockQuestions() {
    // Mock data for testing - replace with Firebase fetch
    final partNumber = widget.selectedParts.first;

    return List.generate(10, (index) {
      final questionNumber = index + 1;

      // Part 1: Image with audio description (no text)
      if (partNumber == 1) {
        return ToeicQuestion(
          id: 'q$questionNumber',
          testId: widget.testId,
          partNumber: 1,
          questionNumber: questionNumber,
          questionType: 'image-audio',
          questionText: null, // Part 1 không có text
          imageUrl: 'https://picsum.photos/400/300?random=$questionNumber',
          audioUrl: 'sample_audio_url_$questionNumber.mp3',
          options: ['A', 'B', 'C', 'D'], // Chỉ có chữ cái, không có text
          correctAnswer: 'A',
          explanation: 'This is the explanation for question $questionNumber',
          order: questionNumber,
          groupId: null,
          passageText: null,
        );
      }

      // Other parts: Normal questions with text
      return ToeicQuestion(
        id: 'q$questionNumber',
        testId: widget.testId,
        partNumber: partNumber,
        questionNumber: questionNumber,
        questionType: 'multiple-choice',
        questionText:
            'This is sample question $questionNumber. Choose the best answer.',
        imageUrl: null,
        audioUrl: partNumber <= 4
            ? 'sample_audio_url_$questionNumber.mp3'
            : null,
        options: [
          'Option A for question $questionNumber',
          'Option B for question $questionNumber',
          'Option C for question $questionNumber',
          'Option D for question $questionNumber',
        ],
        correctAnswer: 'A',
        explanation: 'This is the explanation for question $questionNumber',
        order: questionNumber,
        groupId: null,
        passageText: null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.testName,
      currentIndex: 1,
      child: Consumer<ToeicTestProvider>(
        builder: (context, provider, child) {
          final session = provider.session;
          final question = provider.currentQuestion;

          if (session == null || question == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: const Color(0xFFE8E8E8),
            child: Column(
              children: [
                _buildHeader(session, provider),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question number
                        Text(
                          '${question.questionNumber}.',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Audio player
                        if (!widget.isFullTest && question.audioUrl != null)
                          _buildAudioPlayer(provider, question.audioUrl!),

                        // Image
                        if (question.imageUrl != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(question.imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Options
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildOptions(provider, question),
                                const SizedBox(height: 16),
                                _buildQuestionGrid(provider),
                              ],
                            ),
                          ),
                        ),

                        // Navigation buttons
                        _buildNavigationButtons(provider),
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

  Widget _buildHeader(ToeicTestSession session, ToeicTestProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF1E90FF)),
      child: Column(
        children: [
          // Top row with logo and Finish button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo TOEIC
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text(
                      'TOEIC',
                      style: TextStyle(
                        color: Color(0xFF1E90FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E90FF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              // Finish button
              ElevatedButton(
                onPressed: () => _showFinishConfirmation(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8CAE),
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
          const SizedBox(height: 12),
          // Time display
          if (session.timeLimit != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Time: ${_formatDuration(session.remainingTime ?? Duration.zero)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(ToeicTestProvider provider, String audioUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Play/Pause button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (provider.isAudioPlaying) {
                  provider.pauseAudio();
                } else {
                  provider.playAudio(audioUrl);
                }
              },
              icon: Icon(
                provider.isAudioPlaying ? Icons.pause : Icons.play_arrow,
                size: 24,
                color: Colors.black87,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          // Progress bar
          Expanded(
            child: LinearProgressIndicator(
              value: provider.audioDuration.inSeconds > 0
                  ? provider.audioPosition.inSeconds /
                        provider.audioDuration.inSeconds
                  : 0.3, // Mock progress for demo
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ), // Green color
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(ToeicQuestion question) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E90FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Q${question.questionNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Part ${question.partNumber}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E90FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
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

  Widget _buildOptions(ToeicTestProvider provider, ToeicQuestion question) {
    final userAnswer = provider.getAnswer(question.questionNumber);

    return Column(
      children: question.options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
        final isSelected = userAnswer == optionLetter;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  provider.selectAnswer(question.questionNumber, optionLetter);
                },
                child: Container(
                  width: 24,
                  height: 24,
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
              ),
              const SizedBox(width: 12),
              Text(
                '$optionLetter.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(ToeicTestProvider provider) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF6B8CAE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: provider.hasNextQuestion
              ? () => provider.nextQuestion()
              : () => _showFinishConfirmation(context, provider),
          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    const itemsPerRow = 9;
    final totalQuestions = provider.totalQuestions;
    final rows = (totalQuestions / itemsPerRow).ceil();

    return Container(
      child: Column(
        children: List.generate(rows, (rowIndex) {
          final startIndex = rowIndex * itemsPerRow;
          final endIndex = (startIndex + itemsPerRow).clamp(0, totalQuestions);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(itemsPerRow, (colIndex) {
                final questionIndex = startIndex + colIndex;
                if (questionIndex >= totalQuestions) {
                  return Expanded(child: Container());
                }

                final questionNumber = questionIndex + 1;
                final isAnswered = provider.getAnswer(questionNumber) != null;
                final isCurrent = questionIndex == provider.currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.goToQuestion(questionIndex),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF1E90FF) // Blue for current
                            : isAnswered
                            ? Colors.grey[400] // Grey for answered
                            : Colors.white, // White for unanswered
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          questionNumber.toString(),
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
    final minutes = twoDigits(duration.inMinutes.remainder(60).toInt());
    final seconds = twoDigits(duration.inSeconds.remainder(60).toInt());
    return '$minutes:$seconds';
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
                final result = provider.finishTest();
                if (mounted) {
                  _showResults(context, result);
                }
              } catch (e) {
                print('Error finishing test: $e');
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showResults(BuildContext context, Map<String, dynamic> result) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Test Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${result['score'] ?? 0}%'),
            Text(
              'Correct: ${result['correctAnswers'] ?? 0}/${result['totalQuestions'] ?? 0}',
            ),
            Text(
              'Answered: ${result['answered'] ?? 0}/${result['totalQuestions'] ?? 0}',
            ),
            Text(
              'Time: ${_formatDuration(result['duration'] ?? Duration.zero)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
