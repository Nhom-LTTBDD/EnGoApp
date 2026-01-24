// lib/presentation/pages/vocabulary/quiz_settings_page.dart
import 'package:en_go_app/presentation/widgets/quiz/quiz_language_selector.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../domain/entities/quiz_config.dart';
import '../../../domain/entities/question_type.dart';
import '../../../domain/entities/quiz_language_mode.dart';
import '../../../data/repositories/vocabulary_repository_impl.dart';
import '../../widgets/vocabulary/quiz_language_selector_sheet.dart';
import '../../layout/main_layout.dart';
import '../../widgets/quiz/quiz_build_info.dart';

/// Page thiết lập quiz trước khi làm bài
/// Cho phép người dùng cấu hình:
/// - Ngôn ngữ trả lời
/// - Số câu hỏi (mặc định = tổng số từ)
class QuizSettingsPage extends StatefulWidget {
  final String topicId;
  final String topicName;

  const QuizSettingsPage({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<QuizSettingsPage> createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  // Default settings
  late QuizLanguageMode _questionLanguage;
  late QuizLanguageMode _answerLanguage;
  final _repository = VocabularyRepositoryImpl();
  bool _isLoadingCards = false;
  int _cardCount = 0;

  @override
  void initState() {
    super.initState();
    // Mặc định: hỏi tiếng Anh, trả lời tiếng Việt
    _questionLanguage = QuizLanguageMode.englishToVietnamese;
    _answerLanguage = QuizLanguageMode.englishToVietnamese;

    _loadCardCount();
  }

  Future<void> _loadCardCount() async {
    setState(() {
      _isLoadingCards = true;
    });

    try {
      debugPrint('[SETTINGS] Loading cards for topic: ${widget.topicId}');
      // Load cards directly from repository using topicId
      final cards = await _repository.getVocabularyCards(widget.topicId);

      if (mounted) {
        setState(() {
          _cardCount = cards.length;
          _isLoadingCards = false;
        });
        debugPrint('[SETTINGS] Loaded $_cardCount cards');
      }
    } catch (e) {
      debugPrint('[SETTINGS] Error loading cards: $e');
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
    if (_cardCount == 0) {
      debugPrint('[SETTINGS] Cannot start quiz: _cardCount = 0');
      return;
    }

    debugPrint(
      '[SETTINGS] Starting quiz - Topic: ${widget.topicName}, Cards: $_cardCount',
    );

    final config = QuizConfig(
      topicId: widget.topicId,
      topicName: widget.topicName,
      totalCards: _cardCount,
      questionCount: _cardCount,
      questionType: QuestionType.multipleChoice,
      questionLanguage: _questionLanguage,
      answerLanguage: _answerLanguage,
    );

    Navigator.pushNamed(context, AppRoutes.quiz, arguments: {'config': config});
  }

  @override
  void dispose() {
    super.dispose();
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
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
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
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: getTextPrimary(context),
                                  ),
                                  // Pop back to quiz by topic page (don't push new page)
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Text(
                                  'Thiết lập bài kiểm tra',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: getTextPrimary(context),
                                  ),
                                ),
                                const SizedBox(width: 48), // Placeholder
                              ],
                            ),

                            const SizedBox(height: spaceLg),

                            // Số câu hỏi (read-only)
                            BuildInfoRow(
                              label: 'Số câu hỏi',
                              value: '$_cardCount',
                            ),

                            const SizedBox(height: spaceMd),

                            // Trả lời bằng (clickable)
                            QuizLanguageSelector(
                              questionLanguage: _questionLanguage,
                              answerLanguage: _answerLanguage,
                              onSelectQuestionLanguage: () =>
                                  _showLanguageSelector(
                                    isQuestionLanguage: false,
                                  ),
                            ),

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
                          onPressed: (_isLoadingCards || _cardCount == 0)
                              ? null
                              : _startQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            disabledBackgroundColor: getDisabledColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoadingCards)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.edit_square,
                                  color: Colors.white,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoadingCards
                                    ? 'Đang tải...'
                                    : 'Bắt đầu làm kiểm tra',
                                style: const TextStyle(
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
}
