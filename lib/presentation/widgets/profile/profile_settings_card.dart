// lib/presentation/widgets/profile/profile_settings_card.dart
// Card hiển thị cài đặt
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme/theme_provider.dart';
import '../app_button.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key});

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
              // Button toggle theme
              Expanded(
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return AppButton(
                      onPressed: () => themeProvider.toggleTheme(),
                      icon: themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      text: themeProvider.isDarkMode ? 'Sáng' : 'Tối',
                      variant: AppButtonVariant.accent,
                      size: AppButtonSize.small,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Button ngôn ngữ (placeholder)
              Expanded(
                child: AppButton(
                  onPressed: () {
                    // TODO: Implement language selection
                  },
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
    );
  }
}
