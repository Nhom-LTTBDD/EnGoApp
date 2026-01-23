// lib/presentation/widgets/profile/profile_stats_card.dart
// Card hiển thị thống kê học tập
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/personal_vocabulary_provider.dart';
import '../common/app_button.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

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
            'Thống kê học tập',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Button xem bộ từ cá nhân
          Consumer<PersonalVocabularyProvider>(
            builder: (context, vocabProvider, _) {
              return AppButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.personalVocabByTopic);
                },
                text: '${vocabProvider.topicCount} bộ từ',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
              );
            },
          ),
          const SizedBox(height: 12),
          // Button xem kết quả test
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.test);
              },
              text: 'Xem kết quả bài test',
              variant: AppButtonVariant.success,
              size: AppButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
