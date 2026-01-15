// lib/presentation/pages/welcome/welcome_page.dart
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

class _WelcomePageState extends State<WelcomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images to avoid jank
    precacheImage(AssetImage(kBackgroundJpg), context);
    precacheImage(AssetImage(kIconBirdWelcome), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppHeader(title: 'EnGo App', elevation: 0.0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    SvgPicture.asset(kIconBirdWelcome, width: 150, height: 150),
                    SizedBox(height: 20),
                    Text('Welcome to EnGo App!', style: kH1),
                    SizedBox(height: 10),
                    Text('Unlock your English power', style: kH1),
                    SizedBox(height: 15),
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Chinh phục IELTS/TOEIC dễ dàng',
                        style: kBodyEmphasized,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Flashcard và quiz giúp ghi nhớ nhanh',
                        style: kBodyEmphasized,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tổng hợp ngữ pháp đầy đủ và dễ hiểu',
                        style: kBodyEmphasized,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: AppButton(
                        text: 'Get Started',
                        onPressed: () {
                          // Xử lý khi nhấn nút Get Started
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        variant: AppButtonVariant.accent,
                        size: AppButtonSize.xLarge,
                        isFullWidth: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
