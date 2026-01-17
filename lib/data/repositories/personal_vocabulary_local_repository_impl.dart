// lib/data/repositories/personal_vocabulary_local_repository_impl.dart
// EXAMPLE - Implementation khi muốn migrate từ Service sang Repository pattern

import '../../domain/repository_interfaces/personal_vocabulary_repository.dart';
import '../../core/services/personal_vocabulary_service.dart';

/// Local implementation của PersonalVocabularyRepository
///
/// Sử dụng SharedPreferences thông qua PersonalVocabularyService
///
/// CHƯA SỬ DỤNG - Đây là example cho việc migrate sau này
class PersonalVocabularyLocalRepositoryImpl
    implements PersonalVocabularyRepository {
  final PersonalVocabularyService _service;

  PersonalVocabularyLocalRepositoryImpl({
    required PersonalVocabularyService service,
  }) : _service = service;

  @override
  Future<List<String>> getBookmarkedCardIds(String userId) async {
    return await _service.getBookmarkedCardIds(userId);
  }

  @override
  Future<void> addCard(String userId, String cardId) async {
    await _service.addCard(userId, cardId);
  }

  @override
  Future<void> removeCard(String userId, String cardId) async {
    await _service.removeCard(userId, cardId);
  }

  @override
  Future<bool> toggleBookmark(String userId, String cardId) async {
    return await _service.toggleBookmark(userId, cardId);
  }

  @override
  Future<bool> isBookmarked(String userId, String cardId) async {
    return await _service.isBookmarked(userId, cardId);
  }

  @override
  Future<void> clearAll(String userId) async {
    await _service.clearAll(userId);
  }

  @override
  Future<int> getCardCount(String userId) async {
    final cardIds = await _service.getBookmarkedCardIds(userId);
    return cardIds.length;
  }

  @override
  Future<Map<String, int>> getStatsByTopic(String userId) async {
    // TODO: Implement topic statistics
    // Cần load actual cards và group by topic
    return {};
  }

  @override
  Future<void> syncToRemote(String userId) async {
    // No-op for local-only implementation
  }

  @override
  Future<void> syncFromRemote(String userId) async {
    // No-op for local-only implementation
  }
}
