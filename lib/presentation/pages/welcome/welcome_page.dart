// lib/presentation/pages/welcome/welcome_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.logoOnly(),
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
              Image.asset(kDovePng),
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
                  },
                  variant: AppButtonVariant.accent,
                  size: AppButtonSize.large,
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
