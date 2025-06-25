import 'package:flutter/material.dart';
import '../models/script_model.dart';
import '../../../core/theme/app_theme.dart';

class ScriptAssetCard extends StatelessWidget {
  final ScriptAsset asset;
  final VoidCallback? onTap;

  const ScriptAssetCard({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con tipo y posición
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTypeIcon(),
                      const SizedBox(width: 8),
                      Text(
                        asset.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pos: ${asset.position}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Texto/línea del asset
              if (asset.line.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    asset.line,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Estados de audio y video
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.audiotrack,
                      label: 'Audio',
                      status: asset.audioState,
                      isReady: asset.isAudioReady,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.video_library,
                      label: 'Video',
                      status: asset.videoState,
                      isReady: asset.isVideoReady,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Duración y URLs disponibles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(asset.duration),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (asset.hasAudio) ...[
                        Icon(
                          Icons.audio_file,
                          size: 16,
                          color: Colors.green[400],
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (asset.hasVideo) ...[
                        Icon(
                          Icons.video_file,
                          size: 16,
                          color: Colors.orange[400],
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (onTap != null) ...[
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (asset.type.toUpperCase()) {
      case 'TTS':
        iconData = Icons.record_voice_over;
        iconColor = Colors.blue[400]!;
        break;
      case 'MUSIC':
        iconData = Icons.music_note;
        iconColor = Colors.purple[400]!;
        break;
      case 'SFX':
        iconData = Icons.volume_up;
        iconColor = Colors.green[400]!;
        break;
      case 'VIDEO':
        iconData = Icons.videocam;
        iconColor = Colors.orange[400]!;
        break;
      default:
        iconData = Icons.extension;
        iconColor = Colors.grey[400]!;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String status,
    required bool isReady,
  }) {
    Color statusColor;
    String statusText;

    switch (status.toUpperCase()) {
      case 'FINISHED':
        statusColor = Colors.green[600]!;
        statusText = 'Listo';
        break;
      case 'PENDING':
        statusColor = Colors.orange[600]!;
        statusText = 'Pendiente';
        break;
      case 'PROCESSING':
      case 'IN_PROGRESS':
        statusColor = Colors.blue[600]!;
        statusText = 'Procesando';
        break;
      case 'ERROR':
        statusColor = Colors.red[600]!;
        statusText = 'Error';
        break;
      default:
        statusColor = Colors.grey[600]!;
        statusText = status;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: statusColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(double duration) {
    if (duration <= 0) return '0:00';

    final minutes = (duration ~/ 60);
    final seconds = (duration % 60).round();

    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
