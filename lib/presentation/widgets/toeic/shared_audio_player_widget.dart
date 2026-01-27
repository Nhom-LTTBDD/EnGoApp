// lib/presentation/widgets/toeic/shared_audio_player_widget.dart

/// LOGIC THANH PROGRESS BAR - CHI TIẾT HOẠT ĐỘNG:
/// ====================================================
///
/// 1. CẤU TRÚC THANH PROGRESS:
///    - Sử dụng LinearProgressIndicator (thanh tiến độ tuyến tính)
///    - Hiển thị trực quan quá trình phát audio từ đầu đến cuối
///    - Chiều cao cố định: 8px
///    - Chiếm toàn bộ chiều rộng khi có khoảng trống
///
/// 2. GIỚI HẠN GIÁ TRỊ (0.0 - 1.0):
///    - value = audioPosition.inSeconds / totalDuration.inSeconds
///    - 0.0 = Chưa phát (vị trí ban đầu)
///    - 0.5 = Phát được 50% audio
///    - 1.0 = Phát hết (kết thúc audio)
///    - Nếu totalDuration = 0 (audio chưa load), gán value = 0.0 để tránh division by zero
///
/// 3. CẬP NHẬT LIÊN TỤC:
///    - AudioPlayer phát ra 2 event stream:
///      * onDurationChanged: Gọi khi audio load xong, cập nhật totalDuration
///      * onPositionChanged: Gọi liên tục mỗi 100ms, cập nhật currentPosition
///    - Mỗi khi nhận event, setState() được gọi để rebuild UI
///    - Progress bar tự động cập nhật vị trí con trỏ
///
/// 4. MÀUY SẮC THANH PROGRESS:
///    - backgroundColor (nền): getBorderColor(context) - màu xám nhạt
///      * Hiển thị phần audio chưa được phát
///    - valueColor (tiến độ): getSuccessColor(context) - màu xanh lá
///      * Hiển thị phần audio đã phát xong
///      * Tạo hình ảnh trực quan và dễ theo dõi
///
/// 5. HAI CHẾ ĐỘ HOẠT ĐỘNG:
///    A. PROVIDER MODE (useProvider = true):
///       - Sử dụng ToeicTestProvider để quản lý state audio
///       - Consumer<ToeicTestProvider> tự động rebuild khi state thay đổi
///       - value = provider.audioPosition / provider.audioDuration
///       - Ưu điểm: Quản lý tập trung, chia sẻ state giữa nhiều widget
///
///    B. STANDALONE MODE (useProvider = false):
///       - Widget tự tạo AudioPlayer() riêng
///       - Lắng nghe sự kiện từ audioPlayer trực tiếp
///       - value = currentPosition / totalDuration
///       - Ưu điểm: Độc lập, không cần Provider, dùng ở review_page
///
/// 6. FLOW CỬ CHỈ:
///    - Bước 1: AudioPlayer load audio → onDurationChanged gọi
///    - Bước 2: Thời gian phát càng kéo dài, onPositionChanged gọi nhiều lần
///    - Bước 3: Mỗi lần onPositionChanged, currentPosition được cập nhật
///    - Bước 4: value = currentPosition / totalDuration được tính lại
///    - Bước 5: LinearProgressIndicator render lại với giá trị mới
///    - Bước 6: Con trỏ xanh trên thanh progress di chuyển theo vị trí phát
///
/// 7. TÍNH NĂNG SAFE GUARDS:
///    - Kiểm tra mounted trước setState() để tránh lỗi khi widget unmounted
///    - Kiểm tra totalDuration > 0 trước khi chia để tránh lỗi infinity
///    - Kiểm tra firebaseUrl != null trước khi phát
///    - Try-catch trong playAudio() để xử lý lỗi phát audio
///
/// 8. VÍ DỤ HOẠT ĐỘNG THỰC TẾ:
///    - Audio dài 2 phút (120 giây)
///    - Sau 30 giây: value = 30/120 = 0.25 → Progress bar hiển thị 25%
///    - Sau 60 giây: value = 60/120 = 0.5 → Progress bar hiển thị 50%
///    - Sau 120 giây: value = 120/120 = 1.0 → Progress bar hiển thị 100% (phát xong)
///

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../data/services/firebase_storage_service.dart';
import '../../providers/toeic_test_provider.dart';

/// Widget phát audio chung cho tất cả các trang (taking_page, review_page)
/// Hỗ trợ cache URL, progress bar, play/pause button
///
/// [audioUrl] - URL của audio (firebase_audio: prefix hoặc direct URL)
/// [useProvider] - Nếu true, sẽ dùng ToeicTestProvider để quản lý state
/// [onPlayStart] - Callback khi bắt đầu phát
/// [onPlayEnd] - Callback khi kết thúc phát
class SharedAudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool useProvider;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayEnd;

  const SharedAudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.useProvider = false,
    this.onPlayStart,
    this.onPlayEnd,
  });

  @override
  State<SharedAudioPlayerWidget> createState() =>
      _SharedAudioPlayerWidgetState();
}

class _SharedAudioPlayerWidgetState extends State<SharedAudioPlayerWidget> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  String? firebaseUrl;
  bool isLoading = true;
  String? errorMessage;

  // Cache cho Firebase audio URLs
  static final Map<String, String> _audioUrlCache = {};

  @override
  void initState() {
    super.initState();

    if (widget.useProvider) {
      // Nếu dùng Provider, không cần khởi tạo AudioPlayer riêng
      // Provider sẽ handle tất cả
    } else {
      // Chế độ standalone
      audioPlayer = AudioPlayer();

      // Setup listeners
      audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state == PlayerState.playing;
          });
        }
      });

      audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      });

      audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            totalDuration = duration;
          });
        }
      });

      // Load Firebase URL
      _loadAudioUrl();
    }
  }

  Future<void> _loadAudioUrl() async {
    try {
      // Kiểm tra cache trước
      if (_audioUrlCache.containsKey(widget.audioUrl)) {
        final cachedUrl = _audioUrlCache[widget.audioUrl];
        if (mounted) {
          setState(() {
            firebaseUrl = cachedUrl;
            isLoading = false;
          });
        }
        return;
      }

      // Resolve Firebase URL
      final url = await FirebaseStorageService.resolveFirebaseUrl(
        widget.audioUrl,
      );
      if (url != null) {
        _audioUrlCache[widget.audioUrl] = url;
      }

      if (mounted) {
        setState(() {
          firebaseUrl = url;
          isLoading = false;
          errorMessage = url == null ? 'Không thể tải audio từ Firebase' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Lỗi tải audio: $e';
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (firebaseUrl == null) return;

    try {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play(UrlSource(firebaseUrl!));
        widget.onPlayStart?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: getErrorColor(context),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (!widget.useProvider) {
      audioPlayer.stop();
      audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useProvider) {
      // Mode: dùng Provider để quản lý state
      return Consumer<ToeicTestProvider>(
        builder: (context, audioProvider, child) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Play/Pause button
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () {
                      if (audioProvider.isAudioPlaying) {
                        audioProvider.pauseAudio();
                      } else {
                        audioProvider.playAudio(widget.audioUrl);
                      }
                    },
                    icon: Icon(
                      audioProvider.isAudioPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                // Progress bar
                Expanded(
                  child: LinearProgressIndicator(
                    value: audioProvider.audioDuration.inSeconds > 0
                        ? audioProvider.audioPosition.inSeconds /
                              audioProvider.audioDuration.inSeconds
                        : 0.0,
                    backgroundColor: getBorderColor(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getSuccessColor(context),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Mode: standalone (không dùng Provider)
    if (errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: getErrorColor(context), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(fontSize: 14, color: getErrorColor(context)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Play/Pause button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 12),
          // Progress bar
          Expanded(
            child: LinearProgressIndicator(
              value: totalDuration.inSeconds > 0
                  ? currentPosition.inSeconds / totalDuration.inSeconds
                  : 0.0,
              backgroundColor: getBorderColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                getSuccessColor(context),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
