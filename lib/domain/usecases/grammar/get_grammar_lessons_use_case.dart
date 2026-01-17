// lib/domain/use_cases/get_grammar_lessons_use_case.dart
// Use case để lấy danh sách grammar lessons

import '../../entities/grammar_lesson.dart';
import '../../repository_interfaces/grammar_repository.dart';

/// Get grammar lessons use case
class GetGrammarLessonsUseCase {
  final GrammarRepository _grammarRepository;

  GetGrammarLessonsUseCase(this._grammarRepository);

  /// Execute use case to get lessons by topic ID
  Future<List<GrammarLesson>> call(String topicId) async {
    try {
      final lessons = await _grammarRepository.getLessonsByTopicId(topicId);

      // Sort lessons by status and difficulty
      lessons.sort((a, b) {
        // Prioritize available lessons
        if (a.isAvailable && !b.isAvailable) return -1;
        if (!a.isAvailable && b.isAvailable) return 1;

        // Then prioritize in-progress lessons
        if (a.status == GrammarLessonStatus.inProgress &&
            b.status != GrammarLessonStatus.inProgress)
          return -1;
        if (a.status != GrammarLessonStatus.inProgress &&
            b.status == GrammarLessonStatus.inProgress)
          return 1;

        // Finally sort by level
        return a.level.index.compareTo(b.level.index);
      });

      return lessons;
    } catch (e) {
      throw Exception('Failed to get grammar lessons: ${e.toString()}');
    }
  }
}
