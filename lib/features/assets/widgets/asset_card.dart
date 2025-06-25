import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import '../../../core/theme/app_theme.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback? onTap;

  const AssetCard({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and position
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(asset.type).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getTypeColor(asset.type).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      asset.type,
                      style: TextStyle(
                        color: _getTypeColor(asset.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'Posición ${asset.position}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Line content
              Text(
                asset.line,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Duration and media availability
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${asset.duration.toStringAsFixed(1)}s',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(width: 16),

                  // Audio indicator
                  if (asset.hasAudio) ...[
                    Icon(
                      asset.isAudioReady ? Icons.audiotrack : Icons.pending,
                      size: 16,
                      color:
                          asset.isAudioReady
                              ? AppTheme.primaryColor
                              : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Audio',
                      style: TextStyle(
                        color:
                            asset.isAudioReady
                                ? AppTheme.primaryColor
                                : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Video indicator
                  if (asset.hasVideo) ...[
                    Icon(
                      asset.isVideoReady ? Icons.videocam : Icons.pending,
                      size: 16,
                      color:
                          asset.isVideoReady
                              ? AppTheme.primaryColor
                              : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(
                        color:
                            asset.isVideoReady
                                ? AppTheme.primaryColor
                                : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
