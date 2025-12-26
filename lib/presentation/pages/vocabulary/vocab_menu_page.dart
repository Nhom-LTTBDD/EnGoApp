// lib/presentation/pages/vocabulary/vocab_menu_page.dart
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/core/constants/app_spacing.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import '../../widgets/vocab_menu_item.dart';
import 'dart:math' as math;

class VocabMenuPage extends StatefulWidget {
  const VocabMenuPage({super.key});

  @override
  State<VocabMenuPage> createState() => _VocabMenuPageState();
}

class _VocabMenuPageState extends State<VocabMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late PageController _pageController;
  bool _isFlipped = false;
  int _currentPage = 0;

  // Danh sách từ vựng mẫu
  final List<Map<String, String>> _vocabularyCards = [
    {
      'vietnamese': 'Từ vựng',
      'english': 'Vocabulary',
      'meaning': 'Từ vựng, bộ từ vựng',
    },
    {'vietnamese': 'Học tập', 'english': 'Study', 'meaning': 'Học, nghiên cứu'},
    {
      'vietnamese': 'Kiến thức',
      'english': 'Knowledge',
      'meaning': 'Hiểu biết, kiến thức',
    },
    {
      'vietnamese': 'Giáo dục',
      'english': 'Education',
      'meaning': 'Sự giáo dục, học vấn',
    },
    {
      'vietnamese': 'Trường học',
      'english': 'School',
      'meaning': 'Nhà trường, trường học',
    },
    {
      'vietnamese': 'Giáo viên',
      'english': 'Teacher',
      'meaning': 'Người dạy học',
    },
    {
      'vietnamese': 'Học sinh',
      'english': 'Student',
      'meaning': 'Người đang học tập',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85, // Để thấy một phần card bên cạnh
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 10),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    if (_isFlipped) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: kBackgroundColor),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: spaceMd),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsets.only(right: 25),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: kIconBackColor,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        padding: EdgeInsets.only(left: 25),
                        icon: const Icon(
                          Icons.more_vert,
                          color: kIconBackColor,
                          size: 30,
                        ),
                        onPressed: () {
                          print('Navigate more');
                        },
                      ),
                    ],
                  ),

                  // Card "Từ vựng" với dots - có thể lật và lướt ngang
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          _isFlipped =
                              false; // Reset flip state khi chuyển card
                          _animationController.reset();
                        });
                      },
                      itemCount: _vocabularyCards.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: _flipCard,
                            child: AnimatedBuilder(
                              animation: _flipAnimation,
                              builder: (context, child) {
                                final isShowingFront =
                                    _flipAnimation.value < 0.5;
                                final currentCard = _vocabularyCards[index];

                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(_flipAnimation.value * math.pi),
                                  child: Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: kSurfaceColor,
                                      borderRadius: kRadiusMedium,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Content area - Front or Back
                                        Center(
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..rotateX(
                                                isShowingFront ? 0 : math.pi,
                                              ),
                                            child: isShowingFront
                                                ? Text(
                                                    currentCard['vietnamese']!,
                                                    style: kFlashcardText,
                                                    textAlign: TextAlign.center,
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        currentCard['english']!,
                                                        style: kFlashcardText,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        currentCard['meaning']!,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        // Expand button (bottom right) - chỉ hiện ở mặt trước
                                        if (isShowingFront)
                                          Positioned(
                                            bottom: 4,
                                            right: 0,
                                            child: TextButton(
                                              onPressed: () => {
                                                print(
                                                  'Expand vocabulary card ${index + 1}',
                                                ),
                                              },
                                              child: SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: const Icon(
                                                  Icons.fullscreen,
                                                  size: 30,
                                                  color: kFullscreenButtonColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dots indicator cho PageView - giới hạn 4 dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _vocabularyCards.length > 4 ? 4 : _vocabularyCards.length,
                      (index) {
                        // Tính toán dot nào sẽ active dựa trên current page
                        bool isActive = false;

                        if (_vocabularyCards.length <= 4) {
                          // Nếu có <= 4 cards, hiển thị bình thường
                          isActive = _currentPage == index;
                        } else {
                          // Nếu có > 4 cards, tính toán dot active
                          if (_currentPage < 2) {
                            // Ở đầu: dots 0,1,2,3 tương ứng pages 0,1,2,3
                            isActive = _currentPage == index;
                          } else if (_currentPage >=
                              _vocabularyCards.length - 2) {
                            // Ở cuối: dots 0,1,2,3 tương ứng pages [n-3,n-2,n-1,n]
                            int startPage = _vocabularyCards.length - 4;
                            isActive = _currentPage == startPage + index;
                          } else {
                            // Ở giữa: dot thứ 1 (index 1) luôn active
                            isActive = index == 1;
                          }
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? kTextPrimary
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: spaceLg),

                  // "Tên Chủ Đề" title
                  const Text(
                    'Tên Chủ Đề',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),

                  const SizedBox(height: spaceMd),

                  // Profile section
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: kSecondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: spaceMd),
                      // Name and terms count
                      Text(
                        'Name',
                        style: TextStyle(fontSize: 14, color: kTextThird),
                      ),
                      const SizedBox(width: 45),
                      Text(
                        '30 thuật ngữ',
                        style: TextStyle(
                          fontSize: 14,
                          color: kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: spaceLg),

                  // Menu items
                  VocabMenuItem(
                    icon: Icons.library_books_outlined,
                    backgroundColor: kSurfaceColor,
                    title: 'Thẻ ghi nhớ',
                    iconColor: kIconFlashcardColor,
                    onTap: () {
                      print('Navigate to Flash Cards');
                    },
                  ),
                  VocabMenuItem(
                    icon: Icons.school_rounded,
                    backgroundColor: kSurfaceColor,
                    title: 'Học',
                    iconColor: kIconFlashcardColor,
                    onTap: () {
                      print('Navigate to Learn');
                    },
                  ),
                  VocabMenuItem(
                    icon: Icons.quiz,
                    backgroundColor: kSurfaceColor,
                    title: 'Kiểm tra',
                    iconColor: kIconFlashcardColor,
                    onTap: () {
                      print('Navigate to Test');
                    },
                  ),
                  VocabMenuItem(
                    icon: Icons.extension,
                    backgroundColor: kSurfaceColor,
                    title: 'Ghép thẻ',
                    iconColor: kIconFlashcardColor,
                    onTap: () {
                      print('Navigate to Match');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
