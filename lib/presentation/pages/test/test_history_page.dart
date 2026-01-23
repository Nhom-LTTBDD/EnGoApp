// lib/presentation/pages/test/test_history_page.dart

import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../../../domain/entities/test_history.dart';
import '../../../data/services/firebase_firestore_service.dart';
import '../../../routes/app_routes.dart';

class TestHistoryPage extends StatefulWidget {
  final String userId;

  const TestHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  List<TestHistory> _histories = [];
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadTestHistory();
  }

  Future<void> _loadTestHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final histories = await FirebaseFirestoreService.getTestHistoryByUser(
        widget.userId,
      );
      final stats = await FirebaseFirestoreService.getUserStatistics(
        widget.userId,
      );

      setState(() {
        _histories = histories;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading test history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Lịch Sử Làm Bài',
      currentIndex: 1,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Chưa có lịch sử làm bài',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy thử làm bài TOEIC đầu tiên!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.toeic),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text(
              'Làm Bài TOEIC',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        _buildStatisticsCard(),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _histories.length,
            itemBuilder: (context, index) {
              final history = _histories[index];
              return _buildHistoryCard(history);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Thống Kê Tổng Quan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Số bài đã làm',
                    '${_statistics['totalTests'] ?? 0}',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Điểm cao nhất',
                    '${_statistics['bestScore'] ?? 0}',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Điểm trung bình',
                    '${(_statistics['averageScore'] ?? 0.0).round()}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Độ chính xác',
                    '${(_statistics['averageAccuracy'] ?? 0.0).round()}%',
                    Icons.mail,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(TestHistory history) {
    final completedDate = history.completedAt;
    final formattedDate =
        '${completedDate.day}/${completedDate.month}/${completedDate.year}';
    final formattedTime =
        '${completedDate.hour.toString().padLeft(2, '0')}:${completedDate.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showHistoryDetail(history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    history.testName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor(
                        history.totalScore,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${history.totalScore} điểm',
                      style: TextStyle(
                        color: _getScoreColor(history.totalScore),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text('$formattedDate - $formattedTime'),
                  const SizedBox(width: 20),
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 5),
                  Text('${history.correctAnswers}/${history.totalQuestions}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error, size: 16, color: Colors.red),
                  const SizedBox(width: 5),
                  Text('${history.incorrectQuestions.length} câu sai'),
                  const SizedBox(width: 20),
                  Icon(Icons.percent, size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text('${history.accuracyPercentage.round()}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 800) return Colors.green;
    if (score >= 600) return Colors.orange;
    if (score >= 400) return Colors.red;
    return Colors.grey;
  }

  void _showHistoryDetail(TestHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildHistoryDetailSheet(history),
    );
  }

  Widget _buildHistoryDetailSheet(TestHistory history) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi Tiết Kết Quả',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // Thông tin chung
          _buildDetailRow('Bài test', history.testName),
          _buildDetailRow(
            'Ngày làm',
            '${history.completedAt.day}/${history.completedAt.month}/${history.completedAt.year}',
          ),
          _buildDetailRow('Tổng điểm', '${history.totalScore}/990'),
          _buildDetailRow('Listening', '${history.listeningScore}/495'),
          _buildDetailRow('Reading', '${history.readingScore}/495'),
          _buildDetailRow(
            'Độ chính xác',
            '${history.accuracyPercentage.round()}%',
          ),

          const SizedBox(height: 20),
          const Text(
            '📊 Kết Quả Theo Parts:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final part = index + 1;
                final partData = history.partScores['part$part'];
                if (partData == null) return const SizedBox.shrink();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('$part'),
                  ),
                  title: Text('Part $part'),
                  subtitle: Text(
                    '${partData['correct']}/${partData['total']} câu đúng',
                  ),
                  trailing: Text(
                    '${partData['percentage'].round()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(
                        (partData['percentage'] as double).round(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
