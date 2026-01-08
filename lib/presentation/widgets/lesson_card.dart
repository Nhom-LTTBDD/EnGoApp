/*
 * lesson_card.dart
 *
 * Chức năng:
 * - Hiển thị thông tin tóm tắt một bài học: tiêu đề, mô tả ngắn, thumbnail, tiến độ hoàn thành, thời lượng, trạng thái khóa.
 * - Cung cấp hành động: mở bài học, tiếp tục học, xem chi tiết.
 *
 * Được sử dụng ở đâu:
 * - Danh sách bài học (LessonsList), trang chủ (recommended lessons), màn hình course details.
 *
 * API (props) gợi ý:
 * - final String title;
 * - final String? subtitle;
 * - final String? thumbnail; // asset/network
 * - final double progress; // 0.0 - 1.0
 * - final Duration? duration;
 * - final bool isLocked;
 * - final VoidCallback? onTap;
 *
 * Lưu ý:
 * - Hiển thị progress bar (dùng app_progress_bar) với màu semantic (kPrimaryColor / success).
 * - Nếu thumbnail từ network, dùng caching; fallback sang placeholder local nếu load fail.
 * - Nếu isLocked true, hiển thị overlay lock + semantics hidden for actions that are disabled.
 * - Tránh nặng build logic trong build(); fetch/format tách ra ngoài.
 * - Tối ưu for large lists: dùng const constructors, minimal subtree rebuilds, keys nếu cần.
 *
 * Ví dụ dùng:
 * LessonCard(
 *   title: 'Unit 1: Introductions',
 *   subtitle: 'Basic greetings',
 *   progress: 0.35,
 *   duration: Duration(minutes: 12),
 *   onTap: () => openLesson('unit1'),
 * )
 */
