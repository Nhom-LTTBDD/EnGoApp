// lib/presentation/pages/vocabulary/personal_vocabulary_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../domain/entities/vocabulary_card.dart';
import '../../providers/personal_vocabulary_provider.dart';

/// Trang hiển thị bộ từ vựng cá nhân của người dùng
class PersonalVocabularyPage extends StatefulWidget {
  const PersonalVocabularyPage({super.key});

  @override
  State<PersonalVocabularyPage> createState() => _PersonalVocabularyPageState();
}

class _PersonalVocabularyPageState extends State<PersonalVocabularyPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedCardIds = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalVocabularyProvider>(
      builder: (context, provider, child) {
        return MainLayout(
          title: 'BỘ TỪ CỦA BẠN',
          currentIndex: -1,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: kBackgroundColor),
            child: Column(
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: spaceMd,
                    vertical: spaceLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Từ đã đánh dấu',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: spaceSm),
                          Text(
                            '${provider.cardCount} từ vựng',
                            style: TextStyle(
                              fontSize: 16,
                              color: kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      // More button (3 dots) for bulk actions
                      if (provider.hasCards)
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showOptionsMenu(context, provider),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(PersonalVocabularyProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: spaceMd),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 16,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: spaceSm),
            ElevatedButton(
              onPressed: () => provider.loadPersonalVocabulary(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (!provider.hasCards) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: kTextThird,
            ),
            const SizedBox(height: spaceLg),
            Text(
              'Chưa có từ nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: spaceLg * 2),
              child: Text(
                'Nhấn vào dấu ⭐ trên vocabulary card để thêm từ vào bộ từ của bạn',
                style: TextStyle(
                  fontSize: 16,
                  color: kTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: spaceLg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.vocabByTopic);
              },
              icon: const Icon(Icons.topic),
              label: const Text('Khám phá từ vựng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: spaceLg,
                  vertical: spaceMd,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Cards list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceSm,
      ),
      itemCount: provider.personalCards.length,
      itemBuilder: (context, index) {
        final card = provider.personalCards[index];
        return _buildCardItem(card, provider);
      },
    );
  }

  Widget _buildCardItem(VocabularyCard card, PersonalVocabularyProvider provider) {
    final isSelected = _selectedCardIds.contains(card.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: spaceMd),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            setState(() {
              if (isSelected) {
                _selectedCardIds.remove(card.id);
              } else {
                _selectedCardIds.add(card.id);
              }
            });
          } else {
            // Navigate to vocab menu with this specific card
            // For now, just show the card details
            _showCardDetails(card, provider);
          }
        },
        onLongPress: () {
          setState(() {
            _isSelectionMode = true;
            _selectedCardIds.add(card.id);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(spaceMd),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Selection checkbox
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: spaceMd),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? kPrimaryColor : Colors.grey,
                  ),
                ),
              
              // Card content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.english,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.vietnamese,
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                    ),
                    if (card.phonetic != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.phonetic!,
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextThird,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Star icon (bookmarked)
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardDetails(VocabularyCard card, PersonalVocabularyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.english),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.vietnamese,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(card.meaning),
            if (card.phonetic != null) ...[
              const SizedBox(height: 8),
              Text(
                card.phonetic!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.removeCard(card.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa khỏi bộ từ của bạn'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, PersonalVocabularyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.select_all),
              title: const Text('Chọn nhiều'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAllConfirmation(provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Tải lại'),
              onTap: () {
                Navigator.pop(context);
                provider.loadPersonalVocabulary();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation(PersonalVocabularyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả?'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả từ vựng đã lưu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.clearAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tất cả từ vựng'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
