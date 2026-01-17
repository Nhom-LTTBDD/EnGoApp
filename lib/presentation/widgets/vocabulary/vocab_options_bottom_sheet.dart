// lib/presentation/widgets/vocabulary/vocab_options_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';

class VocabOptionsBottomSheet extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VocabOptionsBottomSheet({super.key, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Edit option
          ListTile(
            leading: const Icon(Icons.edit, color: kTextPrimary, size: 24),
            title: const Text(
              'Sửa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: kTextPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
          ),

          // Delete option
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red, size: 24),
            title: const Text(
              'Xóa bộ từ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + spaceMd),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          VocabOptionsBottomSheet(onEdit: onEdit, onDelete: onDelete),
    );
  }
}
