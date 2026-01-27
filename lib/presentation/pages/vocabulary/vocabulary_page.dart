// lib/presentation/pages/vocabulary/vocabulary_page.dart
// Vocabulary page với thiết kế tối ưu và OOP pattern

import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import '../../widgets/vocabulary_menu_item.dart';
import '../../widgets/optimized_vocabulary_list.dart';
import 'vocabulary_menu_manager.dart';

/// Trang chính Vocabulary - Hiển thị menu các chức năng từ vựng
/// Chức năng: Cho phép người dùng chọn học theo topics, personal collection, hoặc làm quiz
class VocabPage extends StatefulWidget {
  const VocabPage({super.key});

  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage>
    with AutomaticKeepAliveClientMixin {
  late final VocabularyMenuManager _menuManager;
  late final List<VocabularyMenuData> _menuItems;

  /// Giữ state của page khi chuyển tab để tránh rebuild không cần thiết
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeMenuManager();
  }

  /// Khởi tạo menu manager và load danh sách menu items
  /// Menu items bao gồm: Topics, Personal Collection, Quiz
  void _initializeMenuManager() {
    _menuManager = VocabularyMenuManager();
    _menuItems = _menuManager.getMenuItems();
  }

  /// Xử lý khi người dùng tap vào một menu item
  /// Thực hiện navigation hoặc action tương ứng với loại menu được chọn
  Future<void> _handleMenuTap(VocabularyMenuType menuType) async {
    try {
      await _menuManager.executeMenuAction(context, menuType);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Có lỗi xảy ra: ${e.toString()}');
      }
    }
  }

  /// Hiển thị dialog thông báo lỗi khi có exception xảy ra
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
    );  }

  /// Build UI của vocabulary page
  /// Sử dụng OptimizedVocabularyList để hiển thị menu items với performance tối ưu
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: getBackgroundColor(context)),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: OptimizedVocabularyList(
                  menuItems: _menuItems,
                  onMenuTap: _handleMenuTap,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: spaceMd, bottom: spaceLg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
