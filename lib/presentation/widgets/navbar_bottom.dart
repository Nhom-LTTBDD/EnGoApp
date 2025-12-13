// lib/presentation/widgets/navbar_bottom.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_colors.dart';

/// Simple bottom nav that navigates directly to home/profile by name.
/// Note: make sure '/home' and '/profile' are defined in your routes.
class NavBarBottom extends StatelessWidget {
  const NavBarBottom({Key? key}) : super(key: key);

  int _currentIndexFromRoute(BuildContext context) {
    final String? name = ModalRoute.of(context)?.settings.name;
    if (name == '/profile' || name == 'profile') return 1;
    return 0; // default to home
  }

  void _handleTap(BuildContext context, int index) {
    final target = index == 0 ? '/home' : '/profile';
    // use pushReplacementNamed to avoid stacking multiple roots
    if (ModalRoute.of(context)?.settings.name != target) {
      Navigator.pushReplacementNamed(context, target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndexFromRoute(context);
    return BottomNavigationBar(
      backgroundColor: kPrimaryColor,
      currentIndex: currentIndex,
      onTap: (i) => _handleTap(context, i),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
