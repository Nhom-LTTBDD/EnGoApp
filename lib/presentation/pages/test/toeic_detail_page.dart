import 'package:flutter/material.dart';
import 'package:en_go_app/presentation/layout/main_layout.dart';
import 'package:en_go_app/routes/app_routes.dart';
import '../../../domain/entities/toeic_test.dart';
import 'package:en_go_app/core/theme/theme_helper.dart';
import 'package:en_go_app/core/theme/app_theme.dart';

class ToeicDetailPage extends StatefulWidget {
  final String testId;
  final String testName;
  final ToeicTest? test;
  final int? partNumber;

  const ToeicDetailPage({
    Key? key,
    required this.testId,
    required this.testName,
    this.test,
    this.partNumber,
  }) : super(key: key);

  @override
  State<ToeicDetailPage> createState() => _ToeicDetailPageState();
}

class _ToeicDetailPageState extends State<ToeicDetailPage> {
  bool isPracticeMode = true;
  Set<int> selectedParts = {};
  int selectedTime = 120;

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainLayout(
      title: "TOEIC",
      currentIndex: -1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? (themeExt?.backgroundGradientColors ??
                      [Colors.grey[900]!, Colors.grey[800]!])
                : [const Color(0xFF1E90FF), const Color(0xFFB2E0FF)],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      widget.testName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selection
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => isPracticeMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: isPracticeMode
                                      ? Theme.of(context).primaryColor
                                      : getTextThird(context).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Practice Each ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => isPracticeMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: !isPracticeMode
                                      ? Theme.of(context).primaryColor
                                      : getTextThird(context).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Full Test',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Listening Section (only show in practice mode)
                      if (isPracticeMode) ...[
                        Text(
                          'Listening',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildPartButton(1)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildPartButton(2)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildPartButton(3)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildPartButton(4)),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Reading Section
                        Text(
                          'Reading',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildPartButton(5)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildPartButton(6)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildPartButton(7),
                        const SizedBox(height: 15),

                        // Time Selection
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: getTextSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTimeButton(null, 'X'),
                            _buildTimeButton(55, "55'"),
                            _buildTimeButton(75, "75'"),
                            _buildTimeButton(120, "120'"),
                            _buildTimeButton(135, "135'"),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],

                      // Start Test Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate selection in practice mode
                            if (isPracticeMode && selectedParts.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select at least one part',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Navigate to test taking page
                            Navigator.pushNamed(
                              context,
                              AppRoutes.toeicTestTaking,
                              arguments: {
                                'testId': widget.testId,
                                'testName': widget.testName,
                                'isFullTest': !isPracticeMode,
                                'selectedParts': widget.partNumber != null
                                    ? [widget.partNumber!]
                                    : (isPracticeMode
                                          ? selectedParts.toList()
                                          : [
                                              1,
                                              2,
                                            ]), // Available parts from sample data
                                'timeLimit': selectedTime == 0
                                    ? null
                                    : selectedTime,
                                'test': widget.test, // Pass test object
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Start Test',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartButton(int partNumber) {
    final isSelected = selectedParts.contains(partNumber);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPracticeMode) {
            if (isSelected) {
              selectedParts.remove(partNumber);
            } else {
              selectedParts.add(partNumber);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: getDividerColor(context).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'PART $partNumber',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(int? minutes, String label) {
    final isSelected = selectedTime == minutes;
    return GestureDetector(
      onTap: () => setState(() => selectedTime = minutes ?? 0),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: getDividerColor(context).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : getTextSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
