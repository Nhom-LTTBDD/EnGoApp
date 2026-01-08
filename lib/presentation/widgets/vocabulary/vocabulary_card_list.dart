// lib/presentation/widgets/vocabulary/vocabulary_card_list.dart
import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../providers/vocabulary_provider.dart';
import 'vocabulary_card_widget.dart';
import 'dart:math' as math;

class VocabularyCardList extends StatefulWidget {
  final PageController pageController;
  final List<VocabularyCard> vocabularyCards;
  final VocabularyProvider provider;
  final String? topicId; // Thêm topicId parameter

  const VocabularyCardList({
    super.key,
    required this.pageController,
    required this.vocabularyCards,
    required this.provider,
    this.topicId, // Thêm vào constructor
  });

  @override
  State<VocabularyCardList> createState() => _VocabularyCardListState();
}

class _VocabularyCardListState extends State<VocabularyCardList> {
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize current page value
    _currentPageValue = widget.pageController.initialPage.toDouble();

    widget.pageController.addListener(_pageListener);
  }

  void _pageListener() {
    if (mounted && widget.pageController.hasClients) {
      setState(() {
        _currentPageValue = widget.pageController.page ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: widget.pageController,
        onPageChanged: (index) {
          widget.provider.setCurrentCardIndex(index);
          // Animation sẽ được quản lý tự động bởi từng card
        },
        itemCount: widget.vocabularyCards.length,
        itemBuilder: (context, index) {
          return _buildCardWithScale(context, index);
        },
      ),
    );
  }

  Widget _buildCardWithScale(BuildContext context, int index) {
    // Tính toán scale factor dựa trên khoảng cách từ center
    double scaleFactor = 1.0;

    // Kiểm tra nếu PageController đã được khởi tạo
    if (widget.pageController.hasClients) {
      double difference = (_currentPageValue - index).abs();
      // Scale từ 1.0 (center) xuống 0.85 (sides) - tăng độ chênh lệch cho viewportFraction 0.85
      scaleFactor = math.max(0.9, 1.0 - (difference * 0.1));
    } else {
      // Khi chưa khởi tạo, card đầu tiên (index 0) sẽ có scale = 1.0, các card khác nhỏ hơn
      scaleFactor = index == 0 ? 1.0 : 0.9;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Transform.scale(
        scale: scaleFactor,
        child: VocabularyCardWidget(
          card: widget.vocabularyCards[index],
          index: index,
          onExpand: () {
            Navigator.pushNamed(
              context,
              AppRoutes.flashcard,
              arguments: {
                'topicId': widget.topicId ?? '1', // Truyền topicId xuống
              },
            );
          },
        ),
      ),
    );
  }
}
