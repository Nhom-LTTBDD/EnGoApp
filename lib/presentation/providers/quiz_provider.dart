/*
 * quiz_provider.dart
 *
 * Chức năng:
 * - Quản lý state cho các quiz ngắn: load câu hỏi, randomize/chọn độ khó, track progress, feedback từng câu.
 *
 * Được sử dụng ở đâu:
 * - QuizWidget, QuickPracticeScreen, Home mini-quiz card.
 *
 * API (public/state) gợi ý:
 * - List<Question> questions;
 * - int index;
 * - bool isLoading;
 * - bool isCompleted;
 * - Future<void> loadQuiz({String? topic, int count});
 * - void answerCurrent(Answer a);
 * - void next();
 * - void restart();
 *
 * Lưu ý kỹ thuật:
 * - Nếu randomize, giữ seed để reproducible tests in debug.
 * - Expose minimal state needed cho UI; avoid exposing raw internal data structures.
 * - Debounce rapid taps to avoid double submit.
 * - Inject data source for testability.
 * - Consider streaming updates (Stream/ValueNotifier) nếu quiz UI cần real-time animations.
 */
