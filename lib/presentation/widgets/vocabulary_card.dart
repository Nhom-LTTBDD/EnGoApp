/*
 * vocabulary_card.dart
 *
 * Chức năng:
 * - Hiển thị một thẻ từ vựng (term, phát âm, nghĩa, ví dụ, ảnh/biểu tượng).
 * - Cung cấp các hành động thường gặp: mở chi tiết, phát audio, đánh dấu yêu thích.
 *
 * Được sử dụng ở đâu:
 * - Danh sách từ vựng (vocabulary list), trang bài học (lesson), kết quả tìm kiếm, màn hình ôn tập.
 *
 * API (props) gợi ý:
 * - final String term;
 * - final String? phonetic;
 * - final String? meaning;
 * - final String? example;
 * - final String? imagePath; // asset hoặc network
 * - final bool isFavorite;
 * - final VoidCallback? onTap;
 * - final VoidCallback? onPlayAudio;
 * - final ValueChanged<bool>? onToggleFavorite;
 * - final VocabularyCardVariant variant; // compact / detailed / quiz
 *
 * Lưu ý:
 * - Giữ widget stateless nếu không cần state cục bộ; mọi logic fetch/format để ra ngoài.
 * - Xử lý null/placeholder cho image và text (avoid runtime exceptions).
 * - Dùng CachedNetworkImage hoặc precache để tránh jank khi load ảnh từ network.
 * - Hỗ trợ keyboard / semantics: cung cấp semanticLabel cho các nút và thẻ.
 * - Kích thước, paddings, textstyle nên dùng constants (app_spacing, app_text_styles).
 * - Testable: tách UI render và callback để dễ mock trong unit/widget tests.
 *
 * Ví dụ dùng:
 * VocabularyCard(
 *   term: 'apple',
 *   phonetic: '/ˈæp.əl/',
 *   meaning: 'quả táo',
 *   imagePath: kLogoPng,
 *   isFavorite: false,
 *   onTap: () => navigateToDetail('apple'),
 *   onPlayAudio: () => playAudio('apple'),
 * )
 */
