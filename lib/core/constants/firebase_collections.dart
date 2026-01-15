// lib/core/constants/firebase_collections.dart

class FirebaseCollections {
  // Firestore collections
  static const String toeicTests = 'toeic_tests';
  static const String toeicQuestions = 'toeic_questions';
  static const String userResults = 'user_results';
  static const String users = 'users';
  static const String grammar = 'grammar';
  static const String vocabulary = 'vocabulary';

  // Firebase Storage paths
  static const String toeicAudio = 'toeic_audio';
  static const String toeicImages = 'toeic_images';
  static const String userUploads = 'user_uploads';

  // Subcollections
  static const String testSessions = 'test_sessions';
  static const String questions = 'questions';
  static const String results = 'results';

  // Private constructor to prevent instantiation
  FirebaseCollections._();
}