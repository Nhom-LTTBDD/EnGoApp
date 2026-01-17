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
import '../../../domain/entities/user.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../providers/theme/theme_provider.dart';
import '../../providers/personal_vocabulary_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar_color_picker_dialog.dart';
import '../../widgets/custom_icon_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data khi vào trang (nếu chưa có)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      // Chỉ load nếu chưa có data hoặc đang initial state
      if (profileProvider.currentUser == null ||
          profileProvider.state is ProfileInitial) {
        profileProvider.getUserProfile();
      }
    });
  }

  /// Shimmer loading placeholder
  Widget _buildShimmerLoading(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              themeExt?.backgroundGradientColors ??
              [Colors.white, const Color(0xFFB2E0FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar shimmer
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeExt?.shimmerBaseColor ?? Colors.grey[300],
            ),
          ),
          const SizedBox(height: 30),
          // Info shimmer
          Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (themeExt?.cardBackground ?? Colors.white).withOpacity(
                themeExt?.surfaceOpacity ?? 0.8,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _shimmerLine(context, width: 200),
                const SizedBox(height: 15),
                _shimmerLine(context, width: 180),
                const SizedBox(height: 15),
                _shimmerLine(context, width: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine(BuildContext context, {required double width}) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();

    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: themeExt?.shimmerBaseColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
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

  /// Tạo màu avatar dựa trên tên hoặc màu tùy chỉnh
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

  void _showColorPicker(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final currentColor = profileProvider.currentUser?.avatarColor;

    showDialog(
      context: context,
      builder: (context) => AvatarColorPickerDialog(
        currentColor: currentColor,
        onColorSelected: (color) {
          profileProvider.updateAvatarColor(color);
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'EnGo App',
      currentIndex: 1,
      child: Selector<AuthProvider, bool>(
        selector: (_, provider) => provider.state is Unauthenticated,
        builder: (context, isUnauthenticated, _) {
          // Listen to auth state for logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isUnauthenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          });

          return Selector<ProfileProvider, ProfileState>(
            selector: (_, provider) => provider.state,
            shouldRebuild: (previous, current) => previous != current,
            builder: (context, profileState, _) {
              final profileProvider = context.read<ProfileProvider>();
              final user = profileProvider.currentUser;

              // Handle loading state - Use shimmer nếu chưa có data
              if (profileState is ProfileLoading && user == null) {
                return _buildShimmerLoading(context);
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

              final themeExt = Theme.of(context).extension<AppThemeExtension>();

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        themeExt?.backgroundGradientColors ??
                        [Colors.white, const Color(0xFFB2E0FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      // Header Row: Avatar + Streak
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar với button chọn màu
                          Stack(
                            children: [
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
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CustomIconButton(
                                  icon: Icons.palette,
                                  onTap: () => _showColorPicker(context),
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
                          ),

                          // Streak
                          Consumer<StreakProvider>(
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
                                      SvgPicture.asset(
                                        kIconFire,
                                        width: 38,
                                        height: 48,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Streak',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // User Info Card với Edit và Logout
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (themeExt?.cardBackground ?? Colors.white)
                              .withOpacity(themeExt?.surfaceOpacity ?? 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Header với Edit button
                            Row(
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
                                    // Reload profile if update was successful
                                    if (result == true && context.mounted) {
                                      context
                                          .read<ProfileProvider>()
                                          .getUserProfile();
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
                            ),
                            const SizedBox(height: 12),
                            // User info
                            _buildInfoRow(
                              context,
                              Icons.person,
                              user?.name ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.cake,
                              user?.birthDate ?? 'Chưa cập nhật',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Icons.email,
                              user?.email ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (themeExt?.cardBackground ?? Colors.white)
                              .withOpacity(themeExt?.surfaceOpacity ?? 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Thống kê học tập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Consumer<PersonalVocabularyProvider>(
                                    builder: (context, vocabProvider, _) {
                                      return AppButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.personalVocabByTopic,
                                          );
                                        },
                                        text: '${vocabProvider.topicCount} từ',
                                        variant: AppButtonVariant.primary,
                                        size: AppButtonSize.medium,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppButton(
                                    onPressed: () {
                                      // TODO: Tính năng flashcard chưa có
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Tính năng flashcard đang được phát triển',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    text: 'Flashcard',
                                    variant: AppButtonVariant.success,
                                    size: AppButtonSize.medium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                onPressed: () {},
                                text: 'Xem tiến trình học',
                                variant: AppButtonVariant.accent,
                                size: AppButtonSize.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Settings Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (themeExt?.cardBackground ?? Colors.white)
                              .withOpacity(themeExt?.surfaceOpacity ?? 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Cài đặt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Consumer<ThemeProvider>(
                                    builder: (context, themeProvider, _) {
                                      return AppButton(
                                        onPressed: () =>
                                            themeProvider.toggleTheme(),
                                        icon: themeProvider.isDarkMode
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        text: themeProvider.isDarkMode
                                            ? 'Sáng'
                                            : 'Tối',
                                        variant: AppButtonVariant.accent,
                                        size: AppButtonSize.small,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppButton(
                                    onPressed: () {},
                                    icon: Icons.language,
                                    text: 'Ngôn ngữ',
                                    variant: AppButtonVariant.accent,
                                    size: AppButtonSize.small,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logout Button
                      Selector<AuthProvider, bool>(
                        selector: (_, provider) =>
                            provider.state is AuthLoading,
                        builder: (context, isLoading, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: isLoading
                                  ? 'Đang đăng xuất...'
                                  : 'Đăng xuất',
                              onPressed: isLoading
                                  ? null
                                  : () => _handleLogout(context),
                              variant: AppButtonVariant.danger,
                              size: AppButtonSize.medium,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
