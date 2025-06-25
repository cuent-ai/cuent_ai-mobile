import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../projects/models/project_model.dart';
import '../../projects/providers/project_provider.dart';
import '../widgets/project_script_card.dart';
import '../../../core/theme/app_theme.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar detalles del proyecto cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      projectProvider.fetchProjectDetail(widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scripts - ${widget.project.name}'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final projectProvider = Provider.of<ProjectProvider>(
                context,
                listen: false,
              );
              projectProvider.fetchProjectDetail(widget.project.id);
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await projectProvider.fetchProjectDetail(widget.project.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del proyecto
                  _buildProjectHeader(projectProvider),
                  const SizedBox(height: 24),

                  // Sección de scripts
                  _buildScriptsSection(projectProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectHeader(ProjectProvider projectProvider) {
    final project =
        projectProvider.currentProjectDetail?.project ?? widget.project;

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
          Row(
            children: [
              Icon(Icons.folder, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildStateChip(project.state),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          ),
          const SizedBox(height: 12),
          // Información adicional del proyecto
          if (project.cuentokens.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.psychology, size: 16, color: Colors.purple[300]),
                const SizedBox(width: 4),
                Text(
                  'CuentoTokens: ${project.cuentokens}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScriptsSection(ProjectProvider projectProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scripts del Proyecto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (!projectProvider.isLoadingProjectDetail) ...[
              Text(
                '${projectProvider.currentProjectScripts.length} script${projectProvider.currentProjectScripts.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Estadísticas de scripts
        if (projectProvider.currentProjectScripts.isNotEmpty &&
            !projectProvider.isLoadingProjectDetail) ...[
          _buildScriptStats(projectProvider.currentProjectScripts),
          const SizedBox(height: 20),
        ],

        // Lista de scripts o estados
        if (projectProvider.isLoadingProjectDetail) ...[
          _buildLoadingState(),
        ] else if (projectProvider.errorMessage != null) ...[
          _buildErrorState(projectProvider),
        ] else if (projectProvider.currentProjectScripts.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          _buildScriptsList(projectProvider.currentProjectScripts),
        ],
      ],
    );
  }

  Widget _buildScriptStats(List<ProjectScript> scripts) {
    int finished = scripts.where((s) => s.isFinished).length;
    int pending = scripts.where((s) => s.isPending).length;
    int inProgress = scripts.where((s) => s.isInProgress).length;

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
            icon: Icons.article,
            label: 'Total',
            value: scripts.length,
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Terminados',
            value: finished,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.pending,
            label: 'Pendientes',
            value: pending,
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.sync,
            label: 'En Progreso',
            value: inProgress,
            color: Colors.blue,
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

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ProjectProvider projectProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los scripts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              projectProvider.errorMessage ?? 'Error desconocido',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                projectProvider.fetchProjectDetail(widget.project.id);
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
              'No hay scripts disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los scripts aparecerán aquí cuando estén disponibles para este proyecto',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptsList(List<ProjectScript> scripts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scripts.length,
      itemBuilder: (context, index) {
        final script = scripts[index];
        return ProjectScriptCard(
          script: script,
          onTap: () {
            // TODO: Navegar a pantalla de assets del script
            _showScriptAssets(script);
          },
        );
      },
    );
  }

  void _showScriptAssets(ProjectScript script) {
    // Por ahora mostramos un diálogo con la información del script
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Text(
              'Script ID: ${script.id}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado: ${script.state}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Tokens: ${script.totalToken}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'CuentoTokens: ${script.totalCuentoken}',
                  style: const TextStyle(color: Colors.white),
                ),
                if (script.hasMixedAudio) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🎵 Tiene audio mezclado',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
                if (script.hasMixedMedia) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🎥 Tiene video mezclado',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Aquí implementar navegación a assets del script
                },
                child: const Text('Ver Assets'),
              ),
            ],
          ),
    );
  }

  Widget _buildStateChip(String state) {
    Color chipColor;
    String stateText;

    switch (state.toUpperCase()) {
      case 'COMPLETED':
        chipColor = Colors.green[600]!;
        stateText = 'Completado';
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
}
