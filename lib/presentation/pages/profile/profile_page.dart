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
import '../../providers/profile/streak_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/profile/avatar_color_picker_dialog.dart';
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
  bool _hasNavigated = false; // Flag để tránh duplicate navigation
  bool _hasSyncedUserId = false; // Flag để tránh sync userId nhiều lần
  bool _hasCheckedStreakBreak = false; // Flag để check streak break một lần

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

  /// Hiển thị dialog khi streak bị break (chạy trong microtask để không block)
  void _checkAndShowStreakBreakDialog() {
    if (_hasCheckedStreakBreak) return;

    final streakProvider = context.read<StreakProvider>();

    // Chỉ check sau khi streak đã load xong
    if (streakProvider.isLoading) return;

    // Check nếu streak bị break và chưa hiển thị thông báo
    if (streakProvider.hasStreakBroken &&
        !streakProvider.hasShownBreakNotification) {
      _hasCheckedStreakBreak = true;

      // Show dialog trong microtask để không block current frame
      Future.microtask(() {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.heart_broken, color: kDanger, size: 28),
                const SizedBox(width: 12),
                const Text('💔 Streak bị mất!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn đã mất chuỗi học ${streakProvider.previousStreak} ngày!',
                  style: kBodyEmphasized.copyWith(color: kDanger),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Không sao! Hãy bắt đầu lại và xây dựng chuỗi học mới thật mạnh mẽ! 💪',
                  style: kBody,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mẹo: Học mỗi ngày để duy trì streak!',
                          style: TextStyle(fontSize: 13, color: kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Mark as shown
                  streakProvider.markBreakNotificationShown();
                },
                child: const Text('Tiếp tục học!'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Ngăn swipe back vì đây là tab chính
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // Không làm gì - giữ user ở trang profile
        // Nếu muốn về home, dùng bottom navigation
      },
      child: MainLayout(
        title: 'EnGo App',
        currentIndex: 1,
        child: Selector<AuthProvider, bool>(
          selector: (_, provider) => provider.state is Unauthenticated,
          builder: (context, isUnauthenticated, _) {
            // Navigate khi unauthenticated - chỉ navigate một lần
            if (isUnauthenticated && !_hasNavigated) {
              _hasNavigated = true;
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
                    _hasInitialized &&
                    !_hasSyncedUserId) {
                  _hasSyncedUserId = true;
                  // Sync trong microtask để không block current frame
                  Future.microtask(() {
                    if (mounted) {
                      _syncUserId(user.id);
                      // Check streak break sau khi sync xong
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          _checkAndShowStreakBreakDialog();
                        }
                      });
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

                final themeExt = Theme.of(
                  context,
                ).extension<AppThemeExtension>();

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
      ),
    );
  }
}
