// lib/core/services/personal_vocabulary_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/personal_vocabulary_model.dart';

/// Service quản lý từ vựng cá nhân (lưu local với SharedPreferences)
class PersonalVocabularyService {
  static const String _storageKey = 'personal_vocabulary';
  
  final SharedPreferences _prefs;

  PersonalVocabularyService(this._prefs);

  // Get personal vocabulary
  Future<PersonalVocabularyModel> getPersonalVocabulary(String userId) async {
    try {
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString == null) {
        return PersonalVocabularyModel.empty(userId);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PersonalVocabularyModel.fromJson(json);
    } catch (e) {
      print('Error loading personal vocabulary: $e');
      return PersonalVocabularyModel.empty(userId);
    }
  }

  // Save personal vocabulary
  Future<void> savePersonalVocabulary(PersonalVocabularyModel model) async {
    try {
      final jsonString = jsonEncode(model.toJson());
      await _prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving personal vocabulary: $e');
      rethrow;
    }
  }

  // Add card to personal vocabulary
  Future<void> addCard(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.addCard(cardId);
    await savePersonalVocabulary(updated);
  }

  // Remove card from personal vocabulary
  Future<void> removeCard(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.removeCard(cardId);
    await savePersonalVocabulary(updated);
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    final updated = model.toggleBookmark(cardId);
    await savePersonalVocabulary(updated);
    return updated.isBookmarked(cardId);
  }

  // Check if card is bookmarked
  Future<bool> isBookmarked(String userId, String cardId) async {
    final model = await getPersonalVocabulary(userId);
    return model.isBookmarked(cardId);
  }

  // Get all bookmarked card IDs
  Future<List<String>> getBookmarkedCardIds(String userId) async {
    final model = await getPersonalVocabulary(userId);
    return model.vocabularyCardIds;
  }

  // Clear all bookmarks
  Future<void> clearAll(String userId) async {
    final model = PersonalVocabularyModel.empty(userId);
    await savePersonalVocabulary(model);
  }
}
