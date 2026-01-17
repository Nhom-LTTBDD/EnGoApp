import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';

class IeltsPage extends StatelessWidget {
  const IeltsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "IELTS Tests",
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        color: getBackgroundColor(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: getSurfaceColor(context),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: getDividerColor(context).withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: getTextPrimary(context)),
                      decoration: InputDecoration(
                        hintText: 'search....',
                        hintStyle: TextStyle(color: getTextThird(context)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Test list
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: getCardBackground(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: getDividerColor(context).withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      'Test ${index + 1}',
                      style: TextStyle(color: getTextPrimary(context)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
