// lib/presentation/widgets/profile/profile_info_card.dart
// Card hiển thị thông tin cá nhân
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../providers/profile/profile_provider.dart';
import '../custom_icon_button.dart';

class ProfileInfoCard extends StatelessWidget {
  final User? user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (themeExt?.cardBackground ?? Colors.white).withOpacity(
          themeExt?.surfaceOpacity ?? 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.person, user?.name ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.cake,
            user?.birthDate ?? 'Chưa cập nhật',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.email, user?.email ?? 'N/A'),
        ],
      ),
    );
  }

  /// Widget header với title và edit button
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        CustomIconButton(
          icon: Icons.edit,
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.editProfile,
            );
            // Reload profile nếu update thành công
            if (result == true && context.mounted) {
              context.read<ProfileProvider>().getUserProfile();
            }
          },
          backgroundColor: Colors.white,
          iconColor: kSuccess,
          size: 32,
          iconSize: 16,
          shadow: [
            BoxShadow(
              color: kSuccess.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
      ],
    );
  }

  /// Widget hiển thị một dòng thông tin với icon và text
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: kBody.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
