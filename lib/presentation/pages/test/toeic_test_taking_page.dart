// lib/presentation/pages/test/toeic_test_taking_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/toeic_test_provider.dart';
import '../../layout/main_layout.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/toeic_test_session.dart';
import '../../../data/datasources/toeic_sample_data.dart';
import '../../../routes/app_routes.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';

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
        print('❌ No questions loaded, showing detailed error message');
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
      onTimeUp: () {
        // Handle time up - automatically finish test and go to results
        final result = provider.finishTestAndGetResults();
        final session = provider.session;
        if (mounted) {
          _navigateToResults(context, result, session);
        }
        // Finish AFTER navigate để không clear dữ liệu
        provider.finishTest();
      },
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
      currentIndex: -1,
      showBottomNav: false, // Ẩn bottom navigation trong test
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
                        // Check if this is a group question (Part 3, 4, 6, 7 with groupId)
                        if ((question.partNumber == 3 ||
                                question.partNumber == 4) ||
                            (question.partNumber >= 6 &&
                                question.groupId != null)) ...[
                          Builder(
                            builder: (context) {
                              print(
                                'Using _buildGroupQuestions for Part ${question.partNumber}, Question ${question.questionNumber}, GroupId: ${question.groupId}',
                              );
                              return const SizedBox.shrink();
                            },
                          ),
                          _buildGroupQuestions(context, provider),
                        ] else ...[
                          Builder(
                            builder: (context) {
                              print(
                                'Using _buildSingleQuestion for Part ${question.partNumber}, Question ${question.questionNumber}',
                              );
                              return const SizedBox.shrink();
                            },
                          ),
                          _buildSingleQuestion(context, provider, question),
                        ],

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
            // Question number
            Text(
              '${question.questionNumber}.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: getTextPrimary(context),
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
                  print(
                    'UI BUILD Q${question.questionNumber}: Part ${question.partNumber}, imageUrl: ${question.imageUrl}',
                  );
                  print(
                    'UI CONDITIONS: imageUrl != null: ${question.imageUrl != null}, partNumber == 3: ${question.partNumber == 3}',
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Audio player for listening parts (Part 1-4)
            if (question.audioUrl != null && question.partNumber <= 4)
              _buildAudioPlayer(provider, question.audioUrl!),

            // Image (for Part 1 and Part 3 questions with images)
            if (question.imageUrl != null &&
                (question.partNumber == 1 || question.partNumber == 3)) ...[
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    question.imageUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              Text(
                                'Error loading image:\n${question.imageUrl}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

    print(
      '_buildGroupQuestions called for question ${currentQuestion.questionNumber}, part ${currentQuestion.partNumber}, groupId: ${currentQuestion.groupId}',
    );

    // Find all questions in the same group (for Part 3, 4, 6, 7)
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
            if (groupQuestions.first.audioUrl != null &&
                groupQuestions.first.partNumber <= 4)
              _buildAudioPlayer(provider, groupQuestions.first.audioUrl!),

            // Debug: Check image data before showing
            Builder(
              builder: (context) {
                print('🔍 GROUP IMAGE CHECK:');
                print(
                  '   First question: ${groupQuestions.first.questionNumber}',
                );
                print('   Part: ${groupQuestions.first.partNumber}');
                print('   imageUrl: ${groupQuestions.first.imageUrl}');
                print('   imageUrls: ${groupQuestions.first.imageUrls}');
                print(
                  '   imageUrl != null: ${groupQuestions.first.imageUrl != null}',
                );
                print(
                  '   imageUrls != null && not empty: ${groupQuestions.first.imageUrls != null && groupQuestions.first.imageUrls!.isNotEmpty}',
                );
                return const SizedBox.shrink();
              },
            ),

            // Images for group questions - check if any question in group has images
            if (questionWithImages.imageUrl != null ||
                (questionWithImages.imageUrls != null &&
                    questionWithImages.imageUrls!.isNotEmpty)) ...[
              Builder(
                builder: (context) {
                  print(
                    'SHOWING GROUP IMAGES: imageUrl=${questionWithImages.imageUrl}, imageUrls=${questionWithImages.imageUrls}',
                  );
                  return const SizedBox.shrink();
                },
              ),

              // Multiple images (for Part 7 with imageFiles array)
              if (questionWithImages.imageUrls != null &&
                  questionWithImages.imageUrls!.isNotEmpty)
                Column(
                  children: questionWithImages.imageUrls!
                      .map(
                        (imageUrl) => Container(
                          height: 250,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  '❌ Error loading image: $imageUrl, Error: $error',
                                );
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Image not found: ${imageUrl.split('/').last}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              // Single image (for Part 3, Part 6 with single imageFile)
              else if (questionWithImages.imageUrl != null)
                Container(
                  height: 250,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      questionWithImages.imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          '❌ Error loading image: ${questionWithImages.imageUrl}, Error: $error',
                        );
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not found: ${questionWithImages.imageUrl!.split('/').last}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],

            // All 3 questions
            ...groupQuestions.asMap().entries.map((entry) {
              final index = entry.key;
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
                    // Question number and text
                    Text(
                      '${question.questionText ?? 'Question ${question.questionNumber}'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Options for this question
                    _buildOptions(context, provider, question),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
            // Question grid - moved to scrollable area
            _buildQuestionGrid(provider),
            const SizedBox(height: 16),
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

  Widget _buildAudioPlayer(ToeicTestProvider provider, String audioUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debug info
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Audio: $audioUrl',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Row(
            children: [
              // Play/Pause button
              Container(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () {
                    debugPrint('🎵 Audio button pressed: $audioUrl');
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
            if (isGroupQuestion) {
              // For group questions (Part 3, 6, 7), jump to next group
              _moveToNextGroup(provider);
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

  Widget _buildQuestionGrid(ToeicTestProvider provider) {
    const itemsPerRow = 9;
    final questions = provider.questions;
    if (questions.isEmpty) return Container();

    // Get the actual question numbers from the loaded questions
    final questionNumbers = questions.map((q) => q.questionNumber).toList()
      ..sort();
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
                final isAnswered =
                    provider.getAnswer(actualQuestionNumber) != null;
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
                final result = provider.finishTestAndGetResults();
                final session = provider.session;
                // ⚠️ IMPORTANT: Navigate TRƯỚC KHI finishTest() để giữ lại dữ liệu
                if (mounted) {
                  _navigateToResults(context, result, session);
                }
                // Finish test AFTER navigating để không clear dữ liệu trước khi sử dụng
                provider.finishTest();
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

  void _navigateToResults(
    BuildContext context,
    Map<String, dynamic> result,
    ToeicTestSession? session,
  ) {
    if (!mounted) return;

    final provider = context.read<ToeicTestProvider>();

    // ⚠️ IMPORTANT: Lưu dữ liệu TRƯỚC KHI provider.finishTest() clear hết!
    final questions = List<ToeicQuestion>.from(provider.questions);

    // Get all user answers as a Map<int, String>
    final userAnswers = <int, String>{};
    for (final question in questions) {
      final answer = provider.getAnswer(question.questionNumber);
      if (answer != null) {
        userAnswers[question.questionNumber] = answer;
      }
    }

    print('🔍 _navigateToResults Debug:');
    print('   questions.length: ${questions.length}');
    print('   userAnswers.length: ${userAnswers.length}');
    print('   userAnswers: $userAnswers');

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
}
