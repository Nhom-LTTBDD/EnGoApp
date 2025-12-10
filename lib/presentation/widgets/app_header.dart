/*
 * app_header.dart
 *
 * Chức năng:
 * - Header / top bar chuẩn của app (title, leading/back, actions, optional subtitle).
 * - Chuẩn hóa paddings, elevation, background, và text styles.
 *
 * Được sử dụng ở đâu:
 * - Hầu hết các trang có AppBar: Home, LessonDetail, Profile, Search, Settings.
 *
 * API (props) gợi ý:
 * - final String title;
 * - final Widget? leading;
 * - final List<Widget>? actions;
 * - final String? subtitle;
 * - final bool centerTitle;
 *
 * Lưu ý:
 * - Dùng PreferredSizeWidget khi tạo custom AppBar để tương thích Scaffold.appBar.
 * - Hỗ trợ back button tự động khi Navigator.canPop.
 * - Sử dụng theme text styles (app_text_styles) và màu từ app_colors.
 * - Accessibility: semantic labels, ensure tappable areas >= 48x48.
 * - Test: hiển thị title dài, leading/actions click behaviors, dark/light theme compatibility.
 *
 * Ví dụ dùng:
 * AppHeader(title: 'Bài học', actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})]);
 */
