// lib/presentation/pages/vocabulary/vocabulary_menu_manager.dart
// Manager class để quản lý navigation và actions cho vocabulary menu

import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/vocabulary_menu_item.dart';

/// Abstract base class cho vocabulary menu actions
abstract class VocabularyMenuAction {
  Future<void> execute(BuildContext context);
  bool get isEnabled => true;
  String get analyticsEvent;
}

/// Implementation các actions cụ thể
class TopicsMenuAction extends VocabularyMenuAction {
  @override
  Future<void> execute(BuildContext context) async {
    // Analytics tracking
    // AnalyticsService.trackEvent(analyticsEvent);
    
    // Navigate to vocab by topic page (topic selection)
    Navigator.pushNamed(context, AppRoutes.vocabByTopic);
  }

  @override
  String get analyticsEvent => 'vocabulary_topics_opened';
}

class PersonalCollectionMenuAction extends VocabularyMenuAction {
  @override
  Future<void> execute(BuildContext context) async {
    // Navigate to personal vocabulary page
    Navigator.pushNamed(context, AppRoutes.personalVocabulary);
  }

  @override
  String get analyticsEvent => 'personal_collection_opened';
}

class FlashCardMenuAction extends VocabularyMenuAction {
  @override
  Future<void> execute(BuildContext context) async {
    // Navigator.pushNamed(context, AppRoutes.flashCard);
    _showComingSoonDialog(context, 'Flash Card');
  }

  @override
  String get analyticsEvent => 'flashcard_opened';
}

class QuizMenuAction extends VocabularyMenuAction {
  @override
  Future<void> execute(BuildContext context) async {
    // Navigator.pushNamed(context, AppRoutes.quiz);
    _showComingSoonDialog(context, 'Quiz');
  }
  @override
  String get analyticsEvent => 'quiz_opened';
}

/// Helper function for coming soon dialog
void _showComingSoonDialog(BuildContext context, String feature) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$feature'),
      content: const Text('Tính năng này sẽ sớm được cập nhật!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}

/// Factory class để tạo actions
class VocabularyMenuActionFactory {
  static final Map<VocabularyMenuType, VocabularyMenuAction> _actions = {
    VocabularyMenuType.topics: TopicsMenuAction(),
    VocabularyMenuType.personalCollection: PersonalCollectionMenuAction(),
    VocabularyMenuType.flashCard: FlashCardMenuAction(),
    VocabularyMenuType.quiz: QuizMenuAction(),
  };

  static VocabularyMenuAction? getAction(VocabularyMenuType type) {
    return _actions[type];
  }

  static List<VocabularyMenuType> get availableMenuTypes {
    return _actions.keys.toList();
  }
}

/// Data class cho vocabulary menu configuration
class VocabularyMenuData {
  final VocabularyMenuType type;
  final VocabularyMenuItemConfig config;
  final VocabularyMenuAction action;
  final bool isEnabled;
  final Widget? badge;

  VocabularyMenuData({
    required this.type,
    required this.config,
    required this.action,
    this.isEnabled = true,
    this.badge,
  });

  factory VocabularyMenuData.create(VocabularyMenuType type) {
    final action = VocabularyMenuActionFactory.getAction(type);
    if (action == null) {
      throw Exception('No action found for menu type: $type');
    }

    return VocabularyMenuData(
      type: type,
      config: type.getDefaultConfig(),
      action: action,
      isEnabled: action.isEnabled,
    );
  }
}

/// Manager class chính
class VocabularyMenuManager {
  static final VocabularyMenuManager _instance = VocabularyMenuManager._internal();
  factory VocabularyMenuManager() => _instance;
  VocabularyMenuManager._internal();

  /// Get all menu items data
  List<VocabularyMenuData> getMenuItems() {
    return VocabularyMenuActionFactory.availableMenuTypes
        .map((type) => VocabularyMenuData.create(type))
        .toList();
  }

  /// Execute action for specific menu type
  Future<void> executeMenuAction(
    BuildContext context, 
    VocabularyMenuType type,
  ) async {
    final action = VocabularyMenuActionFactory.getAction(type);
    if (action != null && action.isEnabled) {
      await action.execute(context);
    }
  }

  /// Check if menu item is enabled
  bool isMenuEnabled(VocabularyMenuType type) {
    final action = VocabularyMenuActionFactory.getAction(type);
    return action?.isEnabled ?? false;
  }
}
