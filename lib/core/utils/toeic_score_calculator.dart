// lib/core/utils/toeic_score_calculator.dart

class ToeicScoreCalculator {
  /// Calculate TOEIC listening score based on correct answers
  /// TOEIC Listening has 100 questions, scored from 5-495
  /// Mỗi câu đúng = 5 điểm, nhưng cần 97/100 để đạt 495 (max)
  /// 0/100 = 5 điểm (minimum)
  static int calculateListeningScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 5;

    // Minimum score is 5
    if (correctAnswers <= 0) return 5;

    // Maximum score is 495 at 97+ correct answers
    if (correctAnswers >= 97) return 495;

    // Linear scaling: from 5 (at 0) to 495 (at 97)
    // Score = 5 + (correctAnswers / 97) * 490
    final score = 5 + ((correctAnswers / 97) * 490).round();
    return score.clamp(5, 495);
  }

  /// Calculate TOEIC reading score based on correct answers
  /// TOEIC Reading has 100 questions, scored from 5-495
  /// Mỗi câu đúng = 5 điểm, cần 100/100 để đạt 495 (max)
  /// 0/100 = 5 điểm (minimum)
  static int calculateReadingScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 5;

    // Minimum score is 5
    if (correctAnswers <= 0) return 5;

    // Maximum score is 495 at 100 correct answers
    if (correctAnswers >= totalQuestions) return 495;

    // Linear scaling: from 5 (at 0) to 495 (at 100)
    // Score = 5 + (correctAnswers / 100) * 490
    final score = 5 + ((correctAnswers / totalQuestions) * 490).round();
    return score.clamp(5, 495);
  }

  /// Calculate total TOEIC score (listening + reading)
  /// Total score range: 10-990
  /// 197/200 correct (97 listening + 100 reading) = 990
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
