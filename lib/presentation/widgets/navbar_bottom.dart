// lib/presentation/widgets/navbar_bottom.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/routes/app_routes.dart';
import 'package:en_go_app/core/constants/app_colors.dart';

/// Bottom nav that determines current index from route (can be overridden)
/// and performs navigation here (index -> route). Keeps existing colors.
class NavBarBottom extends StatelessWidget {
  const NavBarBottom({super.key, this.currentIndex});

  /// Optional override from caller
  final int? currentIndex;

  int _getCurrentIndex(String? routeName) {
    switch (routeName) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.profile:
        return 1;      case AppRoutes.vocab:
      case AppRoutes.grammar:
        return -1; // No bottom nav highlight for these pages
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index, int currentIdx) {
    if (index == currentIdx) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final idx = currentIndex ?? _getCurrentIndex(routeName);

    // Không highlight khi idx = -1 hoặc invalid
    final displayIndex = (idx >= 0 && idx < 2) ? idx : null;

    return BottomNavigationBar(
      backgroundColor: kPrimaryColor,
      currentIndex: displayIndex ?? 0,
      selectedItemColor: displayIndex != null ? Colors.white : Colors.white70,
      unselectedItemColor: Colors.white70,
      onTap: (i) => _onTap(context, i, idx),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
