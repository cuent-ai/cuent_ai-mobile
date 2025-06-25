import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../projects/models/project_model.dart';
import '../providers/script_provider.dart';
import '../widgets/script_card.dart';
import 'script_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProjectScriptsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectScriptsScreen({super.key, required this.project});

  @override
  State<ProjectScriptsScreen> createState() => _ProjectScriptsScreenState();
}

class _ProjectScriptsScreenState extends State<ProjectScriptsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar scripts cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scriptProvider = Provider.of<ScriptProvider>(
        context,
        listen: false,
      );
      scriptProvider.fetchScriptsForProject(widget.project.id);
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
              final scriptProvider = Provider.of<ScriptProvider>(
                context,
                listen: false,
              );
              scriptProvider.fetchScriptsForProject(widget.project.id);
            },
          ),
        ],
      ),
      body: Consumer<ScriptProvider>(
        builder: (context, scriptProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await scriptProvider.fetchScriptsForProject(widget.project.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header del proyecto
                  _buildProjectHeader(),
                  const SizedBox(height: 24),

                  // Sección de scripts
                  _buildScriptsSection(scriptProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectHeader() {
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
              Icon(Icons.article, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.project.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.project.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[300]),
          ),
          const SizedBox(height: 12),
          // Estado del proyecto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getProjectStateColor(widget.project.state),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getProjectStateText(widget.project.state),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptsSection(ScriptProvider scriptProvider) {
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
            if (!scriptProvider.isLoading) ...[
              Text(
                '${scriptProvider.currentProjectScripts.length} script${scriptProvider.currentProjectScripts.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Estadísticas de scripts
        if (scriptProvider.hasCurrentProjectScripts &&
            !scriptProvider.isLoading) ...[
          _buildScriptStats(scriptProvider),
          const SizedBox(height: 20),
        ],

        // Lista de scripts o estados
        if (scriptProvider.isLoading) ...[
          _buildLoadingState(),
        ] else if (scriptProvider.errorMessage != null) ...[
          _buildErrorState(scriptProvider),
        ] else if (!scriptProvider.hasCurrentProjectScripts) ...[
          _buildEmptyState(),
        ] else ...[
          _buildScriptsList(scriptProvider),
        ],
      ],
    );
  }

  Widget _buildScriptStats(ScriptProvider scriptProvider) {
    final stats = scriptProvider.getScriptStatsForProject(widget.project.id);

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
            value: stats['total']!,
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Terminados',
            value: stats['finished']!,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.pending,
            label: 'Pendientes',
            value: stats['pending']!,
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.sync,
            label: 'En Progreso',
            value: stats['inProgress']!,
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

  Widget _buildErrorState(ScriptProvider scriptProvider) {
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
              scriptProvider.errorMessage ?? 'Error desconocido',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                scriptProvider.fetchScriptsForProject(widget.project.id);
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

  Widget _buildScriptsList(ScriptProvider scriptProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scriptProvider.currentProjectScripts.length,
      itemBuilder: (context, index) {
        final script = scriptProvider.currentProjectScripts[index];
        return ScriptCard(
          script: script,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ScriptDetailScreen(
                      script: script,
                      project: widget.project,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getProjectStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green[600]!;
      case 'PENDING':
        return Colors.orange[600]!;
      case 'IN_PROGRESS':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getProjectStateText(String state) {
    switch (state.toUpperCase()) {
      case 'COMPLETED':
        return 'Completado';
      case 'PENDING':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En Progreso';
      default:
        return state;
    }
  }
}
