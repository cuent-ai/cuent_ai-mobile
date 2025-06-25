import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import '../models/asset_model.dart';
import '../../projects/models/project_model.dart';
import '../../../core/theme/app_theme.dart';

class AssetPlayerScreen extends StatefulWidget {
  final AssetModel asset;
  final ProjectModel project;

  const AssetPlayerScreen({
    super.key,
    required this.asset,
    required this.project,
  });

  @override
  State<AssetPlayerScreen> createState() => _AssetPlayerScreenState();
}

class _AssetPlayerScreenState extends State<AssetPlayerScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  bool _showVideoControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.asset.hasVideo && widget.asset.isVideoReady) {
        await _initializeVideoPlayer();
      } else if (widget.asset.hasAudio && widget.asset.isAudioReady) {
        await _initializeAudioPlayer();
      } else {
        setState(() {
          _errorMessage = 'No hay contenido multimedia disponible';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el contenido: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.asset.videoUrl),
    );

    await _videoController!.initialize();

    _videoController!.addListener(_videoListener);

    setState(() {
      _duration = _videoController!.value.duration;
    });
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    await _audioPlayer!.setUrl(widget.asset.audioUrl);

    _audioPlayer!.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    _audioPlayer!.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer!.playingStream.listen((playing) {
      setState(() {
        _isPlaying = playing;
      });
    });
  }

  void _videoListener() {
    if (_videoController != null) {
      setState(() {
        _position = _videoController!.value.position;
        _isPlaying = _videoController!.value.isPlaying;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_videoController != null) {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
    } else if (_audioPlayer != null) {
      if (_audioPlayer!.playing) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play();
      }
    }
  }

  Future<void> _seek(Duration position) async {
    if (_videoController != null) {
      await _videoController!.seekTo(position);
    } else if (_audioPlayer != null) {
      await _audioPlayer!.seek(position);
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(
                            widget.asset.type,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getTypeColor(
                              widget.asset.type,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          widget.asset.type,
                          style: TextStyle(
                            color: _getTypeColor(widget.asset.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'Posición ${widget.asset.position}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.asset.line,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Media player
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              _buildMediaPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPlayer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          // Video player or audio visualization
          if (_videoController != null)
            _buildVideoPlayer()
          else
            _buildAudioVisualizer(),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bar
                _buildProgressBar(),
                const SizedBox(height: 16),

                // Play/pause button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showVideoControls = !_showVideoControls;
        });
      },
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioVisualizer() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.audiotrack, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Reproduciendo Audio',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
        _duration.inMilliseconds > 0
            ? _position.inMilliseconds / _duration.inMilliseconds
            : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (value * _duration.inMilliseconds).round(),
              );
              _seek(newPosition);
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'TTS':
        return AppTheme.primaryColor;
      case 'SFX':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
