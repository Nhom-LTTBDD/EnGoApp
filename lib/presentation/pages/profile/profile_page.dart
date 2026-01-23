// lib/presentation/pages/profile/profile_page.dart
// Trang hồ sơ người dùng.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../providers/personal_vocabulary_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar_color_picker_dialog.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_info_card.dart';
import '../../widgets/profile/profile_stats_card.dart';
import '../../widgets/profile/profile_settings_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load profile sau khi UI render để tránh skip frames
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInitialized) return;
      _loadProfileData();
    });
  }

  /// Load profile data một lần duy nhất
  Future<void> _loadProfileData() async {
    if (!mounted) return;

    _hasInitialized = true;
    final profileProvider = context.read<ProfileProvider>();

    // Chỉ load nếu chưa có data
    if (profileProvider.currentUser == null ||
        profileProvider.state is ProfileInitial) {
      await profileProvider.getUserProfile();
    }
  }

  /// Đồng bộ userId với các provider khác (gọi một lần duy nhất)
  void _syncUserId(String userId) {
    context.read<StreakProvider>().setUserId(userId);
    context.read<PersonalVocabularyProvider>().setUserId(userId);
  }

  /// Widget hiển thị loading state
  Widget _buildLoadingState(BuildContext context) {
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
          // Sử dụng CircularProgressIndicator đơn giản thay vì nhiều shimmer containers
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1196EF)),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading profile...',
            style: kBody.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// Xử lý đăng xuất
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

  /// Hiển thị dialog chọn màu avatar
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'EnGo App',
      currentIndex: 1,
      child: Selector<AuthProvider, bool>(
        selector: (_, provider) => provider.state is Unauthenticated,
        builder: (context, isUnauthenticated, _) {
          // Navigate khi unauthenticated
          if (isUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            });
          }

          return Selector<ProfileProvider, ProfileState>(
            selector: (_, provider) => provider.state,
            shouldRebuild: (previous, current) => previous != current,
            builder: (context, profileState, _) {
              final profileProvider = context.read<ProfileProvider>();
              final user = profileProvider.currentUser;

              // Đồng bộ userId một lần khi profile loaded lần đầu
              if (profileState is ProfileLoaded &&
                  user != null &&
                  _hasInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _syncUserId(user.id);
                  }
                });
              }

              // Hiển thị loading state nếu chưa có data
              if (profileState is ProfileLoading && user == null) {
                return _buildLoadingState(context);
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
                      // Header: Avatar + Streak
                      ProfileHeader(
                        user: user,
                        onColorPickerTap: () => _showColorPicker(context),
                      ),
                      const SizedBox(height: 20),

                      // Card thông tin cá nhân
                      ProfileInfoCard(user: user),
                      const SizedBox(height: 16),

                      // Card thống kê học tập
                      const ProfileStatsCard(),
                      const SizedBox(height: 16),

                      // Card cài đặt
                      const ProfileSettingsCard(),
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
