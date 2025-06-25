import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/script_detail_provider.dart';
import '../widgets/detailed_script_asset_card.dart';
import '../widgets/media_player_widget.dart';
import '../../../core/theme/app_theme.dart';

class ScriptAssetsScreen extends StatefulWidget {
  final String scriptId;
  final String scriptTitle;

  const ScriptAssetsScreen({
    super.key,
    required this.scriptId,
    required this.scriptTitle,
  });

  @override
  State<ScriptAssetsScreen> createState() => _ScriptAssetsScreenState();
}

class _ScriptAssetsScreenState extends State<ScriptAssetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar detalles del script cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ScriptDetailProvider>(
        context,
        listen: false,
      );
      provider.fetchScriptDetail(widget.scriptId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assets - ${widget.scriptTitle}'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.audiotrack), text: 'Audio'),
            Tab(icon: Icon(Icons.videocam), text: 'Video'),
            Tab(icon: Icon(Icons.description), text: 'Detalles'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<ScriptDetailProvider>(
                context,
                listen: false,
              );
              provider.fetchScriptDetail(widget.scriptId);
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<ScriptDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingScript) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (provider.scriptError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar assets',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.scriptError!,
                    style: TextStyle(color: Colors.red[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => provider.fetchScriptDetail(widget.scriptId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasCurrentScript) {
            return const Center(
              child: Text(
                'No hay información del script',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAudioTab(provider),
              _buildVideoTab(provider),
              _buildDetailsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAudioTab(ScriptDetailProvider provider) {
    final audioAssets = provider.audioAssets;
    final script = provider.currentScript!;

    return RefreshIndicator(
      onRefresh: () => provider.fetchScriptDetail(widget.scriptId),
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio mezclado del script (si existe)
            if (script.hasMixedAudio) ...[
              Card(
                color: AppTheme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.multitrack_audio,
                            color: Colors.green[400],
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Audio Mezclado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MediaPlayerWidget(
                        url: script.mixedAudio!,
                        type: MediaType.audio,
                        title: 'Audio completo del script',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Assets de audio individuales
            if (audioAssets.isNotEmpty) ...[
              Text(
                'Assets de Audio (${audioAssets.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...audioAssets.map(
                (asset) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DetailedScriptAssetCard(
                    asset: asset,
                    showAudio: true,
                    showVideo: false,
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Icon(Icons.audiotrack, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'No hay assets de audio disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
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

  Widget _buildVideoTab(ScriptDetailProvider provider) {
    final videoAssets = provider.videoAssets;
    final script = provider.currentScript!;

    return RefreshIndicator(
      onRefresh: () => provider.fetchScriptDetail(widget.scriptId),
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video mezclado del script (si existe)
            if (script.hasMixedMedia) ...[
              Card(
                color: AppTheme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.movie, color: Colors.blue[400]),
                          const SizedBox(width: 8),
                          const Text(
                            'Video Mezclado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MediaPlayerWidget(
                        url: script.mixedMedia!,
                        type: MediaType.video,
                        title: 'Video completo del script',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Assets de video individuales
            if (videoAssets.isNotEmpty) ...[
              Text(
                'Assets de Video (${videoAssets.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...videoAssets.map(
                (asset) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DetailedScriptAssetCard(
                    asset: asset,
                    showAudio: false,
                    showVideo: true,
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Icon(Icons.videocam, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'No hay assets de video disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
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

  Widget _buildDetailsTab(ScriptDetailProvider provider) {
    final script = provider.currentScript!;

    return RefreshIndicator(
      onRefresh: () => provider.fetchScriptDetail(widget.scriptId),
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general del script
            Card(
              color: AppTheme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[400]),
                        const SizedBox(width: 8),
                        const Text(
                          'Información del Script',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Estado', script.state),
                    _buildDetailRow(
                      'Tokens de Prompt',
                      script.promptTokens.toString(),
                    ),
                    _buildDetailRow(
                      'Tokens de Completion',
                      script.completionTokens.toString(),
                    ),
                    _buildDetailRow(
                      'Total de Tokens',
                      script.totalToken.toString(),
                    ),
                    _buildDetailRow(
                      'CuentoTokens',
                      script.totalCuentoken.toString(),
                    ),
                    _buildDetailRow(
                      'Total de Assets',
                      script.totalAssets.toString(),
                    ),
                    _buildDetailRow(
                      'Assets Terminados',
                      script.finishedAssets.toString(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Texto del script
            if (script.textEntry.isNotEmpty) ...[
              Card(
                color: AppTheme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_snippet, color: Colors.green[400]),
                          const SizedBox(width: 8),
                          const Text(
                            'Texto Original',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          script.textEntry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Texto procesado
            if (script.processedText.isNotEmpty) ...[
              Card(
                color: AppTheme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_fix_high, color: Colors.purple[400]),
                          const SizedBox(width: 8),
                          const Text(
                            'Texto Procesado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          script.processedText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
