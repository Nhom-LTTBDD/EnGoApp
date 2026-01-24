// lib/presentation/pages/welcome/welcome_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_header.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentController;
  late List<Animation<double>> _cardSlideAnimations;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  bool _isImageCached = false;
  bool _hasPreCached = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache chỉ 1 lần
    if (!_hasPreCached) {
      _hasPreCached = true;
      _precacheAssets();
    }
  }

  Future<void> _precacheAssets() async {
    // Precache background image - context đã available
    await precacheImage(const AssetImage(kBackgroundJpg), context);
    if (mounted) {
      setState(() {
        _isImageCached = true;
      });
      // Start animation sau khi image cached
      if (!_contentController.isAnimating) {
        _contentController.forward();
      }
    }
  }

  void _initAnimations() {
    // Content animation - giảm duration để giảm load
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Card slide animations - giảm số lượng animation frame
    _cardSlideAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentController,
          curve: Interval(
            index * 0.2,
            0.5 + (index * 0.15),
            curve: Curves
                .easeOut, // Thay Curves.easeOutCubic bằng easeOut để mượt hơn
          ),
        ),
      ),
    );

    // Button animation
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation CHỈ sau khi image cached (được trigger trong _precacheAssets)
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const AppHeader(title: 'EnGo App', elevation: 0.0),
      body: RepaintBoundary(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _isImageCached
              ? const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(kBackgroundJpg),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                )
              : const BoxDecoration(color: Color(0xFFE3F2FD)),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      screenHeight -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Logo - hiển thị ngay không animation
                        RepaintBoundary(
                          child: Hero(
                            tag: 'app_logo',
                            child: SvgPicture.asset(
                              kIconBirdWelcome,
                              width: 120,
                              height: 120,
                              placeholderBuilder: (context) => const SizedBox(
                                width: 120,
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title - hiển thị ngay
                        const Column(
                          children: [
                            Text('Welcome to EnGo App!', style: kH1),
                            SizedBox(height: 10),
                            Text('Unlock your English power', style: kH1),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Feature Cards with staggered progress animation
                        _buildFeatureCard(
                          animation: _cardSlideAnimations[0],
                          text: 'Chinh phục IELTS/TOEIC dễ dàng',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          animation: _cardSlideAnimations[1],
                          text: 'Flashcard và quiz giúp ghi nhớ nhanh',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          animation: _cardSlideAnimations[2],
                          text: 'Tổng hợp ngữ pháp đầy đủ và dễ hiểu',
                        ),
                        const SizedBox(height: 40),
                        // Animated Button
                        SlideTransition(
                          position: _buttonSlideAnimation,
                          child: FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: _buildGetStartedButton(context),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required Animation<double> animation,
    required String text,
  }) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value.clamp(0.0, 1.0);
          if (progress == 0.0) {
            return const SizedBox(width: 300, height: 44);
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: child,
            ),
          );
        },
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: kBodyEmphasized,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: AppButton(
        text: 'Get Started',
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.login);
        },
        variant: AppButtonVariant.accent,
        size: AppButtonSize.xLarge,
      ),
    );
  }
}
