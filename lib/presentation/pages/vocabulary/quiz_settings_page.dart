// lib/presentation/pages/vocabulary/quiz_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../domain/entities/quiz_config.dart';
import '../../../domain/entities/question_type.dart';
import '../../../domain/entities/quiz_language_mode.dart';
import '../../widgets/vocabulary/quiz_language_selector_sheet.dart';
import '../../layout/main_layout.dart';
import '../../providers/vocabulary_provider.dart';

/// Page thiết lập quiz trước khi làm bài
/// Cho phép người dùng cấu hình:
/// - Loại câu hỏi (Multiple Choice / True-False)
/// - Ngôn ngữ câu hỏi và trả lời
/// - Số câu hỏi (mặc định = tổng số từ)
class QuizSettingsPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int? cardCount; // Make optional, will load from provider if null

  const QuizSettingsPage({
    super.key,
    required this.topicId,
    required this.topicName,
    this.cardCount, // Optional now
  });

  @override
  State<QuizSettingsPage> createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  // Default settings
  late QuestionType _selectedQuestionType;
  late QuizLanguageMode _questionLanguage;
  late QuizLanguageMode _answerLanguage;
  bool _isLoadingCards = false;
  int _cardCount = 0;

  @override
  void initState() {
    super.initState();
    // Mặc định: Nhiều lựa chọn, hỏi tiếng Anh, trả lời tiếng Việt
    _selectedQuestionType = QuestionType.multipleChoice;
    _questionLanguage = QuizLanguageMode.englishToVietnamese;
    _answerLanguage = QuizLanguageMode.vietnameseToEnglish;

    // Load cards to get card count if not provided
    if (widget.cardCount == null) {
      _loadCardCount();
    } else {
      _cardCount = widget.cardCount!;
    }
  }

  Future<void> _loadCardCount() async {
    setState(() {
      _isLoadingCards = true;
    });

    try {
      final provider = context.read<VocabularyProvider>();
      await provider.loadVocabularyCards(widget.topicId);

      if (mounted) {
        setState(() {
          _cardCount = provider.vocabularyCards.length;
          _isLoadingCards = false;
        });
        debugPrint('📊 Loaded card count: $_cardCount');
      }
    } catch (e) {
      debugPrint('❌ Error loading card count: $e');
      if (mounted) {
        setState(() {
          _isLoadingCards = false;
        });
      }
    }
  }

  void _showLanguageSelector({required bool isQuestionLanguage}) {
    QuizLanguageSelectorSheet.show(
      context: context,
      currentMode: isQuestionLanguage ? _questionLanguage : _answerLanguage,
    ).then((selectedMode) {
      if (selectedMode != null) {
        setState(() {
          if (isQuestionLanguage) {
            _questionLanguage = selectedMode;
          } else {
            _answerLanguage = selectedMode;
          }
        });
      }
    });
  }

  void _startQuiz() {
    debugPrint('Starting quiz with settings:');
    debugPrint('  Topic: ${widget.topicName} (${widget.topicId})');
    debugPrint('  Card count: $_cardCount');
    debugPrint('  Question type: $_selectedQuestionType');
    debugPrint('  Question language: $_questionLanguage');
    debugPrint('  Answer language: $_answerLanguage');

    final config = QuizConfig(
      topicId: widget.topicId,
      topicName: widget.topicName,
      totalCards: _cardCount, // Use loaded card count
      questionCount: _cardCount, // Số câu hỏi = tổng số từ
      questionType: _selectedQuestionType,
      questionLanguage: _questionLanguage,
      answerLanguage: _answerLanguage,
    );

    debugPrint('QuizConfig created: $config');

    Navigator.pushNamed(context, AppRoutes.quiz, arguments: {'config': config});
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'VOCABULARY',
      currentIndex: -1, // -1 để không highlight bottom nav
      showBottomNav: false, // Ẩn bottom navigation
      child: Container(
        decoration: BoxDecoration(color: getBackgroundColor(context)),
        child: SafeArea(
          child: _isLoadingCards
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải từ vựng...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Thiết lập bài kiểm tra',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: getTextPrimary(context),
                                  ),
                                ),
                                Icon(
                                  Icons.checklist_sharp,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ],
                            ),

                            const SizedBox(height: spaceLg),

                            // Số câu hỏi (read-only)
                            _buildInfoRow(
                              label: 'Số câu hỏi',
                              displayValue: '${widget.cardCount}',
                            ),

                            const SizedBox(height: spaceMd),

                            // Trả lời bằng (clickable)
                            _buildLanguageSelector(),

                            const SizedBox(height: spaceMd),

                            const Divider(),

                            const SizedBox(height: spaceMd),

                            // Question Type Toggle
                            _buildQuestionTypeToggle(),

                            const SizedBox(height: spaceMd),
                          ],
                        ),
                      ),
                    ),

                    // Start Button
                    Container(
                      padding: const EdgeInsets.all(spaceMd),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit_square, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Bắt đầu làm kiểm tra',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String displayValue}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: getTextPrimary(context)),
            ),
          ],
        ),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return InkWell(
      onTap: () => _showLanguageSelector(isQuestionLanguage: false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: spaceSm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trả lời bằng',
                  style: TextStyle(
                    fontSize: 16,
                    color: getTextPrimary(context),
                  ),
                ),
                Text(
                  _getLanguageModeText(_answerLanguage),
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: getTextThird(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Đúng / Sai
        _buildToggleOption(
          label: 'Đúng / Sai',
          isSelected: _selectedQuestionType == QuestionType.trueFalse,
          onChanged: (value) {
            if (value) {
              setState(() {
                _selectedQuestionType = QuestionType.trueFalse;
              });
            }
          },
        ),

        const SizedBox(height: spaceSm),

        // Nhiều lựa chọn
        _buildToggleOption(
          label: 'Nhiều lựa chọn',
          isSelected: _selectedQuestionType == QuestionType.multipleChoice,
          onChanged: (value) {
            if (value) {
              setState(() {
                _selectedQuestionType = QuestionType.multipleChoice;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: getTextPrimary(context)),
        ),
        Switch(
          value: isSelected,
          onChanged: onChanged,
          activeThumbColor: Colors.blue,
        ),
      ],
    );
  }

  String _getLanguageModeText(QuizLanguageMode mode) {
    return mode.displayText;
  }
}
