import 'package:flutter_tts/flutter_tts.dart';

// Service để xử lý Text-to-Speech
// Có thể tái sử dụng ở bất kỳ UI nào
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Khởi tạo TTS với cấu hình mặc định
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cấu hình chung
      await _flutterTts.setVolume(1.0); // 0.0 - 1.0
      await _flutterTts.setSpeechRate(0.5); // 0.0 - 1.0 (slow - fast)
      await _flutterTts.setPitch(1.0); // 0.5 - 2.0

      // Cấu hình cho iOS
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _isInitialized = true;
    } catch (e) {
      // Log error nhưng không throw, để TTS vẫn có thể hoạt động với config mặc định
      print('TTS initialization warning: ${e.toString()}');
      _isInitialized = true; // Đánh dấu là đã khởi tạo để không thử lại
    }
  }

  // Phát âm text với ngôn ngữ chỉ định
  //
  // [text]: Text cần đọc
  // [languageCode]: Mã ngôn ngữ ('en-US', 'vi-VN')
  Future<void> speak(String text, String languageCode) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (text.trim().isEmpty) {
        return;
      }

      // Dừng nếu đang phát
      await stop();

      // Set ngôn ngữ
      await _flutterTts.setLanguage(languageCode);

      // Phát âm
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: ${e.toString()}');
    }
  }

  // Phát âm tiếng Anh
  Future<void> speakEnglish(String text) async {
    await speak(text, 'en-US');
  }

  // Phát âm tiếng Việt
  Future<void> speakVietnamese(String text) async {
    await speak(text, 'vi-VN');
  }

  // Dừng phát âm
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // Ignore stop errors
    }
  }

  // Dispose resources
  void dispose() {
    _flutterTts.stop();
  }
}
