// lib/domain/usecases/flashcard/reset_flashcard_progress.dart

import '../../repository_interfaces/flashcard_progress_repository.dart';

class ResetFlashcardProgress {
  final FlashcardProgressRepository _repository;

  ResetFlashcardProgress(this._repository);

  Future<void> call({required String userId, required String topicId}) async {
    await _repository.resetProgress(userId: userId, topicId: topicId);
  }
}
