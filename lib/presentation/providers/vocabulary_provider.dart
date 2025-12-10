/*
 * vocabulary_provider.dart
 *
 * Chức năng:
 * - Quản lý state liên quan đến danh sách từ vựng và chi tiết từ: load list, load detail, tìm kiếm, phân trang, favorite toggle, sync local.
 *
 * Được sử dụng ở đâu:
 * - VocabularyListScreen, LessonScreen, SearchScreen, Review/Flashcard screens.
 *
 * API (public/state) gợi ý:
 * - List<Vocabulary> items;
 * - Vocabulary? selected;
 * - RequestState state; // e.g., idle/loading/loaded/error
 * - String? errorMessage;
 * - Future<void> loadList({int page});
 * - Future<void> search(String q);
 * - Future<void> loadDetail(String id);
 * - Future<void> toggleFavorite(String id);
 *
 * Lưu ý kỹ thuật:
 * - Tách logic network/local vào repository; provider chỉ orchestration + notifyListeners()/state updates.
 * - Sử dụng debounce cho search để tránh spam API.
 * - Phân trang: expose hasMore, isLoadingMore để UI render load more.
 * - Xử lý lỗi rõ ràng: set state = error + lưu errorMessage để UI show.
 * - Testable: inject repository qua constructor, mock trong unit tests.
 * - Performance: khi danh sách lớn, giữ immutable list replace/rebuild minimal; dùng selectors để tránh rebuild UI không cần thiết.
 */
