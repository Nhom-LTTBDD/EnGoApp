// lib/presentation/widgets/vocabulary/profile_section.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';

class ProfileSection extends StatelessWidget {
  final int cardCount;
  final String? userName;

  const ProfileSection({
    super.key,
    required this.cardCount,
    this.userName = 'Name',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: kSecondaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: getSurfaceColor(context), size: 24),
        ),
        const SizedBox(width: spaceMd),
        // Name and terms count
        Text(
          userName!,
          style: const TextStyle(fontSize: 14, color: kTextThird),
        ),
        const SizedBox(width: 45),
        Text(
          '$cardCount thuật ngữ',
          style: const TextStyle(
            fontSize: 14,
            color: kTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
