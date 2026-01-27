// lib/domain/use_cases/get_grammar_lessons_use_case.dart
// Use case để lấy danh sách grammar lessons

import '../../entities/grammar_lesson.dart';
import '../../repository_interfaces/grammar_repository.dart';

/// Get grammar lessons use case
class GetGrammarLessonsUseCase {
  final GrammarRepository _grammarRepository;

  GetGrammarLessonsUseCase(this._grammarRepository);
  /// Execute use case để lấy lessons theo topic ID
  /// 
  /// **Flow:**
  /// 1. Fetch lessons từ repository
  /// 2. Sort lessons theo level (beginner -> intermediate -> advanced)
  /// 3. Return sorted list
  /// 
  /// **Note:** Grammar chỉ xem lý thuyết nên không sort theo status
  Future<List<GrammarLesson>> call(String topicId) async {
    try {
      final lessons = await _grammarRepository.getLessonsByTopicId(topicId);

      // Sort lessons theo level (beginner -> intermediate -> advanced)
      lessons.sort((a, b) => a.level.index.compareTo(b.level.index));

      return lessons;
    } catch (e) {
      throw Exception('Failed to get grammar lessons: ${e.toString()}');
    }
  }
}
