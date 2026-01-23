// lib/presentation/widgets/profile/profile_header.dart
// Widget header với avatar và streak counter
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/core/constants/app_assets.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../providers/streak_provider.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onColorPickerTap;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onColorPickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar với button chọn màu
        ProfileAvatar(user: user, onColorPickerTap: onColorPickerTap),
        // Streak counter
        _buildStreakCounter(context),
      ],
    );
  }

  /// Widget hiển thị streak counter
  Widget _buildStreakCounter(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, _) {
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${streakProvider.currentStreak}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kDanger,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(kIconFire, width: 38, height: 48),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Streak',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
