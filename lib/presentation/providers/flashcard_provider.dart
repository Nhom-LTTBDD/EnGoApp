/*
 * flashcard_provider.dart
 *
 * Chức năng:
 * - Quản lý bộ flashcard: load cards, next/prev, flip card, đánh dấu known/unknown, spaced repetition metadata (optional).
 *
 * Được sử dụng ở đâu:
 * - FlashcardScreen, ReviewFlow, LearningSession.
 *
 * API (public/state) gợi ý:
 * - List<Flashcard> cards;
 * - int currentIndex;
 * - bool isFront; // mặt hiện tại
 * - Future<void> loadDeck(String deckId);
 * - void flip();
 * - void markKnown(bool known);
 * - void next();
 * - void previous();
 *
 * Lưu ý kỹ thuật:
 * - Không lưu logic SRS nặng trong provider trừ khi cần; tách ra service SRS riêng.
 * - Khi flip/transition, dùng AnimationController/ValueNotifier để giảm rebuild toàn bộ màn hình.
 * - Persist review results (local db) sau mỗi đánh dấu để tránh mất progress.
 * - Hỗ trợ resume session bằng cách lưu lastIndex.
 * - Test: UI flip animation và markKnown side effects.
 */
