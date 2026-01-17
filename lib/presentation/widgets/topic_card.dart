// lib/presentation/widgets/topic_card.dart
// Widget card hiển thị chủ đề từ vựng

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/theme_helper.dart';

/// Card hiển thị chủ đề từ vựng với tiêu đề và nút navigate
class TopicCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? cardCount;
  final String? emoji;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? imageUrl; // URL ảnh từ Firebase
  final String? imageAsset; // Asset ảnh local

  const TopicCard({
    super.key,
    required this.title,
    this.subtitle,
    this.cardCount,
    this.emoji,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.imageUrl,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240, // Tăng chiều cao để chứa thêm thông tin
        decoration: BoxDecoration(
          color: backgroundColor ?? getSurfaceColor(context),
          borderRadius: kRadiusMedium,
          border: Border.all(
            color: borderColor ?? getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: getTextPrimary(context).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khoảng trống cho ảnh (150px)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: imageAsset != null
                    ? Image.asset(imageAsset!, fit: BoxFit.cover)
                    : imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 48),
                      ),
              ),
            ), // Phần title, subtitle, count và nút arrow
            Container(
              padding: const EdgeInsets.all(spaceMd),
              child: Row(
                children: [
                  // Emoji icon (nếu có)
                  if (emoji != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(emoji!, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: spaceSm),
                  ],
                  // Title và subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: getTextPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: getTextThird(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (cardCount != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$cardCount từ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: spaceSm),
                  // Arrow button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: getTextPrimary(context),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: getTextPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
