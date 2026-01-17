// lib/presentation/widgets/vocab_menu_item.dart
// Widget cho các item menu trong vocab menu

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/theme_helper.dart';

class VocabMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const VocabMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        margin: const EdgeInsets.only(bottom: spaceBase),
        padding: const EdgeInsets.all(spaceMd),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: kRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,

              child: Icon(icon, color: iconColor ?? kPrimaryColor, size: 34),
            ),
            const SizedBox(width: spaceBaseSm),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: getTextPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
