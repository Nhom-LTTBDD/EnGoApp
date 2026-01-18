// lib/domain/usecases/flashcard/save_flashcard_progress.dart

import '../../entities/flashcard_progress.dart';
import '../../repository_interfaces/flashcard_progress_repository.dart';

class SaveFlashcardProgress {
  final FlashcardProgressRepository _repository;

  SaveFlashcardProgress(this._repository);

  Future<void> call(FlashcardProgress progress) async {
    await _repository.saveProgress(progress);
  }
}
