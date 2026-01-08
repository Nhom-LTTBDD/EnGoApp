// lib/presentation/widgets/vocabulary/dots_indicator.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DotsIndicator extends StatelessWidget {
  final int totalDots;
  final int activeDotIndex;
  final int maxDotsToShow;

  const DotsIndicator({
    super.key,
    required this.totalDots,
    required this.activeDotIndex,
    this.maxDotsToShow = 4,
  });

  @override
  Widget build(BuildContext context) {
    final dotsToShow = totalDots > maxDotsToShow ? maxDotsToShow : totalDots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsToShow, (index) {
        final isActive = activeDotIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? kTextPrimary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
