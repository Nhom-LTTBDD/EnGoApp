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
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

/// Simple header that shows only the app logo (no back button, no actions).
/// Use: AppHeader.logoOnly();
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double elevation;

  const AppHeader({Key? key, required this.title, this.elevation = 0.0})
    : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: elevation,
      automaticallyImplyLeading: false, // no back button
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: kPrimaryColor),
            child: Image.asset(
              kSwiftPng,
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
