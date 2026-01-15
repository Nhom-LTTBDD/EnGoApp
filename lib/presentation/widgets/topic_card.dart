// lib/presentation/widgets/topic_card.dart
// Widget card hiển thị chủ đề từ vựng

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

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
      onTap: onTap,      child: Container(
        width: double.infinity,
        height: 240, // Tăng chiều cao để chứa thêm thông tin
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: kRadiusMedium,
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            ),            // Phần title, subtitle, count và nút arrow
            Container(
              padding: const EdgeInsets.all(spaceMd),
              child: Row(
                children: [
                  // Emoji icon (nếu có)
                  if (emoji != null) ...[
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 32),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
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
                              color: kTextThird,
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
                      border: Border.all(color: kTextPrimary, width: 2),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: kTextPrimary,
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
