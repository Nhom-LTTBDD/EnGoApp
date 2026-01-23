// lib/core/constants/vocabulary_constants.dart

/// Constants cho Vocabulary module
class VocabularyConstants {
  VocabularyConstants._(); // Private constructor để prevent instantiation

  // ============================================================================
  // Storage Keys
  // ============================================================================
  static const String personalVocabularyStorageKey = 'personal_vocabulary';

  // ============================================================================
  // Firestore Collections
  // ============================================================================
  static const String personalVocabulariesCollection = 'personal_vocabularies';

  // ============================================================================
  // Sync Configuration
  // ============================================================================
  static const Duration syncDebounceInterval = Duration(seconds: 5);
  static const Duration cloudLoadTimeout = Duration(seconds: 5);
  static const Duration forceSyncTimeout = Duration(seconds: 10);

  // ============================================================================
  // Parts of Speech (Loại từ)
  // ============================================================================
  static const String partOfSpeechNoun = 'noun';
  static const String partOfSpeechVerb = 'verb';
  static const String partOfSpeechAdjective = 'adjective';
  static const String partOfSpeechAdverb = 'adverb';
  static const String partOfSpeechPronoun = 'pronoun';
  static const String partOfSpeechPreposition = 'preposition';
  static const String partOfSpeechConjunction = 'conjunction';
  static const String partOfSpeechInterjection = 'interjection';

  static const List<String> allPartsOfSpeech = [
    partOfSpeechNoun,
    partOfSpeechVerb,
    partOfSpeechAdjective,
    partOfSpeechAdverb,
    partOfSpeechPronoun,
    partOfSpeechPreposition,
    partOfSpeechConjunction,
    partOfSpeechInterjection,
  ];

  // ============================================================================
  // Log Messages
  // ============================================================================
  static const String logLoadingFromLocal = 'Loaded from local storage';
  static const String logLoadingFromCloud = 'Local storage empty, fetching from cloud...';
  static const String logRestoredFromCloud = 'Restored from cloud';
  static const String logNoDataFound = 'No data found, creating new empty model';
  static const String logSavedToLocal = 'Saved to local storage';
  static const String logSyncedToCloud = 'Synced to cloud';
  static const String logSyncFailed = 'Cloud sync failed';
  static const String logSyncSkipped = 'Skipping cloud sync (debouncing';
  static const String logStartingSync = 'Starting cloud sync...';
  // ============================================================================
  // Error Messages
  // ============================================================================
  static const String errorLoadingVocabulary = 'Error loading personal vocabulary';
  static const String errorSavingVocabulary = 'Error saving personal vocabulary';
  static const String errorLoadingFromCloud = 'Error loading from cloud';
  static const String errorSavingToLocal = 'Error saving to local';
  static const String errorForceSyncFailed = 'Force sync failed';
  static const String errorRestoreFailed = 'Restore failed';

  // ============================================================================
  // UI Constants - Card Widget
  // ============================================================================
  static const Duration cardFlipAnimationDuration = Duration(milliseconds: 300);
  static const double cardHeightDefault = 200.0;
  static const double fullscreenIconSize = 30.0;
  static const double fullscreenButtonSize = 32.0;

  // ============================================================================
  // UI Constants - Dots Indicator
  // ============================================================================
  static const int maxDotsCount = 4;
  static const int minCardsForDotsLogic = 5;
}
