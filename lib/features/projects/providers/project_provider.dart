import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    _setLoading(true);
    _clearError();

    try {
      final projectsResponse = await _projectService.getProjects();
      _projects = projectsResponse.data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearProjects() {
    _projects = [];
    _errorMessage = null;
    notifyListeners();
  }
}
