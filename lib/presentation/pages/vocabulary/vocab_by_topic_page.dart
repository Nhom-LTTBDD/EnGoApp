// lib/presentation/pages/vocabulary/vocab_by_topic_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/constants/app_assets.dart';
import '../../widgets/topic_card.dart';

class VocabByTopicPage extends StatelessWidget {
  const VocabByTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: kBackgroundColor),
        child: Column(
          children: [
            // Subtitle section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceMd,
              ),
              color: Colors.white,
              child: const Text(
                'Bộ từ vựng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // List topics
            Expanded(
              child: Container(
                color: kBackgroundColor,
                padding: const EdgeInsets.all(spaceMd),
                child: ListView(
                  children: [
                    const SizedBox(height: spaceSm),
                    TopicCard(
                      title: 'Tên Chủ Đề',
                      imageAsset:
                          kBackgroundJpg, // Tạm thời dùng ảnh background
                      onTap: () {
                        // TODO: Navigate to topic detail
                        print('Navigate to topic detail');
                      },
                    ),
                    const SizedBox(height: spaceMd),
                    TopicCard(
                      title: 'Tên Chủ Đề',
                      imageAsset: kBackgroundJpg, // Tạm thời dùng ảnh eagle
                      onTap: () {
                        // TODO: Navigate to topic detail
                        print('Navigate to topic detail');
                      },
                    ),
                    const SizedBox(height: spaceMd),
                    TopicCard(
                      title: 'Tên Chủ Đề',
                      imageAsset: kBackgroundJpg, // Tạm thời dùng ảnh swift
                      onTap: () {
                        // TODO: Navigate to topic detail
                        print('Navigate to topic detail');
                      },
                    ),
                    const SizedBox(height: spaceMd),
                    TopicCard(
                      title: 'Tên Chủ Đề',
                      imageAsset:
                          kBackgroundJpg, // Tạm thời dùng ảnh background
                      onTap: () {
                        // TODO: Navigate to topic detail
                        print('Navigate to topic detail');
                      },
                    ),
                    const SizedBox(height: spaceMd),
                    TopicCard(
                      title: 'Tên Chủ Đề',
                      imageAsset: kBackgroundJpg, // Tạm thời dùng ảnh eagle
                      onTap: () {
                        // TODO: Navigate to topic detail
                        print('Navigate to topic detail');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
