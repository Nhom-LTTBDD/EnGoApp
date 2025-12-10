/*
 * navbar_bottom.dart
 *
 * Chức năng:
 * - Thanh điều hướng dưới cùng (Bottom Navigation Bar) chứa các tab chính của app.
 * - Quản lý highlight tab hiện tại, hiển thị badge/indicator, hỗ trợ FAB notch nếu cần.
 *
 * Được sử dụng ở đâu:
 * - Scaffold chính của app (root page), trong MainShell / HomeScreen.
 *
 * API (props) gợi ý:
 * - final int currentIndex;
 * - final ValueChanged<int> onTap;
 * - final List<BottomNavigationBarItem> items; // hoặc custom model (icon, label, badge)
 * - final bool showFAB;
 * - final Color? backgroundColor;
 *
 * Lưu ý:
 * - Đặt trong SafeArea để tránh cắt trên các device có insets.
 * - Dùng semanticsLabel cho các icon để hỗ trợ screen reader.
 * - Nếu có badge động, chỉ render widget badge khi cần (avoid rebuilds).
 * - Nếu có notch, đảm bảo scaffold dùng FloatingActionButtonLocation.centerDocked.
 * - Test: kiểm tra onTap index, hiển thị đúng label/icon, xử lý disable state.
 *
 * Ví dụ dùng:
 * NavBarBottom(
 *   currentIndex: 0,
 *   items: [
 *     NavItem(icon: Icons.home, label: 'Home'),
 *     NavItem(icon: Icons.book, label: 'Lessons'),
 *     NavItem(icon: Icons.person, label: 'Profile'),
 *   ],
 *   onTap: (i) => pageController.jumpToPage(i),
 * )
 */
