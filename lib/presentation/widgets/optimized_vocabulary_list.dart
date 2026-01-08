// lib/presentation/widgets/optimized_vocabulary_list.dart  
// Optimized list widget cho vocabulary menu để tránh unnecessary rebuilds

import 'package:flutter/material.dart';
import 'vocabulary_menu_item.dart';
import '../pages/vocabulary/vocabulary_menu_manager.dart';

/// Optimized list widget sử dụng ListView.separated để performance tốt hơn
class OptimizedVocabularyList extends StatelessWidget {
  final List<VocabularyMenuData> menuItems;
  final Function(VocabularyMenuType) onMenuTap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const OptimizedVocabularyList({
    super.key,
    required this.menuItems,
    required this.onMenuTap,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding,
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final menuData = menuItems[index];
        
        return _OptimizedVocabularyMenuItem(
          key: ValueKey('vocab_menu_${menuData.type.name}'),
          menuData: menuData,
          onTap: () => onMenuTap(menuData.type),
        );
      },
    );
  }
}

/// Private optimized menu item widget với caching
class _OptimizedVocabularyMenuItem extends StatelessWidget {
  final VocabularyMenuData menuData;
  final VoidCallback onTap;

  const _OptimizedVocabularyMenuItem({
    super.key,
    required this.menuData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: VocabularyMenuItem(
        menuType: menuData.type,
        config: menuData.config,
        isEnabled: menuData.isEnabled,
        trailing: menuData.badge,
        onTap: onTap,
      ),
    );
  }
}

/// Builder widget cho custom layouts
class VocabularyMenuBuilder extends StatelessWidget {
  final List<VocabularyMenuData> menuItems;
  final Function(VocabularyMenuType) onMenuTap;
  final Widget Function(BuildContext context, List<Widget> menuWidgets) builder;

  const VocabularyMenuBuilder({
    super.key,
    required this.menuItems,
    required this.onMenuTap,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final menuWidgets = menuItems.map((menuData) {
      return _OptimizedVocabularyMenuItem(
        key: ValueKey('vocab_menu_${menuData.type.name}'),
        menuData: menuData,
        onTap: () => onMenuTap(menuData.type),
      );
    }).toList();

    return builder(context, menuWidgets);
  }
}
