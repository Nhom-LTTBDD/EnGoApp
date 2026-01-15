// lib/data/datasources/dictionary_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary_model.dart';

abstract class DictionaryRemoteDataSource {
  /// Get word definition from Dictionary API
  /// Throws [DictionaryNotFoundException] if word not found
  /// Throws [DictionaryApiException] for other errors
  Future<DictionaryModel> getWordDefinition(String word);
}

class DictionaryRemoteDataSourceImpl implements DictionaryRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  const DictionaryRemoteDataSourceImpl({required this.client});

  @override
  Future<DictionaryModel> getWordDefinition(String word) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/${word.toLowerCase().trim()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        if (jsonList.isEmpty) {
          throw DictionaryNotFoundException('No definition found for "$word"');
        }

        // API returns array, we take the first result
        return DictionaryModel.fromJson(jsonList[0] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw DictionaryNotFoundException('Word "$word" not found in dictionary');
      } else {
        throw DictionaryApiException(
          'Failed to fetch definition. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DictionaryException) {
        rethrow;
      }
      throw DictionaryApiException('Failed to connect to dictionary API: $e');
    }
  }
}

/// Base exception for dictionary errors
abstract class DictionaryException implements Exception {
  final String message;
  const DictionaryException(this.message);

  @override
  String toString() => message;
}

/// Thrown when word is not found in dictionary
class DictionaryNotFoundException extends DictionaryException {
  const DictionaryNotFoundException(super.message);
}

/// Thrown when API request fails
class DictionaryApiException extends DictionaryException {
  const DictionaryApiException(super.message);
}
