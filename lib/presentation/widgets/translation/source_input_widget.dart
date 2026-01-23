// lib/presentation/widgets/translation/source_input_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/constants/app_spacing.dart';

class SourceInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSpeak;

  const SourceInputWidget({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(spaceMd),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: spaceSm),
                Text(
                  'Nhập văn bản',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                if (controller.text.isNotEmpty)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Text field
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Nhập hoặc dán văn bản cần dịch...',
              hintStyle: TextStyle(color: getTextThird(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(spaceMd),
            ),
            style: TextStyle(
              fontSize: 16,
              color: getTextPrimary(context),
              height: 1.5,
            ),
            onChanged: onChanged,
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: spaceMd,
              vertical: spaceSm,
            ),
            child: Row(
              children: [
                Text(
                  '${controller.text.length} ký tự',
                  style: TextStyle(fontSize: 12, color: getTextThird(context)),
                ),
                const Spacer(),
                if (controller.text.isNotEmpty && onSpeak != null)
                  IconButton(
                    onPressed: onSpeak,
                    icon: Icon(Icons.volume_up, size: 24),
                    color: Colors.blue.shade700,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
