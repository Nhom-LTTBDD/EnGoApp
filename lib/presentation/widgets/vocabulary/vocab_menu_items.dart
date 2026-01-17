// lib/presentation/widgets/vocabulary/vocab_menu_items.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../vocab_menu_item.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/theme_helper.dart';

class VocabMenuItems extends StatelessWidget {
  final String? topicId;

  const VocabMenuItems({super.key, this.topicId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VocabMenuItem(
          icon: Icons.library_books_outlined,
          backgroundColor: getSurfaceColor(context),
          title: 'Thẻ ghi nhớ',
          iconColor: kIconFlashcardColor,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.flashcard,
              arguments: {'topicId': topicId ?? '1'},
            );
          },
        ),
        VocabMenuItem(
          icon: Icons.school_rounded,
          backgroundColor: getSurfaceColor(context),
          title: 'Học',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Learn');
          },
        ),
        VocabMenuItem(
          icon: Icons.quiz,
          backgroundColor: getSurfaceColor(context),
          title: 'Kiểm tra',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Test');
          },
        ),
        VocabMenuItem(
          icon: Icons.extension,
          backgroundColor: getSurfaceColor(context),
          title: 'Ghép thẻ',
          iconColor: kIconFlashcardColor,
          onTap: () {
            print('Navigate to Match');
          },
        ),
      ],
    );
  }
}
