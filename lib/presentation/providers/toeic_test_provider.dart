// lib/presentation/providers/toeic_test_provider.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/toeic_test_session.dart';
import '../../domain/entities/toeic_question.dart';

class ToeicTestProvider extends ChangeNotifier {
  ToeicTestSession? _session;
  List<ToeicQuestion> _questions = [];
  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

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
    _initAudioPlayer();
    notifyListeners();
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
  }

  Future<void> playAudio(String audioUrl) async {
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.stop();
      
      // Check if it's an asset or URL
      if (audioUrl.startsWith('assets/')) {
        // For local assets, use AssetSource and remove 'assets/' prefix
        final assetPath = audioUrl.replaceFirst('assets/', '');
        await _audioPlayer!.play(AssetSource(assetPath));
      } else {
        // For URLs, use UrlSource
        await _audioPlayer!.play(UrlSource(audioUrl));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
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

  Map<String, dynamic> finishTest() {
    if (_session == null)
      return {
        'totalQuestions': 0,
        'answered': 0,
        'correctAnswers': 0,
        'score': 0,
        'duration': Duration.zero,
        'userAnswers': {},
      };

    final correctAnswers = _questions.where((q) {
      final userAnswer = _session!.userAnswers[q.questionNumber];
      return userAnswer == q.correctAnswer;
    }).length;

    final result = {
      'totalQuestions': totalQuestions,
      'answered': _session!.totalAnswered,
      'correctAnswers': correctAnswers,
      'score': totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100).round()
          : 0,
      'duration': _session!.elapsedTime,
      'userAnswers': _session!.userAnswers,
    };

    // Don't dispose here - let the widget handle cleanup
    return result;
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    super.dispose();
  }
}
