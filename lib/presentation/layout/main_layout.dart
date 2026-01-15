// lib/presentation/layout/main_layout.dart
import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/navbar_bottom.dart';

/// Main layout with app bar and bottom navigation bar
class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final bool showBottomNav;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.title,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: title, elevation: 0.0),
      bottomNavigationBar: showBottomNav
          ? NavBarBottom(currentIndex: currentIndex)
          : null,
      body: child,
    );
  }
}
