// lib/presentation/pages/vocabulary/flashcard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/vocabulary/flashcard_widget.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_helper.dart';

class FlashcardPage extends StatefulWidget {
  final String? topicId;

  const FlashcardPage({super.key, this.topicId});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  int _currentCardIndex = 0;
  int _correctCount = 0; // Số thẻ đúng (màu xanh)
  int _wrongCount = 0; // Số thẻ sai (màu đỏ)
  bool _isFlipped = false; // Trạng thái lật thẻ

  // Cho hiệu ứng quẹt
  double _dragOffset = 0.0;
  double _dragOffsetY = 0.0; // Thêm offset Y cho quẹt chéo
  bool _isDragging = false;
  bool _isCommittedToSwipe = false; // Đã cam kết quẹt, không thể quay lại

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Giảm về 600ms cho mượt hơn
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack, // Curve có bounce nhẹ để cảm giác thật hơn
      ),
    );

    // Load vocabulary cards when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyProvider>().loadVocabularyCards(
        widget.topicId ?? '1',
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showResultDialog() {
    final total = _correctCount + _wrongCount;
    final percentage = total > 0 ? (_correctCount * 100 / total).round() : 0;

    // 🔥 Record activity to update streak
    context.read<StreakProvider>().recordActivity();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kết quả học tập'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bạn đã hoàn thành bộ thẻ!',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_correctCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                      Text(
                        'Đúng',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_wrongCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                      Text('Sai', style: TextStyle(color: Colors.red.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tỷ lệ đúng: $percentage%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay về trang trước
              },
              child: const Text('Quay lại'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                // Reset và học lại
                setState(() {
                  _currentCardIndex = 0;
                  _correctCount = 0;
                  _wrongCount = 0;
                  _isFlipped = false; // Reset trạng thái lật thẻ
                  _dragOffset = 0.0; // Reset vị trí thẻ
                  _dragOffsetY = 0.0; // Reset vị trí Y
                  _isDragging = false;
                  _isCommittedToSwipe = false;
                });
                final provider = context.read<VocabularyProvider>();
                provider.setCurrentCardIndex(0);
                provider.resetCardFlip();
                _animationController.reset();
              },
              style: TextButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: getSurfaceColor(context),
              ),
              child: const Text('Học lại'),
            ),
          ],
        );
      },
    );
  }

  // Animate khi quẹt phải với hiệu ứng
  void _animateAndSwipeRight() {
    // Animation thẻ hiện tại bay ra ngoài bên phải
    setState(() {
      _dragOffset = 800; // Bay xa hơn để đảm bảo ra khỏi màn hình
      _isCommittedToSwipe = true;
    });

    // Ngay lập tức cập nhật state để hiển thị thẻ tiếp theo
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _correctCount++;
          _currentCardIndex++;
          // Reset hoàn toàn - thẻ tiếp theo đã sẵn có sẽ tự động hiển thị
          _dragOffset = 0.0;
          _dragOffsetY = 0.0;
          _isFlipped = false; // Thẻ mới bắt đầu với mặt trước
          _isDragging = false;
          _isCommittedToSwipe = false;
        });

        // Cập nhật provider
        final provider = context.read<VocabularyProvider>();
        provider.setCurrentCardIndex(_currentCardIndex);
        _animationController.reset();
        provider.resetCardFlip();

        // Kiểm tra nếu hết thẻ
        if (_currentCardIndex >=
            context.read<VocabularyProvider>().vocabularyCards.length) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _showResultDialog();
          });
        }
      }
    });
  }

  // Animate khi quẹt trái với hiệu ứng
  void _animateAndSwipeLeft() {
    // Animation thẻ hiện tại bay ra ngoài bên trái
    setState(() {
      _dragOffset = -800; // Bay xa hơn để đảm bảo ra khỏi màn hình
      _isCommittedToSwipe = true;
    });

    // Ngay lập tức cập nhật state để hiển thị thẻ tiếp theo
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _wrongCount++;
          _currentCardIndex++;
          // Reset hoàn toàn - thẻ tiếp theo đã sẵn có sẽ tự động hiển thị
          _dragOffset = 0.0;
          _dragOffsetY = 0.0;
          _isFlipped = false; // Thẻ mới bắt đầu với mặt trước
          _isDragging = false;
          _isCommittedToSwipe = false;
        });

        // Cập nhật provider
        final provider = context.read<VocabularyProvider>();
        provider.setCurrentCardIndex(_currentCardIndex);
        _animationController.reset();
        provider.resetCardFlip();

        // Kiểm tra nếu hết thẻ
        if (_currentCardIndex >=
            context.read<VocabularyProvider>().vocabularyCards.length) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _showResultDialog();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, vocabularyProvider, child) {
        if (vocabularyProvider.isLoading) {
          return Scaffold(
            backgroundColor: getBackgroundColor(context),
            body: const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (vocabularyProvider.error != null) {
          return Scaffold(
            backgroundColor: getBackgroundColor(context),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: kFlashcardText.copyWith(
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vocabularyProvider.error!,
                      style: TextStyle(color: getTextSecondary(context)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vocabularyProvider.loadVocabularyCards(
                        widget.topicId ?? '1',
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final vocabularyCards = vocabularyProvider.vocabularyCards;
        if (vocabularyCards.isEmpty) {
          return Scaffold(
            backgroundColor: getBackgroundColor(context),
            body: SafeArea(
              child: Center(
                child: Text(
                  'Không có từ vựng nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: getTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }

        // Kiểm tra nếu đã hết thẻ
        if (_currentCardIndex >= vocabularyCards.length) {
          return Scaffold(
            backgroundColor: getBackgroundColor(context),
            body: SafeArea(
              child: Center(
                child: Text(
                  'Đã hoàn thành tất cả thẻ!',
                  style: TextStyle(
                    fontSize: 18,
                    color: getTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: getBackgroundColor(context),
          body: SafeArea(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: getBackgroundColor(context)),
              padding: const EdgeInsets.all(spaceMd),
              child: Column(
                children: [
                  // Header với nút X, điểm số và progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút X để đóng
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: getTextPrimary(context),
                          size: 28,
                        ),
                      ), // Progress hiển thị ở giữa
                      Text(
                        '${_currentCardIndex + 1} / ${vocabularyCards.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: getTextPrimary(context),
                        ),
                      ),

                      // Placeholder để cân bằng layout
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: spaceSm),

                  // Điểm số màu đỏ và xanh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Điểm sai (màu đỏ) - bên trái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          '$_wrongCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),

                      // Điểm đúng (màu xanh) - bên phải
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          '$_correctCount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: spaceLg),

                  // Flashcard với gesture detector để quẹt
                  Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          // Thẻtrắng placeholder ở phía sau - luôn hiển thị để tạo depth
                          Container(
                            width: double.infinity,
                            height: 600,
                            decoration: BoxDecoration(
                              color: getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: getBorderColor(context),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: getTextPrimary(
                                    context,
                                  ).withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          // Tạo tất cả thẻ flashcard từ mảng vocabularyCards
                          // Mỗi thẻ được tạo sẵn nhưng chỉ thẻ hiện tại mới hiển thị
                          ...vocabularyCards.asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            final isCurrentCard = index == _currentCardIndex;

                            return IgnorePointer(
                              ignoring:
                                  !isCurrentCard, // Chỉ thẻ hiện tại mới nhận gesture
                              child: Opacity(
                                opacity: isCurrentCard
                                    ? 1.0
                                    : 0.0, // Chỉ thẻ hiện tại mới hiển thị
                                child: AnimatedContainer(
                                  duration: isCurrentCard && _isDragging
                                      ? Duration.zero
                                      : const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  transform: isCurrentCard
                                      ? (Matrix4.identity()
                                          ..translate(_dragOffset, _dragOffsetY)
                                          ..rotateZ(_dragOffset * 0.0005))
                                      : Matrix4.identity(), // Thẻ ẩn không có transform
                                  child: Container(
                                    width: double.infinity,
                                    height: 600,
                                    decoration: BoxDecoration(
                                      color: getSurfaceColor(context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: getBorderColor(context),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: getTextPrimary(
                                            context,
                                          ).withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Nội dung thẻ - chỉ có gesture cho thẻ hiện tại
                                        if (isCurrentCard)
                                          Opacity(
                                            opacity:
                                                (_isDragging &&
                                                    (_dragOffset.abs() > 20 ||
                                                        _dragOffsetY.abs() >
                                                            20))
                                                ? (1.0 -
                                                          (((_dragOffset.abs() +
                                                                  _dragOffsetY
                                                                      .abs()) /
                                                              120.0)))
                                                      .clamp(0.0, 1.0)
                                                : 1.0,
                                            child: GestureDetector(
                                              onTap: _isCommittedToSwipe
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _isFlipped =
                                                            !_isFlipped;
                                                      });
                                                      if (_isFlipped) {
                                                        _animationController
                                                            .forward();
                                                      } else {
                                                        _animationController
                                                            .reverse();
                                                      }
                                                    },
                                              onPanStart: (details) {
                                                if (!_isCommittedToSwipe) {
                                                  setState(() {
                                                    _isDragging = false;
                                                  });
                                                }
                                              },
                                              onPanUpdate: (details) {
                                                if (!_isCommittedToSwipe) {
                                                  setState(() {
                                                    _dragOffset +=
                                                        details.delta.dx;
                                                    _dragOffsetY +=
                                                        details.delta.dy;

                                                    final totalDistance =
                                                        (_dragOffset.abs() +
                                                        _dragOffsetY.abs());
                                                    if (totalDistance > 10) {
                                                      _isDragging = true;
                                                    }

                                                    final screenWidth =
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width;
                                                    final commitThreshold =
                                                        screenWidth * 0.35;
                                                    final horizontalDistance =
                                                        _dragOffset.abs();

                                                    if (horizontalDistance >
                                                        commitThreshold) {
                                                      _isCommittedToSwipe =
                                                          true;
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    _dragOffset +=
                                                        details.delta.dx;
                                                    _dragOffsetY +=
                                                        details.delta.dy;

                                                    final screenWidth =
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width;
                                                    final safeZoneThreshold =
                                                        screenWidth * 0.25;
                                                    final horizontalDistance =
                                                        _dragOffset.abs();

                                                    if (horizontalDistance <
                                                        safeZoneThreshold) {
                                                      _isCommittedToSwipe =
                                                          false;
                                                    }
                                                  });
                                                }
                                              },
                                              onPanEnd: (details) {
                                                if (_isCommittedToSwipe) {
                                                  if (_dragOffset > 0) {
                                                    _animateAndSwipeRight();
                                                  } else {
                                                    _animateAndSwipeLeft();
                                                  }
                                                } else {
                                                  final screenWidth =
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width;
                                                  final halfScreenWidth =
                                                      screenWidth * 0.5;

                                                  final velocity = details
                                                      .velocity
                                                      .pixelsPerSecond;
                                                  final totalVelocity =
                                                      (velocity.dx.abs() +
                                                      velocity.dy.abs());
                                                  final horizontalDistance =
                                                      _dragOffset.abs();

                                                  if (horizontalDistance >
                                                          halfScreenWidth ||
                                                      totalVelocity > 2000) {
                                                    setState(() {
                                                      _isCommittedToSwipe =
                                                          true;
                                                    });

                                                    if (_dragOffset > 0) {
                                                      _animateAndSwipeRight();
                                                    } else {
                                                      _animateAndSwipeLeft();
                                                    }
                                                  } else {
                                                    setState(() {
                                                      _dragOffset = 0.0;
                                                      _dragOffsetY = 0.0;
                                                      _isDragging = false;
                                                    });
                                                  }
                                                }
                                              },
                                              child: FlashcardWidget(
                                                card: card,
                                                flipAnimation: _flipAnimation,
                                                isFlipped: _isFlipped,
                                              ),
                                            ),
                                          )
                                        else
                                          // Thẻ ẩn không có gesture, chỉ có nội dung
                                          FlashcardWidget(
                                            card: card,
                                            flipAnimation: _flipAnimation,
                                            isFlipped:
                                                false, // Thẻ ẩn luôn ở mặt trước
                                          ),

                                        // Indicator màu khi quẹt - chỉ cho thẻ hiện tại
                                        if (isCurrentCard &&
                                            _isDragging &&
                                            (_dragOffset.abs() > 20 ||
                                                _dragOffsetY.abs() > 20))
                                          Container(
                                            decoration: BoxDecoration(
                                              color: _dragOffset > 0
                                                  ? (_isCommittedToSwipe
                                                        ? Colors.green
                                                              .withOpacity(0.4)
                                                        : Colors.green
                                                              .withOpacity(0.2))
                                                  : (_isCommittedToSwipe
                                                        ? Colors.red
                                                              .withOpacity(0.4)
                                                        : Colors.red
                                                              .withOpacity(
                                                                0.2,
                                                              )),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),

                                        // Icon quẹt trái/phải - chỉ cho thẻ hiện tại khi cam kết
                                        if (isCurrentCard &&
                                            _isDragging &&
                                            _isCommittedToSwipe &&
                                            (_dragOffset.abs() > 30 ||
                                                _dragOffsetY.abs() > 30))
                                          Center(
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              opacity: _isCommittedToSwipe
                                                  ? 1.0
                                                  : 0.0,
                                              child: Icon(
                                                _dragOffset > 0
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: _isCommittedToSwipe
                                                    ? 100
                                                    : 80,
                                                color: _dragOffset > 0
                                                    ? Colors.green.shade600
                                                    : Colors.red.shade600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: spaceLg),

                  // Nút điều hướng và reset ở dưới
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút reset (quay lại)
                      IconButton(
                        onPressed: () {
                          // Reset về đầu
                          setState(() {
                            _currentCardIndex = 0;
                            _correctCount = 0;
                            _wrongCount = 0;
                            _isFlipped = false; // Reset trạng thái lật thẻ
                            _dragOffset = 0.0; // Reset vị trí thẻ
                            _dragOffsetY = 0.0; // Reset vị trí Y
                            _isDragging = false;
                            _isCommittedToSwipe = false;
                          });
                          final provider = context.read<VocabularyProvider>();
                          provider.setCurrentCardIndex(0);
                          provider.resetCardFlip();
                          _animationController.reset();
                        },
                        icon: const Icon(
                          Icons.replay,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),

                      // Nút play/pause
                      IconButton(
                        onPressed: () {
                          // TODO: Auto play cards
                          print('Auto play flashcards');
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 32,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: spaceMd),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
