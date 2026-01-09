// lib/presentation/providers/grammar_provider.dart
// Grammar provider cho state management

import 'package:flutter/material.dart';
import '../../domain/entities/grammar_lesson.dart';
import '../../domain/entities/grammar_topic.dart';
import '../../domain/use_cases/get_grammar_topics_use_case.dart';
import '../../domain/use_cases/get_grammar_lessons_use_case.dart';
import '../../domain/repository_interfaces/grammar_repository.dart';

/// Grammar provider cho state management
class GrammarProvider extends ChangeNotifier {
  final GetGrammarTopicsUseCase _getGrammarTopicsUseCase;
  final GetGrammarLessonsUseCase _getGrammarLessonsUseCase;
  final GrammarRepository _grammarRepository;

  GrammarProvider({
    required GetGrammarTopicsUseCase getGrammarTopicsUseCase,
    required GetGrammarLessonsUseCase getGrammarLessonsUseCase,
    required GrammarRepository grammarRepository,
  })  : _getGrammarTopicsUseCase = getGrammarTopicsUseCase,
        _getGrammarLessonsUseCase = getGrammarLessonsUseCase,
        _grammarRepository = grammarRepository;

  // Topics state
  List<GrammarTopic> _topics = [];
  bool _isLoadingTopics = false;
  String? _topicsError;

  // Lessons state
  List<GrammarLesson> _lessons = [];
  bool _isLoadingLessons = false;
  String? _lessonsError;
  String? _currentTopicId;

  // Current lesson state
  GrammarLesson? _currentLesson;
  int _currentLessonIndex = 0;

  // Getters
  List<GrammarTopic> get topics => _topics;
  bool get isLoadingTopics => _isLoadingTopics;
  String? get topicsError => _topicsError;

  List<GrammarLesson> get lessons => _lessons;
  bool get isLoadingLessons => _isLoadingLessons;
  String? get lessonsError => _lessonsError;
  String? get currentTopicId => _currentTopicId;

  GrammarLesson? get currentLesson => _currentLesson;
  int get currentLessonIndex => _currentLessonIndex;

  // Computed properties
  bool get hasTopics => _topics.isNotEmpty;
  bool get hasLessons => _lessons.isNotEmpty;
  bool get hasError => _topicsError != null || _lessonsError != null;

  /// Get current topic info
  GrammarTopic? get currentTopic {
    if (_currentTopicId == null) return null;
    try {
      return _topics.firstWhere((topic) => topic.id == _currentTopicId);
    } catch (e) {
      return null;
    }
  }

  /// Load grammar topics
  Future<void> loadGrammarTopics() async {
    _isLoadingTopics = true;
    _topicsError = null;
    notifyListeners();

    try {
      _topics = await _getGrammarTopicsUseCase();
      _topicsError = null;
    } catch (e) {
      _topicsError = e.toString();
      _topics = [];
    } finally {
      _isLoadingTopics = false;
      notifyListeners();
    }
  }

  /// Load lessons by topic ID
  Future<void> loadLessonsByTopic(String topicId) async {
    _currentTopicId = topicId;
    _isLoadingLessons = true;
    _lessonsError = null;
    _currentLessonIndex = 0;
    notifyListeners();

    try {
      _lessons = await _getGrammarLessonsUseCase(topicId);
      _lessonsError = null;
      
      // Set first available lesson as current
      if (_lessons.isNotEmpty) {
        final availableLesson = _lessons.firstWhere(
          (lesson) => lesson.isAvailable,
          orElse: () => _lessons.first,
        );
        _currentLesson = availableLesson;
        _currentLessonIndex = _lessons.indexOf(availableLesson);
      }
    } catch (e) {
      _lessonsError = e.toString();
      _lessons = [];
      _currentLesson = null;
    } finally {
      _isLoadingLessons = false;
      notifyListeners();
    }
  }

  /// Set current lesson
  void setCurrentLesson(GrammarLesson lesson) {
    _currentLesson = lesson;
    _currentLessonIndex = _lessons.indexOf(lesson);
    notifyListeners();
  }

  /// Set current lesson by index
  void setCurrentLessonIndex(int index) {
    if (index >= 0 && index < _lessons.length) {
      _currentLessonIndex = index;
      _currentLesson = _lessons[index];
      notifyListeners();
    }
  }

  /// Go to next lesson
  void nextLesson() {
    if (_currentLessonIndex < _lessons.length - 1) {
      setCurrentLessonIndex(_currentLessonIndex + 1);
    }
  }

  /// Go to previous lesson
  void previousLesson() {
    if (_currentLessonIndex > 0) {
      setCurrentLessonIndex(_currentLessonIndex - 1);
    }
  }

  /// Check if can go to next lesson
  bool get canGoNext => _currentLessonIndex < _lessons.length - 1;

  /// Check if can go to previous lesson
  bool get canGoPrevious => _currentLessonIndex > 0;

  /// Refresh topics
  Future<void> refreshTopics() async {
    await loadGrammarTopics();
  }

  /// Refresh current lessons
  Future<void> refreshLessons() async {
    if (_currentTopicId != null) {
      await loadLessonsByTopic(_currentTopicId!);
    }
  }

  /// Clear error messages
  void clearErrors() {
    _topicsError = null;
    _lessonsError = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _topics = [];
    _lessons = [];
    _currentLesson = null;
    _currentLessonIndex = 0;
    _currentTopicId = null;
    _isLoadingTopics = false;
    _isLoadingLessons = false;
    _topicsError = null;
    _lessonsError = null;
    notifyListeners();
  }

  /// Get topics by level
  List<GrammarTopic> getTopicsByLevel(GrammarLevel level) {
    return _topics.where((topic) => topic.level == level).toList();
  }

  /// Get available topics
  List<GrammarTopic> get availableTopics {
    return _topics.where((topic) => topic.isUnlocked).toList();
  }

  /// Get completed topics
  List<GrammarTopic> get completedTopics {
    return _topics.where((topic) => topic.isCompleted).toList();
  }

  /// Get available lessons
  List<GrammarLesson> get availableLessons {
    return _lessons.where((lesson) => lesson.isAvailable).toList();
  }
  /// Get completed lessons
  List<GrammarLesson> get completedLessons {
    return _lessons.where((lesson) => lesson.isCompleted).toList();
  }

  /// Get lesson by ID
  GrammarLesson? getLessonById(String lessonId) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }
  /// Load lesson detail by ID
  Future<GrammarLesson?> loadLessonDetail(String lessonId) async {
    try {
      _isLoadingLessons = true;
      _lessonsError = null;
      notifyListeners();
      
      final lesson = await _grammarRepository.getLessonById(lessonId);
      
      if (lesson != null) {
        // Update lesson in current list if exists
        final index = _lessons.indexWhere((l) => l.id == lessonId);
        if (index != -1) {
          _lessons[index] = lesson;
        } else {
          _lessons.add(lesson);
        }
        notifyListeners();
      }
      
      return lesson;
    } catch (e) {
      _lessonsError = e.toString();
      return null;
    } finally {
      _isLoadingLessons = false;
      notifyListeners();
    }
  }  /// Mark lesson as completed
  Future<void> markLessonAsCompleted(String lessonId) async {
    try {
      await _grammarRepository.markLessonCompleted(lessonId);
      
      // Update lesson status in local list
      final index = _lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        final lesson = _lessons[index];
        final updatedLesson = lesson.copyWith(
          status: GrammarLessonStatus.completed,
          updatedAt: DateTime.now(),
        );
        _lessons[index] = updatedLesson;
        notifyListeners();
      }
    } catch (e) {
      _lessonsError = e.toString();
      notifyListeners();
    }
  }
}
