// lib/data/datasources/dictionary_local_data_source.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dictionary_model.dart';

abstract class DictionaryLocalDataSource {
  /// Get cached word definition
  /// Returns null if not found in cache
  Future<DictionaryModel?> getCachedWordDefinition(String word);

  /// Cache word definition
  Future<void> cacheWordDefinition(DictionaryModel definition);

  /// Clear all cached definitions
  Future<void> clearCache();

  /// Get cache age for a word (in milliseconds)
  Future<int?> getCacheAge(String word);
}

class DictionaryLocalDataSourceImpl implements DictionaryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachePrefix = 'dictionary_cache_';
  static const String _timestampPrefix = 'dictionary_timestamp_';
  static const int _cacheExpirationDays = 7; // Cache valid for 7 days

  const DictionaryLocalDataSourceImpl({required this.sharedPreferences});

  String _getCacheKey(String word) => '$_cachePrefix${word.toLowerCase()}';
  String _getTimestampKey(String word) => '$_timestampPrefix${word.toLowerCase()}';

  @override
  Future<DictionaryModel?> getCachedWordDefinition(String word) async {
    try {
      final cacheKey = _getCacheKey(word);
      final timestampKey = _getTimestampKey(word);

      final jsonString = sharedPreferences.getString(cacheKey);
      final timestamp = sharedPreferences.getInt(timestampKey);

      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - timestamp;
      final expirationMs = _cacheExpirationDays * 24 * 60 * 60 * 1000;

      if (age > expirationMs) {
        // Cache expired, remove it
        await _removeCachedWord(word);
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DictionaryModel.fromJson(json);
    } catch (e) {
      // If any error occurs, return null
      return null;
    }
  }

  @override
  Future<void> cacheWordDefinition(DictionaryModel definition) async {
    try {
      final cacheKey = _getCacheKey(definition.word);
      final timestampKey = _getTimestampKey(definition.word);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final jsonString = jsonEncode(definition.toJson());
      
      await sharedPreferences.setString(cacheKey, jsonString);
      await sharedPreferences.setInt(timestampKey, timestamp);
    } catch (e) {
      // Silently fail - caching is not critical
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final dictionaryKeys = keys.where(
        (key) => key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix),
      );

      for (final key in dictionaryKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<int?> getCacheAge(String word) async {
    try {
      final timestampKey = _getTimestampKey(word);
      final timestamp = sharedPreferences.getInt(timestampKey);

      if (timestamp == null) {
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      return now - timestamp;
    } catch (e) {
      return null;
    }
  }

  Future<void> _removeCachedWord(String word) async {
    try {
      await sharedPreferences.remove(_getCacheKey(word));
      await sharedPreferences.remove(_getTimestampKey(word));
    } catch (e) {
      // Silently fail
    }
  }
}
