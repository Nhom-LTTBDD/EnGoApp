// lib/domain/usecases/flashcard/get_flashcard_progress.dart

import '../../entities/flashcard_progress.dart';
import '../../repository_interfaces/flashcard_progress_repository.dart';

class GetFlashcardProgress {
  final FlashcardProgressRepository _repository;

  GetFlashcardProgress(this._repository);

  Future<FlashcardProgress?> call({
    required String userId,
    required String topicId,
  }) async {
    return await _repository.getProgress(userId: userId, topicId: topicId);
  }
}
