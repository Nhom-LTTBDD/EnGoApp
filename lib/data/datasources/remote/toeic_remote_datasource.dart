// lib/data/datasources/remote/toeic_remote_datasource.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/toeic_test_model.dart';
import '../../models/toeic_question_model.dart';
import '../../../core/constants/firebase_collections.dart';

abstract class ToeicRemoteDatasource {
  Future<void> uploadToeicTest(ToeicTestModel test);
  Future<void> uploadToeicQuestions(List<ToeicQuestionModel> questions);
  Future<String> uploadAudioFile(
    File audioFile,
    String testId,
    int questionNumber,
  );
  Future<ToeicTestModel?> getToeicTest(String testId);
  Future<List<ToeicQuestionModel>> getToeicQuestions(String testId);
  Future<List<ToeicQuestionModel>> getToeicQuestionsByParts(
    String testId,
    List<int> partNumbers,
  );
}

class ToeicRemoteDatasourceImpl implements ToeicRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ToeicRemoteDatasourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> uploadToeicTest(ToeicTestModel test) async {
    try {
      await _firestore
          .collection(FirebaseCollections.toeicTests)
          .doc(test.id)
          .set(test.toJson());
    } catch (e) {
      throw Exception('Failed to upload TOEIC test: $e');
    }
  }

  @override
  Future<void> uploadToeicQuestions(List<ToeicQuestionModel> questions) async {
    try {
      final batch = _firestore.batch();

      for (final question in questions) {
        final docRef = _firestore
            .collection(FirebaseCollections.toeicQuestions)
            .doc(question.id);
        batch.set(docRef, question.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to upload TOEIC questions: $e');
    }
  }

  @override
  Future<String> uploadAudioFile(
    File audioFile,
    String testId,
    int questionNumber,
  ) async {
    try {
      final fileName = 'q${questionNumber.toString().padLeft(3, '0')}.mp3';
      final ref = _storage.ref().child('toeic_audio/$testId/$fileName');

      final uploadTask = await ref.putFile(audioFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }

  @override
  Future<ToeicTestModel?> getToeicTest(String testId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.toeicTests)
          .doc(testId)
          .get();

      if (!doc.exists) return null;

      return ToeicTestModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get TOEIC test: $e');
    }
  }

  @override
  Future<List<ToeicQuestionModel>> getToeicQuestions(String testId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.toeicQuestions)
          .where('testId', isEqualTo: testId)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ToeicQuestionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get TOEIC questions: $e');
    }
  }

  @override
  Future<List<ToeicQuestionModel>> getToeicQuestionsByParts(
    String testId,
    List<int> partNumbers,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.toeicQuestions)
          .where('testId', isEqualTo: testId)
          .where('partNumber', whereIn: partNumbers)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ToeicQuestionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get TOEIC questions by parts: $e');
    }
  }
}
