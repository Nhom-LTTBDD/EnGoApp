// lib/presentation/pages/profile/profile_page.dart
// Trang hồ sơ người dùng.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_assets.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../widgets/app_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getUserProfile();
    });
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }

  /// Lấy chữ cái đầu của tên để làm avatar
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      // Lấy chữ cái đầu của 2 từ đầu tiên
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  /// Tạo màu avatar dựa trên tên
  Color _getAvatarColor(String name) {
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
    return MainLayout(
      title: 'EnGo App',
      currentIndex: 1,
      child: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, _) {
          // Listen to auth state for logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.state is Unauthenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          });

          final profileState = profileProvider.state;
          final user = profileProvider.currentUser;

          // Handle loading state
          if (profileState is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          // Handle error state
          if (profileState is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(profileState.message, style: kBody),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Thử lại',
                    onPressed: () => profileProvider.getUserProfile(),
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.medium,
                    isFullWidth: false,
                  ),
                ],
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            decoration: const BoxDecoration(gradient: kBackgroundGradient),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar mặc định với chữ cái đầu
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: _getAvatarColor(user?.name ?? 'U'),
                      child: Text(
                        _getInitials(user?.name ?? 'User'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Info Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, color: kPrimaryColor),
                                const SizedBox(width: 10),
                                Text(user?.name ?? 'N/A', style: kBody),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cake, color: kPrimaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  user?.birthDate ?? 'Chưa cập nhật',
                                  style: kBody,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.email, color: kPrimaryColor),
                                const SizedBox(width: 10),
                                Text(user?.email ?? 'N/A', style: kBody),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        AppButton(
                          icon: Icons.edit,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                          variant: AppButtonVariant.borderSuccess,
                          size: AppButtonSize.small,
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Logout Button
                  AppButton(
                    text: authProvider.state is AuthLoading
                        ? 'Đang đăng xuất...'
                        : 'Logout',
                    onPressed: authProvider.state is AuthLoading
                        ? null
                        : () => _handleLogout(context),
                    variant: AppButtonVariant.danger,
                    size: AppButtonSize.small,
                    isFullWidth: false,
                  ),
                  const SizedBox(height: 30),

                  // Streak
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '10',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: kDanger,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SvgPicture.asset(kIconFire, width: 45, height: 55),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Settings buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        onPressed: () {},
                        icon: Icons.dark_mode,
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.small,
                        isFullWidth: false,
                      ),
                      const SizedBox(width: 20),
                      AppButton(
                        onPressed: () {},
                        icon: Icons.language,
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.small,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        onPressed: () {},
                        text: '20 bộ từ',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.xLarge,
                        isFullWidth: false,
                      ),
                      const SizedBox(width: 20),
                      AppButton(
                        onPressed: () {},
                        text: '15 bài học',
                        variant: AppButtonVariant.success,
                        size: AppButtonSize.xLarge,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  AppButton(
                    onPressed: () {},
                    text: 'Xem tiến trình học',
                    variant: AppButtonVariant.accent,
                    size: AppButtonSize.xLarge,
                    isFullWidth: false,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
