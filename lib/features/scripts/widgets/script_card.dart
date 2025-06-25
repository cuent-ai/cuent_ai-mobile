import 'package:flutter/material.dart';
import '../models/script_model.dart';
import '../../../core/theme/app_theme.dart';

class ScriptCard extends StatelessWidget {
  final ScriptModel script;
  final VoidCallback? onTap;

  const ScriptCard({super.key, required this.script, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              // Header con estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Script',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildStateChip(),
                ],
              ),

              const SizedBox(height: 12),

              // Texto del script (preview)
              if (script.displayText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    script.displayText.length > 150
                        ? '${script.displayText.substring(0, 150)}...'
                        : script.displayText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Información de tokens
              if (script.totalToken > 0 || script.totalCuentoken > 0) ...[
                Row(
                  children: [
                    Icon(Icons.toll, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Tokens: ${script.totalToken}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    if (script.totalCuentoken > 0) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: Colors.purple[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CuentoTokens: ${script.totalCuentoken}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Media disponible
              Row(
                children: [
                  if (script.hasMixedAudio) ...[
                    Icon(Icons.audiotrack, size: 16, color: Colors.green[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Audio',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (script.hasMixedMedia) ...[
                    Icon(
                      Icons.video_library,
                      size: 16,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 16),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Fecha de creación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(script.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip() {
    Color chipColor;
    String stateText;

    switch (script.state.toUpperCase()) {
      case 'FINISHED':
        chipColor = Colors.green[600]!;
        stateText = 'Terminado';
        break;
      case 'PENDING':
        chipColor = Colors.orange[600]!;
        stateText = 'Pendiente';
        break;
      case 'IN_PROGRESS':
        chipColor = Colors.blue[600]!;
        stateText = 'En Progreso';
        break;
      default:
        chipColor = Colors.grey[600]!;
        stateText = script.state;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        stateText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'ahora mismo';
    }
  }
}
