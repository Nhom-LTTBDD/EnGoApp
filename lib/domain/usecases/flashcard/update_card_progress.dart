// lib/domain/usecases/flashcard/update_card_progress.dart

import '../../repository_interfaces/flashcard_progress_repository.dart';

class UpdateCardProgress {
  final FlashcardProgressRepository _repository;

  UpdateCardProgress(this._repository);

  Future<void> call({
    required String userId,
    required String topicId,
    required List<String> masteredCardIds,
    required List<String> learningCardIds,
  }) async {
    await _repository.updateCardProgress(
      userId: userId,
      topicId: topicId,
      masteredCardIds: masteredCardIds,
      learningCardIds: learningCardIds,
    );
  }
}
