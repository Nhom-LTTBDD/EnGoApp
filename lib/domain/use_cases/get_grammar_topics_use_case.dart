// lib/domain/use_cases/get_grammar_topics_use_case.dart
// Use case để lấy danh sách grammar topics

import '../entities/grammar_topic.dart';
import '../repository_interfaces/grammar_repository.dart';

/// Get grammar topics use case
class GetGrammarTopicsUseCase {
  final GrammarRepository _grammarRepository;

  GetGrammarTopicsUseCase(this._grammarRepository);

  /// Execute use case
  Future<List<GrammarTopic>> call() async {
    try {
      final topics = await _grammarRepository.getGrammarTopics();
      
      // Sort topics by level and completion status
      topics.sort((a, b) {
        // Prioritize unlocked topics
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        
        // Then sort by level
        return a.level.index.compareTo(b.level.index);
      });
      
      return topics;
    } catch (e) {
      throw Exception('Failed to get grammar topics: ${e.toString()}');
    }
  }
}
