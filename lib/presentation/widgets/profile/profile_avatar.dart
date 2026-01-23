// lib/presentation/widgets/profile/profile_avatar.dart
// Widget hiển thị avatar với button chọn màu
import 'package:flutter/material.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../avatar_color_picker_dialog.dart';
import '../custom_icon_button.dart';

class ProfileAvatar extends StatelessWidget {
  final User? user;
  final VoidCallback onColorPickerTap;

  const ProfileAvatar({
    super.key,
    required this.user,
    required this.onColorPickerTap,
  });

  /// Lấy chữ cái đầu của tên để làm avatar
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      // Lấy chữ cái đầu của từ đầu và từ cuối
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  /// Tạo màu avatar dựa trên màu tùy chỉnh hoặc auto-generate
  Color _getAvatarColor(User? user) {
    // Nếu user đã chọn màu custom
    if (user?.avatarColor != null) {
      return AvatarColorPickerDialog.getColorFromName(user!.avatarColor!);
    }

    // Fallback: màu auto theo hashCode
    final name = user?.name ?? 'U';
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF3F51B5), // Indigo
    ];

    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar với shadow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: _getAvatarColor(user),
            child: Text(
              _getInitials(user?.name ?? 'User'),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Button chọn màu
        Positioned(
          bottom: 0,
          right: 0,
          child: CustomIconButton(
            icon: Icons.palette,
            onTap: onColorPickerTap,
            backgroundColor: Colors.white,
            iconColor: kPrimaryColor,
            size: 36,
            iconSize: 20,
            shadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
