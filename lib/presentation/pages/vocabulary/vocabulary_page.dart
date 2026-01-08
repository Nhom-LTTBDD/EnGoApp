// lib/presentation/pages/vocabulary/vocabulary_page.dart
// Vocabulary page với thiết kế tối ưu và OOP pattern

import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import '../../widgets/vocabulary_menu_item.dart';
import '../../widgets/optimized_vocabulary_list.dart';
import 'vocabulary_menu_manager.dart';

class VocabPage extends StatefulWidget {
  const VocabPage({super.key});

  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage> with AutomaticKeepAliveClientMixin {
  late final VocabularyMenuManager _menuManager;
  late final List<VocabularyMenuData> _menuItems;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeMenuManager();
  }

  void _initializeMenuManager() {
    _menuManager = VocabularyMenuManager();
    _menuItems = _menuManager.getMenuItems();
  }

  Future<void> _handleMenuTap(VocabularyMenuType menuType) async {
    try {
      await _menuManager.executeMenuAction(context, menuType);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Có lỗi xảy ra: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: 1, // Vocabulary tab index
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: kBackgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: OptimizedVocabularyList(
                  menuItems: _menuItems,
                  onMenuTap: _handleMenuTap,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: spaceMd,
                    bottom: spaceLg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(spaceMd),
      padding: const EdgeInsets.all(spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kSecondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(spaceSm),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.book_outlined,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Học từ vựng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: spaceSm),
                Text(
                  'Chọn phương pháp học phù hợp với bạn',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kTextThird,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
