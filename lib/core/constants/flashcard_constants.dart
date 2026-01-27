// lib/core/constants/flashcard_constants.dart

/// Các hằng số sử dụng trong flashcard
class FlashcardConstants {
  // Animation durations
  static const int flipAnimationDuration = 600; // milliseconds
  static const int swipeAnimationDuration = 300; // milliseconds
  static const int transitionDelay = 100; // milliseconds

  // Swipe thresholds (tỷ lệ % so với screen width)
  static const double commitSwipeThreshold = 0.35; // 35% màn hình
  static const double safeZoneThreshold = 0.25; // 25% màn hình
  static const double halfScreenThreshold = 0.5; // 50% màn hình

  // Velocity threshold
  static const double velocityThreshold = 2000.0; // pixels per second

  // Drag thresholds
  static const double minDragDistance = 10.0; // pixels
  static const double minSwipeDistance = 20.0; // pixels
  static const double iconSwipeDistance = 30.0; // pixels

  // Card dimensions
  static const double cardHeight = 600.0;
  static const double cardBorderRadius = 16.0;

  // Swipe animation
  static const double rotationFactor = 0.0005;
  static const double opacityDivisor = 120.0;

  // Icon sizes
  static const double commitIconSize = 100.0;
  static const double normalIconSize = 80.0;

  FlashcardConstants._(); // Private constructor để prevent instantiation
}
