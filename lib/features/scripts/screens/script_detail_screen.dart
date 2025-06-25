import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../projects/models/project_model.dart';
import '../models/script_model.dart';
import '../models/script_detail_model.dart' as detail;
import '../providers/script_detail_provider.dart';
import '../../../core/theme/app_theme.dart';

class ScriptDetailScreen extends StatefulWidget {
  final ScriptModel script;
  final ProjectModel project;

  const ScriptDetailScreen({
    super.key,
    required this.script,
    required this.project,
  });

  @override
  State<ScriptDetailScreen> createState() => _ScriptDetailScreenState();
}

class _ScriptDetailScreenState extends State<ScriptDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar detalles del script cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scriptProvider = Provider.of<ScriptDetailProvider>(
        context,
        listen: false,
      );
      scriptProvider.fetchScriptDetail(widget.script.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Script'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final scriptProvider = Provider.of<ScriptDetailProvider>(
                context,
                listen: false,
              );
              scriptProvider.fetchScriptDetail(widget.script.id);
            },
          ),
        ],
      ),
      body: Consumer<ScriptDetailProvider>(
        builder: (context, scriptProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await scriptProvider.fetchScriptDetail(widget.script.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del proyecto y script
                  _buildProjectScriptHeader(),
                  const SizedBox(height: 24),

                  // Contenido del script
                  if (scriptProvider.isLoadingScript) ...[
                    _buildLoadingState(),
                  ] else if (scriptProvider.scriptError != null) ...[
                    _buildErrorState(scriptProvider),
                  ] else if (scriptProvider.hasCurrentScript) ...[
                    _buildScriptContent(scriptProvider.currentScript!),
                  ] else ...[
                    _buildEmptyState(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectScriptHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.accentColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proyecto
          Row(
            children: [
              Icon(Icons.folder, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.project.name,
                style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Script
          Row(
            children: [
              Icon(Icons.article, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Script',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildStateChip(widget.script.state),
            ],
          ),

          const SizedBox(height: 12),

          // Texto del script
          if (widget.script.displayText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.script.displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[200],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScriptContent(detail.ScriptDetail scriptDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del script
        _buildScriptInfo(scriptDetail),
        const SizedBox(height: 24),

        // Assets del script
        _buildAssetsSection(scriptDetail.assets),
      ],
    );
  }

  Widget _buildScriptInfo(detail.ScriptDetail script) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Script',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Tokens
          if (script.totalToken > 0 || script.totalCuentoken > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.toll,
                    label: 'Total Tokens',
                    value: script.totalToken.toString(),
                    color: Colors.blue,
                  ),
                ),
                if (script.totalCuentoken > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.psychology,
                      label: 'CuentoTokens',
                      value: script.totalCuentoken.toString(),
                      color: Colors.purple,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Detalles de tokens
          if (script.promptTokens > 0 || script.completionTokens > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.input,
                    label: 'Prompt Tokens',
                    value: script.promptTokens.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.output,
                    label: 'Completion Tokens',
                    value: script.completionTokens.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Media
          Row(
            children: [
              if (script.hasMixedAudio) ...[
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.audiotrack,
                    label: 'Audio Mezclado',
                    value: 'Disponible',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (script.hasMixedMedia) ...[
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.video_library,
                    label: 'Video Mezclado',
                    value: 'Disponible',
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Fechas
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Creado',
                  value: _formatDate(script.createdAt),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.update,
                  label: 'Actualizado',
                  value: _formatDate(script.updatedAt),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsSection(List<detail.ScriptAsset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assets del Script',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${assets.length} asset${assets.length != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (assets.isEmpty) ...[
          _buildEmptyAssetsState(),
        ] else ...[
          // Estadísticas de assets
          _buildAssetsStats(assets),
          const SizedBox(height: 20),

          // Lista de assets
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                        Text(
                          'Asset ${asset.type}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          asset.displayDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (asset.line.isNotEmpty) ...[
                      Text(
                        asset.line,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        if (asset.hasAudio) ...[
                          Icon(
                            Icons.audiotrack,
                            color: Colors.green[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Audio',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[400],
                            ),
                          ),
                        ],
                        if (asset.hasVideo) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.videocam,
                            color: Colors.blue[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Video',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[400],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAssetsStats(List<detail.ScriptAsset> assets) {
    int finished = assets.where((a) => a.isFinished).length;
    int audioReady = assets.where((a) => a.hasAudio).length;
    int videoReady = assets.where((a) => a.hasVideo).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.apps,
            label: 'Total',
            value: assets.length,
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Terminados',
            value: finished,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.audiotrack,
            label: 'Audio Listo',
            value: audioReady,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.video_library,
            label: 'Video Listo',
            value: videoReady,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildEmptyAssetsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.media_bluetooth_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay assets disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los assets aparecerán aquí cuando estén disponibles para este script',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ScriptDetailProvider scriptProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el script',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scriptProvider.scriptError ?? 'Error desconocido',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                scriptProvider.fetchScriptDetail(widget.script.id);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Script no encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(String state) {
    Color chipColor;
    String stateText;

    switch (state.toUpperCase()) {
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
        stateText = state;
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
