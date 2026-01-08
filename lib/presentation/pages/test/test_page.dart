import 'package:en_go_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/constants/app_text_styles.dart';
import 'package:en_go_app/core/constants/app_colors.dart';
import 'package:en_go_app/presentation/widgets/app_header.dart';

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Test TOEIC - IELTS",
      currentIndex: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ExamTypes(
              text: "IELTS",
              color: Color(0xFFFF6B6B),
              desc: "British Council Test",
              onTap: () => Navigator.pushNamed(context, AppRoutes.ielts),
            ),
            ExamTypes(
              text: "TOEIC",
              color: Colors.blueAccent,
              desc: "EST Toeic",
              onTap: () => Navigator.pushNamed(context, AppRoutes.toeic),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamTypes extends StatelessWidget {
  const ExamTypes({
    super.key,
    required this.text,
    required this.color,
    required this.desc,
    required this.onTap,
  });
  final String text;
  final Color color;
  final String desc;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 39,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(desc, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
