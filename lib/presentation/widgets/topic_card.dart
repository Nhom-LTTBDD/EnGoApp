// lib/presentation/widgets/topic_card.dart
// Widget card hiển thị chủ đề từ vựng

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Card hiển thị chủ đề từ vựng với tiêu đề và nút navigate
class TopicCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? imageUrl; // URL ảnh từ Firebase
  final String? imageAsset; // Asset ảnh local

  const TopicCard({
    super.key,
    required this.title,
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
        height: 200, // Chiều cao cố định cho card
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
            ),
            // Phần title và nút arrow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: spaceMd,
                  vertical: spaceSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}
