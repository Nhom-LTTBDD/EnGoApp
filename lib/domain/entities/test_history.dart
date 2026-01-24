// lib/domain/entities/test_history.dart

class TestHistory {
  final String id;
  final String userId;
  final String testId;
  final String testName;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int listeningScore;
  final int readingScore;
  final int totalScore;
  final Map<int, String> userAnswers; // questionNumber -> userAnswer
  final Map<int, String> correctAnswersMap; // questionNumber -> correctAnswer
  final List<int> incorrectQuestions;
  final int timeSpent; // in seconds
  final Map<String, dynamic> partScores; // Part scores breakdown

  const TestHistory({
    required this.id,
    required this.userId,
    required this.testId,
    required this.testName,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.listeningScore,
    required this.readingScore,
    required this.totalScore,
    required this.userAnswers,
    required this.correctAnswersMap,
    required this.incorrectQuestions,
    required this.timeSpent,
    required this.partScores,
  });

  // Tính phần trăm đúng
  double get accuracyPercentage => (correctAnswers / totalQuestions) * 100;

  // Tính phần trăm sai
  double get errorPercentage => 100 - accuracyPercentage;

  // Get sai câu theo part
  Map<int, List<int>> get incorrectQuestionsByPart {
    final Map<int, List<int>> result = {};

    for (int questionNum in incorrectQuestions) {
      int part = _getPartFromQuestionNumber(questionNum);
      if (!result.containsKey(part)) {
        result[part] = [];
      }
      result[part]!.add(questionNum);
    }

    return result;
  }

  // Helper để determine part từ question number
  int _getPartFromQuestionNumber(int questionNum) {
    if (questionNum <= 6) return 1;
    if (questionNum <= 31) return 2;
    if (questionNum <= 70) return 3;
    if (questionNum <= 100) return 4;
    if (questionNum <= 140) return 5;
    if (questionNum <= 152) return 6;
    return 7;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    // Convert userAnswers Map<int, String> to Map<String, dynamic> for Firestore
    final userAnswersConverted = <String, dynamic>{};
    userAnswers.forEach((key, value) {
      userAnswersConverted[key.toString()] = value;
    });

    // Convert correctAnswersMap Map<int, String> to Map<String, dynamic> for Firestore
    final correctAnswersMapConverted = <String, dynamic>{};
    correctAnswersMap.forEach((key, value) {
      correctAnswersMapConverted[key.toString()] = value;
    });

    return {
      'id': id,
      'userId': userId,
      'testId': testId,
      'testName': testName,
      'completedAt': completedAt.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'listeningScore': listeningScore,
      'readingScore': readingScore,
      'totalScore': totalScore,
      'userAnswers': userAnswersConverted,
      'correctAnswersMap': correctAnswersMapConverted,
      'incorrectQuestions': incorrectQuestions,
      'timeSpent': timeSpent,
      'partScores': partScores,
    };
  }

  // Create from Map from Firestore
  factory TestHistory.fromMap(Map<String, dynamic> map) {
    return TestHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      testId: map['testId'] ?? '',
      testName: map['testName'] ?? '',
      completedAt: DateTime.parse(map['completedAt']),
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
      correctAnswers: map['correctAnswers']?.toInt() ?? 0,
      listeningScore: map['listeningScore']?.toInt() ?? 0,
      readingScore: map['readingScore']?.toInt() ?? 0,
      totalScore: map['totalScore']?.toInt() ?? 0,
      userAnswers:
          (map['userAnswers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v.toString()),
          ) ??
          {},
      correctAnswersMap:
          (map['correctAnswersMap'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v.toString()),
          ) ??
          {},
      incorrectQuestions: List<int>.from(map['incorrectQuestions'] ?? []),
      timeSpent: map['timeSpent']?.toInt() ?? 0,
      partScores: Map<String, dynamic>.from(map['partScores'] ?? {}),
    );
  }

  TestHistory copyWith({
    String? id,
    String? userId,
    String? testId,
    String? testName,
    DateTime? completedAt,
    int? totalQuestions,
    int? correctAnswers,
    int? listeningScore,
    int? readingScore,
    int? totalScore,
    Map<int, String>? userAnswers,
    Map<int, String>? correctAnswersMap,
    List<int>? incorrectQuestions,
    int? timeSpent,
    Map<String, dynamic>? partScores,
  }) {
    return TestHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      completedAt: completedAt ?? this.completedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      listeningScore: listeningScore ?? this.listeningScore,
      readingScore: readingScore ?? this.readingScore,
      totalScore: totalScore ?? this.totalScore,
      userAnswers: userAnswers ?? this.userAnswers,
      correctAnswersMap: correctAnswersMap ?? this.correctAnswersMap,
      incorrectQuestions: incorrectQuestions ?? this.incorrectQuestions,
      timeSpent: timeSpent ?? this.timeSpent,
      partScores: partScores ?? this.partScores,
    );
  }
}
