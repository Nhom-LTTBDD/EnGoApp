// lib/presentation/widgets/vocabulary_menu_item.dart
// Widget item menu vocabulary với thiết kế tối ưu và OOP

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/animation_utils.dart';
import '../../core/theme/theme_helper.dart';

/// Enum định nghĩa các loại menu item vocabulary
enum VocabularyMenuType {
  topics('Các chủ đề từ vựng', Icons.topic_outlined),
  personalCollection('Bộ từ của bạn', Icons.bookmark_outline),
  flashCard('Flash Card', Icons.flip_to_front_outlined),
  quiz('Quiz', Icons.quiz_outlined);

  const VocabularyMenuType(this.title, this.icon);

  final String title;
  final IconData icon;
}

/// Configuration class cho vocabulary menu item styling
class VocabularyMenuItemConfig {
  final Color? backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  const VocabularyMenuItemConfig({
    this.backgroundColor,
    this.borderColor = kPrimaryColor,
    this.textColor = kTextPrimary,
    this.iconColor = kPrimaryColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(
      vertical: spaceLg,
      horizontal: spaceMd,
    ),
    this.elevation = 2.0,
  });

  /// Factory constructors cho các style khác nhau
  factory VocabularyMenuItemConfig.primary() => const VocabularyMenuItemConfig(
    borderColor: kPrimaryColor,
    iconColor: kPrimaryColor,
  );

  factory VocabularyMenuItemConfig.success() => const VocabularyMenuItemConfig(
    borderColor: kSuccessColor,
    iconColor: kSuccessColor,
  );

  factory VocabularyMenuItemConfig.warning() => const VocabularyMenuItemConfig(
    borderColor: kWarningColor,
    iconColor: kWarningColor,
  );

  factory VocabularyMenuItemConfig.special() => const VocabularyMenuItemConfig(
    borderColor: kAccentColor,
    iconColor: kAccentColor,
  );
}

/// Widget vocabulary menu item chính
class VocabularyMenuItem extends StatefulWidget {
  final VocabularyMenuType menuType;
  final VocabularyMenuItemConfig? config;
  final VoidCallback? onTap;
  final bool isEnabled;
  final Widget? trailing;

  const VocabularyMenuItem({
    super.key,
    required this.menuType,
    this.config,
    this.onTap,
    this.isEnabled = true,
    this.trailing,
  });

  @override
  State<VocabularyMenuItem> createState() => _VocabularyMenuItemState();
}

class _VocabularyMenuItemState extends State<VocabularyMenuItem>
    with TickerProviderStateMixin, AnimationMixin {
  bool _isPressed = false;

  VocabularyMenuItemConfig get _effectiveConfig {
    return widget.config ?? VocabularyMenuItemConfig.primary();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
    playAnimation();
  }

  void _handleTapUp(TapUpDetails details) {
    _resetTapState();
  }

  void _handleTapCancel() {
    _resetTapState();
  }

  void _resetTapState() {
    setState(() => _isPressed = false);
    reverseAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isEnabled ? widget.onTap : null,
            child: AnimatedContainer(
              duration: AnimationUtils.normalDuration,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceSm,
              ),
              padding: _effectiveConfig.padding,
              decoration: BoxDecoration(
                color: _isPressed
                    ? (_effectiveConfig.backgroundColor ??
                              getSurfaceColor(context))
                          .withValues(alpha: 0.9)
                    : (_effectiveConfig.backgroundColor ??
                          getSurfaceColor(context)),
                borderRadius: BorderRadius.circular(
                  _effectiveConfig.borderRadius,
                ),
                border: Border.all(
                  color: widget.isEnabled
                      ? _effectiveConfig.borderColor
                      : getDividerColor(context),
                  width: 2,
                ),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: _effectiveConfig.borderColor.withValues(
                            alpha: 0.1,
                          ),
                          blurRadius: _effectiveConfig.elevation * 2,
                          offset: Offset(0, _effectiveConfig.elevation),
                        ),
                      ]
                    : null,
              ),
              child: _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(spaceSm),
          decoration: BoxDecoration(
            color: widget.isEnabled
                ? _effectiveConfig.iconColor.withValues(alpha: 0.1)
                : getTextThird(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.menuType.icon,
            color: widget.isEnabled
                ? _effectiveConfig.iconColor
                : getTextThird(context),
            size: 24,
          ),
        ),
        const SizedBox(width: spaceMd),
        Expanded(
          child: Text(
            widget.menuType.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: widget.isEnabled
                  ? _effectiveConfig.textColor
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: spaceSm),
          widget.trailing!,
        ] else if (widget.isEnabled) ...[
          Icon(
            Icons.arrow_forward_ios,
            color: _effectiveConfig.iconColor,
            size: 16,
          ),
        ],
      ],
    );
  }
}

/// Extension để tạo configuration dễ dàng hơn
extension VocabularyMenuTypeExtension on VocabularyMenuType {
  VocabularyMenuItemConfig getDefaultConfig() {
    switch (this) {
      case VocabularyMenuType.topics:
        return VocabularyMenuItemConfig.success();
      case VocabularyMenuType.personalCollection:
        return VocabularyMenuItemConfig.warning();
      case VocabularyMenuType.flashCard:
      case VocabularyMenuType.quiz:
        return VocabularyMenuItemConfig.special();
    }
  }
}
