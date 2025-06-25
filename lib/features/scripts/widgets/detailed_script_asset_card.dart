import 'package:flutter/material.dart';
import '../models/script_detail_model.dart';
import 'media_player_widget.dart';
import '../../../core/theme/app_theme.dart';

class DetailedScriptAssetCard extends StatelessWidget {
  final ScriptAsset asset;
  final bool showAudio;
  final bool showVideo;

  const DetailedScriptAssetCard({
    super.key,
    required this.asset,
    this.showAudio = true,
    this.showVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del asset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getAssetIcon(), color: _getAssetColor(), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Asset ${asset.type}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildStateChip(asset.audioState, 'Audio'),
                    const SizedBox(width: 8),
                    _buildStateChip(asset.videoState, 'Video'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información del asset
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Posición', asset.position.toString()),
                  _buildInfoRow('Duración', asset.displayDuration),
                  _buildInfoRow('Tipo', asset.type),
                  if (asset.line.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Texto:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.line,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reproductores de audio y video
            if (showAudio && asset.hasAudio) ...[
              MediaPlayerWidget(
                url: asset.audioUrl!,
                type: MediaType.audio,
                title: 'Audio - ${asset.type}',
              ),
              const SizedBox(height: 12),
            ],

            if (showVideo && asset.hasVideo) ...[
              MediaPlayerWidget(
                url: asset.videoUrl!,
                type: MediaType.video,
                title: 'Video - ${asset.type}',
              ),
            ],

            // Mensaje si no hay medios disponibles
            if (!asset.hasAudio && !asset.hasVideo) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[400]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Este asset no tiene archivos de audio o video disponibles',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip(String state, String type) {
    Color chipColor;

    switch (state.toUpperCase()) {
      case 'FINISHED':
        chipColor = Colors.green;
        break;
      case 'PENDING':
        chipColor = Colors.orange;
        break;
      case 'IN_PROGRESS':
        chipColor = Colors.blue;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getAssetIcon() {
    switch (asset.type.toUpperCase()) {
      case 'TTS':
        return Icons.record_voice_over;
      case 'AUDIO':
        return Icons.audiotrack;
      case 'VIDEO':
        return Icons.videocam;
      default:
        return Icons.attachment;
    }
  }

  Color _getAssetColor() {
    switch (asset.type.toUpperCase()) {
      case 'TTS':
        return Colors.green[400]!;
      case 'AUDIO':
        return Colors.blue[400]!;
      case 'VIDEO':
        return Colors.purple[400]!;
      default:
        return Colors.grey[400]!;
    }
  }
}
