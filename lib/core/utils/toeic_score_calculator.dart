// lib/core/utils/toeic_score_calculator.dart

class ToeicScoreCalculator {
  /// Calculate TOEIC listening score based on correct answers
  /// TOEIC Listening has 100 questions, scored from 5-495
  /// Special curve: 97/100 correct = 495 points
  static int calculateListeningScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 5;
    if (correctAnswers <= 0) return 5;
    if (correctAnswers >= totalQuestions) return 495;

    // Special curve for listening - 97/100 = 495 points
    if (totalQuestions == 100) {
      if (correctAnswers >= 97) return 495;
      // Curve formula: more generous scoring for listening
      final percentage = correctAnswers / 100.0;
      final score = 5 + (percentage * 505).round(); // 505 to reach 495 at 97%
      return score.clamp(5, 495);
    } else {
      // For partial tests, use percentage mapping
      final percentage = (correctAnswers / totalQuestions).clamp(0.0, 1.0);
      final score = 5 + (percentage * 490).round();
      return score.clamp(5, 495);
    }
  }

  /// Calculate TOEIC reading score based on correct answers
  /// TOEIC Reading has 100 questions, scored from 5-495
  /// Linear: 100/100 correct = 495 points
  static int calculateReadingScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 5;
    if (correctAnswers <= 0) return 5;
    if (correctAnswers >= totalQuestions) return 495;

    // Linear mapping - must get 100/100 for full score
    final percentage = (correctAnswers / totalQuestions).clamp(0.0, 1.0);
    final score = 5 + (percentage * 490).round();
    return score.clamp(5, 495);
  }

  /// Calculate total TOEIC score (listening + reading)
  /// Total score range: 10-990
  static int calculateTotalScore(int listeningScore, int readingScore) {
    return listeningScore + readingScore;
  }

  /// Get score level description
  static String getScoreLevel(int totalScore) {
    if (totalScore >= 860) return 'Expert';
    if (totalScore >= 730) return 'Advanced';
    if (totalScore >= 470) return 'Intermediate';
    if (totalScore >= 220) return 'Elementary';
    return 'Beginner';
  }

  /// Get score color based on total score
  static String getScoreColor(int totalScore) {
    if (totalScore >= 860) return '#4CAF50'; // Green
    if (totalScore >= 730) return '#8BC34A'; // Light Green
    if (totalScore >= 470) return '#FFC107'; // Amber
    if (totalScore >= 220) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }
}
