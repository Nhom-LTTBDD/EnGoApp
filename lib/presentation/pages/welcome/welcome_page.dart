// lib/presentation/pages/welcome/welcome_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'EnGo App', elevation: 0.0),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(kBackgroundJpg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(kSwiftWelcomePng, width: 200, height: 200),
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
    );
  }
}
