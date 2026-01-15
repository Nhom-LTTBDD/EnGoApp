// lib/core/services/audio_service.dart

import 'package:audioplayers/audioplayers.dart';

/// Service để quản lý audio playback cho vocabulary cards
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingUrl;
  bool _isPlaying = false;

  /// Getter để kiểm tra trạng thái playing
  bool get isPlaying => _isPlaying;
  String? get currentPlayingUrl => _currentPlayingUrl;

  /// Phát audio từ URL
  Future<void> playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      print('⚠️ Audio URL is null or empty');
      return;
    }

    try {
      // Nếu đang phát cùng URL, dừng lại
      if (_isPlaying && _currentPlayingUrl == audioUrl) {
        await stopAudio();
        return;
      }

      // Dừng audio hiện tại nếu có
      await stopAudio();

      // Chuẩn bị URL - thêm https: nếu thiếu
      String fullUrl = audioUrl;
      if (audioUrl.startsWith('//')) {
        fullUrl = 'https:$audioUrl';
      }

      print('🔊 Playing audio: $fullUrl');

      // Phát audio
      _currentPlayingUrl = audioUrl;
      _isPlaying = true;
      
      await _audioPlayer.play(UrlSource(fullUrl));

      // Lắng nghe khi audio kết thúc
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _currentPlayingUrl = null;
      });

    } catch (e) {
      print('❌ Error playing audio: $e');
      _isPlaying = false;
      _currentPlayingUrl = null;
    }
  }

  /// Dừng audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPlayingUrl = null;
    } catch (e) {
      print('❌ Error stopping audio: $e');
    }
  }

  /// Pause audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('❌ Error pausing audio: $e');
    }
  }

  /// Resume audio
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      print('❌ Error resuming audio: $e');
    }
  }

  /// Giải phóng resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
