// lib/presentation/widgets/vocabulary/vocab_page_header.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'vocab_options_bottom_sheet.dart';

class VocabPageHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabPageHeader({
    super.key,
    this.onBackPressed,
    this.onMorePressed,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        IconButton(
          padding: const EdgeInsets.only(left: 25),
          icon: const Icon(Icons.more_vert, color: kIconBackColor, size: 30),
          onPressed:
              onMorePressed ??
              () {
                VocabOptionsBottomSheet.show(
                  context,
                  onEdit: onEdit ?? () => print('Edit vocabulary set'),
                  onDelete: onDelete ?? () => print('Delete vocabulary set'),
                );
              },
        ),
      ],
    );
  }
}
