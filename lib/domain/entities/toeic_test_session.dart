// lib/domain/entities/toeic_test_session.dart

class ToeicTestSession {
  final String testId;
  final String testName;
  final bool isFullTest;
  final List<int> selectedParts;
  final int? timeLimit; // minutes, null = no limit
  final DateTime startTime;
  final Map<int, String> userAnswers; // questionNumber -> answer
  final int currentQuestionIndex;
  final bool isPaused;

  const ToeicTestSession({
    required this.testId,
    required this.testName,
    required this.isFullTest,
    required this.selectedParts,
    this.timeLimit,
    required this.startTime,
    this.userAnswers = const {},
    this.currentQuestionIndex = 0,
    this.isPaused = false,
  });

  ToeicTestSession copyWith({
    String? testId,
    String? testName,
    bool? isFullTest,
    List<int>? selectedParts,
    int? timeLimit,
    DateTime? startTime,
    Map<int, String>? userAnswers,
    int? currentQuestionIndex,
    bool? isPaused,
  }) {
    return ToeicTestSession(
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      isFullTest: isFullTest ?? this.isFullTest,
      selectedParts: selectedParts ?? this.selectedParts,
      timeLimit: timeLimit ?? this.timeLimit,
      startTime: startTime ?? this.startTime,
      userAnswers: userAnswers ?? this.userAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  int get totalAnswered => userAnswers.length;

  Duration get elapsedTime => DateTime.now().difference(startTime);

  Duration? get remainingTime {
    if (timeLimit == null) return null;
    final limit = Duration(minutes: timeLimit!);
    final remaining = limit - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
