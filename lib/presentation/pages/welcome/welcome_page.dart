// lib/presentation/pages/welcome/welcome_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late List<Animation<double>> _cardAnimations;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Content animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Staggered card animations
    _cardAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentController,
          curve: Interval(
            0.2 + (index * 0.15),
            0.5 + (index * 0.15),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Button animation
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
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

    // Start animations
    _logoController.forward().then((_) {
      _contentController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images to avoid jank
    precacheImage(const AssetImage(kBackgroundJpg), context);
  }

  @override
  void dispose() {
    _logoController.dispose();
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(kBackgroundJpg),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            ),
          ),
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
                        // Animated Logo
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: ScaleTransition(
                                scale: _logoScaleAnimation,
                                child: RepaintBoundary(
                                  child: Hero(
                                    tag: 'app_logo',
                                    child: SvgPicture.asset(
                                      kIconBirdWelcome,
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Title with fade
                        FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: const Column(
                            children: [
                              Text('Welcome to EnGo App!', style: kH1),
                              SizedBox(height: 10),
                              Text('Unlock your English power', style: kH1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Feature Cards with staggered animation
                        _buildFeatureCard(
                          animation: _cardAnimations[0],

                          text: 'Chinh phục IELTS/TOEIC dễ dàng',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          animation: _cardAnimations[1],

                          text: 'Flashcard và quiz giúp ghi nhớ nhanh',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          animation: _cardAnimations[2],

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
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: kBodyEmphasized, textAlign: TextAlign.center),
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
