// lib/presentation/widgets/avatar_color_picker_dialog.dart
// Dialog chọn màu avatar với 16 màu preset

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AvatarColorPickerDialog extends StatelessWidget {
  final String? currentColor;
  final Function(String) onColorSelected;

  const AvatarColorPickerDialog({
    super.key,
    this.currentColor,
    required this.onColorSelected,
  });

  // 16 màu preset đẹp
  static const List<AvatarColorOption> _colors = [
    AvatarColorOption('blue', Color(0xFF2196F3), 'Xanh dương'),
    AvatarColorOption('green', Color(0xFF4CAF50), 'Xanh lá'),
    AvatarColorOption('orange', Color(0xFFFF9800), 'Cam'),
    AvatarColorOption('purple', Color(0xFF9C27B0), 'Tím'),
    AvatarColorOption('pink', Color(0xFFE91E63), 'Hồng'),
    AvatarColorOption('cyan', Color(0xFF00BCD4), 'Xanh ngọc'),
    AvatarColorOption('red', Color(0xFFF44336), 'Đỏ'),
    AvatarColorOption('indigo', Color(0xFF3F51B5), 'Chàm'),
    AvatarColorOption('teal', Color(0xFF009688), 'Xanh lục'),
    AvatarColorOption('amber', Color(0xFFFFC107), 'Hổ phách'),
    AvatarColorOption('deepPurple', Color(0xFF673AB7), 'Tím đậm'),
    AvatarColorOption('lime', Color(0xFFCDDC39), 'Chanh'),
    AvatarColorOption('brown', Color(0xFF795548), 'Nâu'),
    AvatarColorOption('blueGrey', Color(0xFF607D8B), 'Xám xanh'),
    AvatarColorOption('deepOrange', Color(0xFFFF5722), 'Cam đậm'),
    AvatarColorOption('lightGreen', Color(0xFF8BC34A), 'Xanh nhạt'),
  ];

  static Color getColorFromName(String colorName) {
    final option = _colors.firstWhere(
      (c) => c.name == colorName,
      orElse: () => _colors[0],
    );
    return option.color;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn màu avatar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final colorOption = _colors[index];
                final isSelected = currentColor == colorOption.name;

                return GestureDetector(
                  onTap: () {
                    onColorSelected(colorOption.name);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorOption.color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 4)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: colorOption.color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: isSelected ? 3 : 0,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarColorOption {
  final String name;
  final Color color;
  final String displayName;

  const AvatarColorOption(this.name, this.color, this.displayName);
}
