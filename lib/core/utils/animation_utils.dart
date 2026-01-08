// lib/core/utils/animation_utils.dart
// Utility class cho animations và performance optimizations

import 'dart:async';
import 'package:flutter/material.dart';

/// Animation utilities để tái sử dụng animations
class AnimationUtils {
  AnimationUtils._();

  /// Standard durations
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// Standard curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve fadeInCurve = Curves.easeIn;

  /// Tạo scale animation controller
  static AnimationController createScaleController(TickerProvider vsync) {
    return AnimationController(
      duration: fastDuration,
      vsync: vsync,
    );
  }

  /// Tạo scale animation
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 1.0,
    double end = 0.95,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  /// Tạo fade animation
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: fadeInCurve),
    );
  }

  /// Tạo slide animation
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  /// Pre-built page route transitions
  static Route<T> createSlideRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static Route<T> createFadeRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Mixin để easily add common animations cho widgets
mixin AnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationUtils.createScaleController(this);
    _scaleAnimation = AnimationUtils.createScaleAnimation(_animationController);
  }

  void playAnimation() => _animationController.forward();
  void reverseAnimation() => _animationController.reverse();
  void resetAnimation() => _animationController.reset();

  Animation<double> get scaleAnimation => _scaleAnimation;
  AnimationController get animationController => _animationController;
}

/// Performance utilities
class PerformanceUtils {
  PerformanceUtils._();

  /// Tạo RepaintBoundary cho widgets expensive
  static Widget wrapWithRepaintBoundary(Widget child, {Key? key}) {
    return RepaintBoundary(key: key, child: child);
  }

  /// Tạo AutomaticKeepAlive cho widgets cần persist
  static Widget wrapWithKeepAlive(Widget child, {Key? key}) {
    return _KeepAliveWrapper(key: key, child: child);
  }

  /// Debounce function để tránh excessive calls
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return ([args]) {
      timer?.cancel();
      timer = Timer(delay, () => func(args));
    };
  }

  /// Throttle function để limit frequency
  static Function throttle(Function func, Duration duration) {
    bool isThrottling = false;
    return ([args]) {
      if (!isThrottling) {
        isThrottling = true;
        func(args);
        Timer(duration, () => isThrottling = false);
      }
    };
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({super.key, required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Memory optimization utilities
class MemoryUtils {
  MemoryUtils._();

  /// Lazy initialization pattern
  static T lazy<T>(T Function() factory) {
    T? _instance;
    return _instance ??= factory();
  }
  /// Singleton pattern helper
  static final Map<Type, dynamic> _instances = {};
  
  static T singleton<T>(T Function() factory) {
    return _instances[T] ??= factory();
  }

  /// Clear cached data
  static void clearCache() {
    // Implement cache clearing logic
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Monitor memory usage (debug only)
  static void logMemoryUsage(String tag) {
    assert(() {
      debugPrint('[$tag] Memory usage: ${_getMemoryUsage()}MB');
      return true;
    }());
  }

  static String _getMemoryUsage() {
    // Simplified memory monitoring
    return 'N/A';
  }
}
