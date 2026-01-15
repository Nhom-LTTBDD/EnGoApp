// lib/presentation/widgets/vocabulary/vocab_page_header.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VocabPageHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const VocabPageHeader({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          padding: const EdgeInsets.only(right: 25),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: kIconBackColor,
            size: 30,
          ),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
        ),
      ],
    );
  }
}
