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
            // List topics
            Expanded(
              child: Container(
                color: kBackgroundColor,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Subtitle section - sẽ scroll cùng list
                    Container(
                      width: double.infinity,
                      height: 80,
                      alignment: Alignment.center,
                      child: const Text(
                        'Bộ từ vựng',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    // Cards trong padding container
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spaceMd),
                      child: Column(
                        children: [
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
                            imageAsset:
                                kBackgroundJpg, // Tạm thời dùng ảnh eagle
                            onTap: () {
                              // TODO: Navigate to topic detail
                              print('Navigate to topic detail');
                            },
                          ),
                          const SizedBox(height: spaceMd),
                          TopicCard(
                            title: 'Tên Chủ Đề',
                            imageAsset:
                                kBackgroundJpg, // Tạm thời dùng ảnh swift
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
                            imageAsset:
                                kBackgroundJpg, // Tạm thời dùng ảnh eagle
                            onTap: () {
                              // TODO: Navigate to topic detail
                              print('Navigate to topic detail');
                            },
                          ),
                          const SizedBox(height: spaceMd), // Padding bottom
                        ],
                      ),
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
