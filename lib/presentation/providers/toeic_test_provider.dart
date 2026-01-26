// lib/presentation/providers/toeic_test_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/toeic_test_session.dart';
import '../../domain/entities/toeic_question.dart';
import '../../core/utils/toeic_score_calculator.dart';
import '../../data/services/firebase_storage_service.dart';

class ToeicTestProvider extends ChangeNotifier {
  ToeicTestSession? _session;
  List<ToeicQuestion> _questions = [];
  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  Timer? _timer;
  VoidCallback? _onTimeUp;

  ToeicTestSession? get session => _session;
  List<ToeicQuestion> get questions => _questions;
  AudioPlayer? get audioPlayer => _audioPlayer;
  bool get isAudioPlaying => _isAudioPlaying;
  Duration get audioDuration => _audioDuration;
  Duration get audioPosition => _audioPosition;

  ToeicQuestion? get currentQuestion {
    if (_session == null || _questions.isEmpty) return null;
    if (_session!.currentQuestionIndex >= _questions.length) return null;
    return _questions[_session!.currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;
  int get currentIndex => _session?.currentQuestionIndex ?? 0;
  bool get hasNextQuestion => currentIndex < totalQuestions - 1;
  bool get hasPreviousQuestion => currentIndex > 0;

  void startTest({
    required String testId,
    required String testName,
    required bool isFullTest,
    required List<int> selectedParts,
    int? timeLimit,
    required List<ToeicQuestion> questions,
    VoidCallback? onTimeUp,
  }) {
    _session = ToeicTestSession(
      testId: testId,
      testName: testName,
      isFullTest: isFullTest,
      selectedParts: selectedParts,
      timeLimit: timeLimit,
      startTime: DateTime.now(),
    );
    _questions = questions;
    _onTimeUp = onTimeUp;

    // Initialize audio player
    _initAudioPlayer();
    // Auto-play audio for the first question if it's a listening question
    if (!isFullTest) {
      final firstQuestion = currentQuestion;
      if (firstQuestion != null &&
          firstQuestion.audioUrl != null &&
          firstQuestion.partNumber <= 4) {
        // Schedule autoplay for next frame to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          playAudio(firstQuestion.audioUrl!);
        });
      }
    }
    // Start timer if time limit is set
    if (timeLimit != null && timeLimit > 0) {
      _startTimer();
    }

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session != null) {
        final remainingTime = _session!.remainingTime;
        if (remainingTime != null && remainingTime <= Duration.zero) {
          // Time's up
          timer.cancel();
          if (_onTimeUp != null) {
            _onTimeUp!();
          } else {
            finishTest();
          }
        } else {
          // Just notify listeners to update UI
          notifyListeners();
        }
      }
    });
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer!.onDurationChanged.listen((duration) {
      _audioDuration = duration;
      notifyListeners();
    });
    _audioPlayer!.onPositionChanged.listen((position) {
      _audioPosition = position;
      notifyListeners();
    });
    _audioPlayer!.onPlayerStateChanged.listen((state) {
      _isAudioPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    // Listen for player errors
    _audioPlayer!.onLog.listen((message) {
      // Audio log messages
    });

    // Listen for player complete events
    _audioPlayer!.onPlayerComplete.listen((_) {
      _isAudioPlaying = false;
      notifyListeners();
    });
  }

  Future<void> playAudio(String audioUrl) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.stop();

      // Set volume to maximum for testing
      await _audioPlayer!.setVolume(1.0);

      // Handle Firebase Storage references
      if (audioUrl.startsWith('firebase_audio:')) {
        // Resolve Firebase Storage reference to download URL
        final downloadUrl = await FirebaseStorageService.resolveFirebaseUrl(
          audioUrl,
        );
        if (downloadUrl != null) {
          await _audioPlayer!.play(UrlSource(downloadUrl));
        } else {
          throw Exception('Failed to resolve Firebase Storage URL');
        }
      } else if (audioUrl.startsWith('assets/')) {
        // For local assets, use AssetSource and remove 'assets/' prefix
        final assetPath = audioUrl.replaceFirst('assets/', '');

        await _audioPlayer!.play(AssetSource(assetPath));
      } else if (audioUrl.startsWith('http://') ||
          audioUrl.startsWith('https://')) {
        // For URLs, use UrlSource
        await _audioPlayer!.play(UrlSource(audioUrl));
      } else {
        // For local audio files without assets/ prefix, assume it's in audio/toeic_test1/
        final assetPath = 'audio/toeic_test1/$audioUrl';

        await _audioPlayer!.play(AssetSource(assetPath));
      }
    } catch (e) {
      // Audio playback failed
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer?.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer?.resume();
  }

  Future<void> stopAudio() async {
    await _audioPlayer?.stop();
    _isAudioPlaying = false;
    notifyListeners();
  }

  void selectAnswer(int questionNumber, String answer) {
    if (_session == null) return;
    final updatedAnswers = Map<int, String>.from(_session!.userAnswers);
    updatedAnswers[questionNumber] = answer;
    _session = _session!.copyWith(userAnswers: updatedAnswers);
    notifyListeners();
  }

  String? getAnswer(int questionNumber) {
    return _session?.userAnswers[questionNumber];
  }

  void nextQuestion() {
    if (_session == null || !hasNextQuestion) return;
    _session = _session!.copyWith(
      currentQuestionIndex: _session!.currentQuestionIndex + 1,
    );

    // Auto play audio for listening questions in practice mode
    if (!_session!.isFullTest) {
      final question = currentQuestion;
      if (question != null &&
          question.audioUrl != null &&
          question.partNumber <= 4) {
        playAudio(question.audioUrl!);
      }
    }

    notifyListeners();
  }

  void previousQuestion() {
    if (_session == null || !hasPreviousQuestion) return;
    _session = _session!.copyWith(
      currentQuestionIndex: _session!.currentQuestionIndex - 1,
    );
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (_session == null || index < 0 || index >= totalQuestions) return;
    _session = _session!.copyWith(currentQuestionIndex: index);
    notifyListeners();
  }

  void pauseTest() {
    if (_session == null) return;
    _session = _session!.copyWith(isPaused: true);
    pauseAudio();
    notifyListeners();
  }

  void resumeTest() {
    if (_session == null) return;
    _session = _session!.copyWith(isPaused: false);
    notifyListeners();
  }

  Map<String, dynamic> finishTestAndGetResults() {
    if (_session == null) {
      return {
        'totalQuestions': 0,
        'answered': 0,
        'correctAnswers': 0,
        'score': 0,
        'duration': Duration.zero,
        'userAnswers': {},
        'listeningScore': 5,
        'readingScore': 5,
        'totalScore': 10,
        'listeningCorrect': 0,
        'listeningWrong': 0,
        'listeningUnanswered': 0,
        'readingCorrect': 0,
        'readingWrong': 0,
        'readingUnanswered': 0,
        'listeningTotal': 100,
        'readingTotal': 100,
      };
    }

    // Separate listening and reading questions
    final listeningQuestions = _questions
        .where((q) => q.partNumber <= 4)
        .toList();
    final readingQuestions = _questions
        .where((q) => q.partNumber >= 5)
        .toList();

    // Calculate stats for each section
    int listeningCorrect = 0;
    int listeningWrong = 0;
    int listeningUnanswered = 0;

    int readingCorrect = 0;
    int readingWrong = 0;
    int readingUnanswered = 0;

    // Count listening results
    for (final question in listeningQuestions) {
      final userAnswer = _session!.userAnswers[question.questionNumber];
      if (userAnswer == null || userAnswer.isEmpty) {
        listeningUnanswered++;
      } else if (userAnswer == question.correctAnswer) {
        listeningCorrect++;
      } else {
        listeningWrong++;
      }
    }

    // Count reading results
    for (final question in readingQuestions) {
      final userAnswer = _session!.userAnswers[question.questionNumber];
      if (userAnswer == null || userAnswer.isEmpty) {
        readingUnanswered++;
      } else if (userAnswer == question.correctAnswer) {
        readingCorrect++;
      } else {
        readingWrong++;
      }
    }

    // For full TOEIC test (200 questions), assume 100 listening + 100 reading
    // For partial tests, use actual counts
    final listeningTotal = listeningQuestions.isNotEmpty
        ? (listeningQuestions.length == totalQuestions
              ? 100
              : listeningQuestions.length)
        : 100;
    final readingTotal = readingQuestions.isNotEmpty
        ? (readingQuestions.length == totalQuestions
              ? 100
              : readingQuestions.length)
        : 100;

    // Calculate TOEIC scores based on standard 100 questions each
    final listeningScore = ToeicScoreCalculator.calculateListeningScore(
      listeningCorrect,
      listeningTotal,
    );
    final readingScore = ToeicScoreCalculator.calculateReadingScore(
      readingCorrect,
      readingTotal,
    );
    final totalScore = ToeicScoreCalculator.calculateTotalScore(
      listeningScore,
      readingScore,
    );

    final totalCorrect = listeningCorrect + readingCorrect;

    final result = {
      'totalQuestions': totalQuestions,
      'answered': _session!.totalAnswered,
      'correctAnswers': totalCorrect,
      'score': totalQuestions > 0
          ? (totalCorrect / totalQuestions * 100).round()
          : 0,
      'duration': _session!.elapsedTime,
      'userAnswers': _session!.userAnswers,
      'listeningScore': listeningScore,
      'readingScore': readingScore,
      'totalScore': totalScore,
      'listeningCorrect': listeningCorrect,
      'listeningWrong': listeningWrong,
      'listeningUnanswered': listeningUnanswered,
      'readingCorrect': readingCorrect,
      'readingWrong': readingWrong,
      'readingUnanswered': readingUnanswered,
      'listeningTotal': listeningTotal,
      'readingTotal': readingTotal,
    };

    // Stop audio when test is finished
    stopAudio();

    return result;
  }

  void finishTest() {
    _timer?.cancel();
    stopAudio();
    _session = null;
    _questions.clear();
    notifyListeners();
  }

  void cleanupTest() {
    _timer?.cancel();
    stopAudio();
    _session = null;
    _questions.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    super.dispose();
  }
}
