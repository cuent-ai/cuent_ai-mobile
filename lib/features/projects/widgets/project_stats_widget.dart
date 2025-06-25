import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../../../core/theme/app_theme.dart';

class ProjectStatsWidget extends StatelessWidget {
  final List<ProjectModel> projects;

  const ProjectStatsWidget({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.folder,
            label: 'Total',
            value: stats['total'].toString(),
            color: AppTheme.primaryColor,
          ),
          _buildStatItem(
            icon: Icons.pending,
            label: 'Pendientes',
            value: stats['pending'].toString(),
            color: AppTheme.warningColor,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Completados',
            value: stats['completed'].toString(),
            color: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    int total = projects.length;
    int pending =
        projects.where((p) => p.state.toUpperCase() == 'PENDING').length;
    int completed =
        projects.where((p) => p.state.toUpperCase() == 'COMPLETED').length;

    return {'total': total, 'pending': pending, 'completed': completed};
  }
}
