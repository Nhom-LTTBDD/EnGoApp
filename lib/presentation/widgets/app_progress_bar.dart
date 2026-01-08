/*
 * app_progress_bar.dart
 *
 * Chức năng:
 * - Wrapper/consistently-styled progress bar dùng toàn app (linear hoặc circular).
 * - Đặt kích thước, màu sắc, animation, và accessibility mặc định cho tiến trình.
 *
 * Được sử dụng ở đâu:
 * - Trong LessonCard, profile completion, test results, trang course progress.
 *
 * API (props) gợi ý:
 * - final double? value; // 0.0 - 1.0, null = indeterminate
 * - final double height;
 * - final Color? backgroundColor;
 * - final Color? foregroundColor;
 * - final Duration animationDuration;
 *
 * Lưu ý:
 * - Nếu value null => show indeterminate (Circular/LinearProgressIndicator).
 * - Dùng AnimatedContainer/AnimatedSwitcher để animate khi value thay đổi mượt hơn.
 * - Accessibility: thêm semanticsLabel và semanticsValue (ví dụ "Progress: 35%").
 * - Reusable: export cả Linear và Circular nếu project cần.
 *
 * Ví dụ dùng:
 * AppProgressBar(value: 0.6, height: 6.0);
 */
