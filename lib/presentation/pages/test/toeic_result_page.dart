// lib/presentation/pages/test/toeic_result_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../domain/entities/toeic_test_session.dart';
import '../../../domain/entities/toeic_question.dart';
import '../../../domain/entities/test_history.dart';
import '../../../data/services/firebase_firestore_service.dart';
import '../../providers/auth/auth_provider.dart';

class ToeicResultPage extends StatefulWidget {
  final ToeicTestSession? session;
  final String testName;
  final int listeningScore;
  final int readingScore;
  final int totalScore;
  final int listeningCorrect;
  final int listeningWrong;
  final int listeningUnanswered;
  final int readingCorrect;
  final int readingWrong;
  final int readingUnanswered;
  final int listeningTotal;
  final int readingTotal;
  final List<ToeicQuestion>? questions;
  final Map<int, String>? userAnswers;
  final List<dynamic>? sessionLog;

  const ToeicResultPage({
    Key? key,
    this.session,
    required this.testName,
    required this.listeningScore,
    required this.readingScore,
    required this.totalScore,
    required this.listeningCorrect,
    required this.listeningWrong,
    required this.listeningUnanswered,
    required this.readingCorrect,
    required this.readingWrong,
    required this.readingUnanswered,
    required this.listeningTotal,
    required this.readingTotal,
    this.questions,
    this.userAnswers,
    this.sessionLog,
  }) : super(key: key);

  @override
  State<ToeicResultPage> createState() => _ToeicResultPageState();
}

class _ToeicResultPageState extends State<ToeicResultPage> {
  bool _isHistorySaved = false;

  @override
  void initState() {
    super.initState();
    _saveTestHistory();
  }

  Future<void> _saveTestHistory() async {
    try {
      if (_isHistorySaved ||
          widget.questions == null ||
          widget.userAnswers == null) {
        print('History already saved or missing data');
        return;
      }

      print('Saving test history...');

      // Calculate incorrect questions
      final incorrectQuestions = <int>[];
      final correctAnswersMap = <int, String>{};

      for (final question in widget.questions!) {
        correctAnswersMap[question.questionNumber] = question.correctAnswer;
        final userAnswer = widget.userAnswers![question.questionNumber] ?? '';
        if (userAnswer != question.correctAnswer) {
          incorrectQuestions.add(question.questionNumber);
        }
      }

      // Calculate part scores
      final partScores = <String, dynamic>{};
      for (int part = 1; part <= 7; part++) {
        final partQuestions = widget.questions!
            .where((q) => q.partNumber == part)
            .toList();
        final partCorrect = partQuestions
            .where(
              (q) => widget.userAnswers![q.questionNumber] == q.correctAnswer,
            )
            .length;
        partScores['part$part'] = {
          'correct': partCorrect,
          'total': partQuestions.length,
          'percentage': partQuestions.isEmpty
              ? 0.0
              : (partCorrect / partQuestions.length) * 100,
        };
      }

      // Get actual user ID from AuthProvider
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) {
        print('User not authenticated, cannot save test history');
        return;
      }

      // Create history object
      final history = TestHistory(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        testId: 'test1',
        testName: widget.testName,
        completedAt: DateTime.now(),
        totalQuestions: widget.questions!.length,
        correctAnswers: widget.listeningCorrect + widget.readingCorrect,
        listeningScore: widget.listeningScore,
        readingScore: widget.readingScore,
        totalScore: widget.totalScore,
        userAnswers: widget.userAnswers!,
        correctAnswersMap: correctAnswersMap,
        incorrectQuestions: incorrectQuestions,
        timeSpent: 7200, // TODO: Calculate actual time spent
        partScores: partScores,
      );

      // Save to Firestore
      await FirebaseFirestoreService.saveTestHistory(history);

      setState(() {
        _isHistorySaved = true;
      });

      print('✅ Test history saved successfully');
    } catch (e) {
      print('❌ Error saving test history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 ToeicResultPage Build:');
    print('   questions: ${widget.questions?.length ?? 'null'}');
    print('   userAnswers: ${widget.userAnswers?.length ?? 'null'}');

    return MainLayout(
      title: "TOEIC",
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E90FF), Color(0xFFE0E0E0)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TOEIC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Test name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.testName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E90FF),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Result Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEST RESULT Title
                    const Text(
                      'TEST RESULT',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Listening and Reading scores
                    Row(
                      children: [
                        // Listening section
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'LISTENING: ${widget.listeningScore}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Correct: ${widget.listeningCorrect}/${widget.listeningTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Wrong: ${widget.listeningWrong}/${widget.listeningTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unanswered: ${widget.listeningUnanswered}/${widget.listeningTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reading section
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'READING: ${widget.readingScore}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Correct: ${widget.readingCorrect}/${widget.readingTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Wrong: ${widget.readingWrong}/${widget.readingTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unanswered: ${widget.readingUnanswered}/${widget.readingTotal}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Total Score Circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(color: Colors.green, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          widget.totalScore.toString(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        // Back Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate back to TOEIC main page, clearing navigation stack
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.toeic,
                                (route) =>
                                    route.settings.name == AppRoutes.home ||
                                    route.isFirst,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E90FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Review Test Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              print('🔍 Debug ToeicResultPage Review Button:');
                              print(
                                '   questions: ${widget.questions?.length ?? 'null'}',
                              );
                              print(
                                '   userAnswers: ${widget.userAnswers?.length ?? 'null'}',
                              );

                              if (widget.questions != null &&
                                  widget.userAnswers != null) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.toeicReview,
                                  arguments: {
                                    'questions': widget.questions,
                                    'userAnswers': widget.userAnswers,
                                    'sessionLog': widget.sessionLog ?? [],
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không có dữ liệu để xem lại bài làm!',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Xem lại bài làm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
