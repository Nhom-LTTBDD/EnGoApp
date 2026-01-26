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
