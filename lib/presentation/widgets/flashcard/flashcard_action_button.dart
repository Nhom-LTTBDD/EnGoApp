import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_helper.dart';

class FlashcardActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool hasBackground;
  final VoidCallback onTap;

  const FlashcardActionButton({
    super.key,
    this.icon,
    required this.label,
    this.hasBackground = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildActionButton(
      context: context,
      icon: icon,
      label: label,
      hasBackground: hasBackground,
      onTap: onTap,
    );
  }
}

Widget _buildActionButton({
  required BuildContext context,
  IconData? icon,
  required String label,
  required bool hasBackground,
  required VoidCallback onTap,
}) {
  if (hasBackground) {
    // Elevated button with background and shadow
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 20),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  } else {
    // Text button without background
    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: getTextPrimary(context),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
