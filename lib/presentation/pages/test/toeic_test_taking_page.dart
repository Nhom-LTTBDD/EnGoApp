// lib/presentation/pages/test/toeic_test_taking_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toeic_test_provider.dart';
import '../../layout/main_layout.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/toeic_test_session.dart';
import '../../../data/datasources/toeic_sample_data.dart';

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

    // Load questions from JSON or use passed questions
    List<ToeicQuestion> questions;
    if (widget.questions != null) {
      questions = widget.questions!;
      print('Using passed questions: ${questions.length}');
    } else {
      // Load questions for selected parts from JSON
      questions = [];
      print('Loading questions for parts: ${widget.selectedParts}');

      for (int partNumber in widget.selectedParts) {
        print('Loading part $partNumber...');
        final partQuestions = await ToeicSampleData.getQuestionsByPart(
          partNumber,
        );
        print('Loaded ${partQuestions.length} questions for part $partNumber');
        questions.addAll(partQuestions);
      }

      print('Total questions loaded: ${questions.length}');

      // If no questions loaded, show error
      if (questions.isEmpty) {
        print('No questions loaded, showing error message');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No questions available for selected parts. Please check if JSON data is loaded correctly.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    }

    print('Starting test with ${questions.length} questions');
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.testName,
      currentIndex: 1,
      showBottomNav: false, // Ẩn bottom navigation trong test
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
                        // Check if this is Part 3 (conversation)
                        if (question.partNumber == 3)
                          _buildPart3Questions(provider)
                        else
                          _buildSingleQuestion(provider, question),

                        const SizedBox(height: 16),
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

  // Build UI for single question (Part 1, 2, 4-7)
  Widget _buildSingleQuestion(ToeicTestProvider provider, ToeicQuestion question) {
    return Expanded(
      child: SingleChildScrollView(
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

            // Audio player
            if (!widget.isFullTest && question.audioUrl != null)
              _buildAudioPlayer(provider, question.audioUrl!),

            // Image (only for Part 1)
            if (question.imageUrl != null && question.partNumber == 1)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(question.imageUrl!.replaceAll('.jpg', '.png')),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

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
              _buildOptions(provider, question),

            const SizedBox(height: 24),
            // Question grid - moved to scrollable area
            _buildQuestionGrid(provider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Build UI for Part 3 conversation questions (3 questions per audio)
  Widget _buildPart3Questions(ToeicTestProvider provider) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return Container();

    // Find all questions in the same group (conversation)
    final groupQuestions = provider.questions
        .where((q) => q.partNumber == 3 && 
                     q.groupId == currentQuestion.groupId)
        .toList()
        ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    if (groupQuestions.isEmpty) return _buildSingleQuestion(provider, currentQuestion);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conversation header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E90FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Questions ${groupQuestions.first.questionNumber}-${groupQuestions.last.questionNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E90FF),
                ),
              ),
            ),

            // Audio player - only for first question in group
            if (!widget.isFullTest && groupQuestions.first.audioUrl != null)
              _buildAudioPlayer(provider, groupQuestions.first.audioUrl!),

            // All 3 questions
            ...groupQuestions.map((question) => Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number and text
                  Text(
                    '${question.questionNumber}. ${question.questionText ?? 'Listen to the conversation and choose the best answer.'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Options for this question
                  _buildOptions(provider, question),
                ],
              ),
            )).toList(),

            const SizedBox(height: 24),
            // Question grid - moved to scrollable area
            _buildQuestionGrid(provider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ToeicTestSession session, ToeicTestProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(color: Color(0xFF1E90FF)),
      child: Column(
        children: [
          // Time và btn finish
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (session.timeLimit != null)
                Text(
                  'Time: ${_formatDuration(session.remainingTime ?? Duration.zero)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox(), // Empty space if no time limit
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
                size: 30,
                color: Colors.grey[400],
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          // Thanh audio
          Expanded(
            child: LinearProgressIndicator(
              value: provider.audioDuration.inSeconds > 0
                  ? provider.audioPosition.inSeconds /
                        provider.audioDuration.inSeconds
                  : 0.3,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
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

  Widget _buildOptions(ToeicTestProvider provider, ToeicQuestion question) {
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
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
  Widget _buildSimpleOptions(ToeicTestProvider provider, ToeicQuestion question) {
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
    final isPart3 = currentQuestion?.partNumber == 3;
    
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF6B8CAE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          onPressed: () {
            if (isPart3) {
              // For Part 3, jump to next conversation group
              _moveToNextConversationGroup(provider);
            } else if (provider.hasNextQuestion) {
              provider.nextQuestion();
            } else {
              _showFinishConfirmation(context, provider);
            }
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _moveToNextConversationGroup(ToeicTestProvider provider) {
    final currentQuestion = provider.currentQuestion;
    if (currentQuestion == null) return;

    // Find the last question in current group
    final currentGroupQuestions = provider.questions
        .where((q) => q.partNumber == 3 && q.groupId == currentQuestion.groupId)
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
    final lastQuestionIndex = provider.questions.indexWhere((q) => q.questionNumber == lastQuestionInGroup.questionNumber);

    // Move to next question after the group (or finish if no more questions)
    if (lastQuestionIndex >= 0 && lastQuestionIndex < provider.questions.length - 1) {
      provider.goToQuestion(lastQuestionIndex + 1);
    } else {
      _showFinishConfirmation(context, provider);
    }
  }

  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    const itemsPerRow = 9;
    final questions = provider.questions;
    if (questions.isEmpty) return Container();
    
    // Get the actual question numbers from the loaded questions
    final questionNumbers = questions.map((q) => q.questionNumber).toList()..sort();
    final minQuestion = questionNumbers.first;
    final maxQuestion = questionNumbers.last;
    final totalQuestions = questions.length;
    
    final rows = (totalQuestions / itemsPerRow).ceil();

    return Container(
      child: Column(
        children: List.generate(rows, (rowIndex) {
          final startIndex = rowIndex * itemsPerRow;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(itemsPerRow, (colIndex) {
                final questionIndex = startIndex + colIndex;
                if (questionIndex >= totalQuestions) {
                  return Expanded(child: Container());
                }

                // Use actual question number from the loaded questions
                final actualQuestionNumber = questionNumbers[questionIndex];
                final isAnswered = provider.getAnswer(actualQuestionNumber) != null;
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
                          actualQuestionNumber.toString(),
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
                final result = provider.finishTestAndGetResults();
                provider.finishTest();
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
