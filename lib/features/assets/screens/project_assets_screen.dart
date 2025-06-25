import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../projects/models/project_model.dart';
import '../providers/asset_provider.dart';
import '../widgets/asset_card.dart';
import 'asset_player_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProjectAssetsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectAssetsScreen({super.key, required this.project});

  @override
  State<ProjectAssetsScreen> createState() => _ProjectAssetsScreenState();
}

class _ProjectAssetsScreenState extends State<ProjectAssetsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch assets when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assetProvider = Provider.of<AssetProvider>(context, listen: false);
      assetProvider.fetchAssets(projectId: widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final assetProvider = Provider.of<AssetProvider>(
                context,
                listen: false,
              );
              assetProvider.fetchAssets(projectId: widget.project.id);
            },
          ),
        ],
      ),
      body: Consumer<AssetProvider>(
        builder: (context, assetProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await assetProvider.fetchAssets(projectId: widget.project.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project info
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
                        Text(
                          widget.project.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Assets section
                  _buildAssetsSection(assetProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetsSection(AssetProvider assetProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assets del Proyecto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${assetProvider.assets.length} asset${assetProvider.assets.length != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (assetProvider.isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          )
        else if (assetProvider.errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.errorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar assets',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assetProvider.errorMessage!,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed:
                      () => assetProvider.fetchAssets(
                        projectId: widget.project.id,
                      ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          )
        else if (assetProvider.assets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Icon(Icons.library_music, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No hay assets en este proyecto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los assets aparecerán aquí cuando estén disponibles',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assetProvider.assets.length,
            itemBuilder: (context, index) {
              final asset = assetProvider.assets[index];
              return AssetCard(
                asset: asset,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AssetPlayerScreen(
                            asset: asset,
                            project: widget.project,
                          ),
                    ),
                  );
                },
              );
            },
          ),

          // Pagination controls
          if (assetProvider.assets.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildPaginationControls(assetProvider),
          ],
        ],
      ],
    );
  }

  Widget _buildPaginationControls(AssetProvider assetProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          if (isSmallScreen) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Text(
                    'Página ${assetProvider.currentPage + 1} de ${assetProvider.totalPages}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                              assetProvider.currentPage > 0 &&
                                      !assetProvider.isLoading
                                  ? () => assetProvider.loadPreviousPage()
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cardColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[800],
                            disabledForegroundColor: Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 4),
                              Text('Anterior', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed:
                              assetProvider.hasNextPage &&
                                      !assetProvider.isLoading
                                  ? () => assetProvider.loadNextPage()
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[800],
                            disabledForegroundColor: Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Siguiente', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed:
                          assetProvider.currentPage > 0 &&
                                  !assetProvider.isLoading
                              ? () => assetProvider.loadPreviousPage()
                              : null,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(
                        'Anterior',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[800],
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Text(
                      'Página ${assetProvider.currentPage + 1} de ${assetProvider.totalPages}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed:
                          assetProvider.hasNextPage && !assetProvider.isLoading
                              ? () => assetProvider.loadNextPage()
                              : null,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text(
                        'Siguiente',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[800],
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
