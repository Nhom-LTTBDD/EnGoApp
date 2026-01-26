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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // Start animation immediately - don't wait for assets
    _contentController.forward();
    // Precache in background without blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(const AssetImage(kBackgroundJpg), context);
      }
    });
  }

  void _initAnimations() {
    // Single simple fade animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
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
      body: Container(
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
              child: FadeTransition(
                opacity: _fadeAnimation,
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
                        // Logo
                        Hero(
                          tag: 'app_logo',
                          child: SvgPicture.asset(
                            kIconBirdWelcome,
                            width: 120,
                            height: 120,
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
                        // Feature Cards - static for performance
                        _buildFeatureCard('Chinh phục IELTS/TOEIC dễ dàng'),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          'Flashcard và quiz giúp ghi nhớ nhanh',
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          'Tổng hợp ngữ pháp đầy đủ và dễ hiểu',
                        ),
                        const SizedBox(height: 40),
                        // Button
                        _buildGetStartedButton(context),
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

  Widget _buildFeatureCard(String text) {
    return Container(
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
