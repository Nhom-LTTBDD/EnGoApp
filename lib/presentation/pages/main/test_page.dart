import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Test TOEIC - IELTS",
      currentIndex: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("TOEIC & IELTS Tests", style: kH1),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
