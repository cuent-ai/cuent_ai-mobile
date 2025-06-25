import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;

  // Para manejar el detalle del proyecto actual
  ProjectDetailResponse? _currentProjectDetail;
  bool _isLoadingProjectDetail = false;
  String? _currentProjectId;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _currentPage < _totalPages - 1;

  // Getters para el detalle del proyecto
  ProjectDetailResponse? get currentProjectDetail => _currentProjectDetail;
  bool get isLoadingProjectDetail => _isLoadingProjectDetail;
  String? get currentProjectId => _currentProjectId;
  List<ProjectScript> get currentProjectScripts =>
      _currentProjectDetail?.project.scripts ?? [];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingProjectDetail(bool loading) {
    _isLoadingProjectDetail = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects({int offset = 0}) async {
    _setLoading(true);
    _clearError();

    try {
      final projectsResponse = await _projectService.getProjects(
        offset: offset,
      );
      _projects = projectsResponse.data;
      _currentPage = offset ~/ 10; // Assuming limit is 10
      _totalPages = projectsResponse.pages;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene el detalle de un proyecto específico con sus scripts
  Future<void> fetchProjectDetail(String projectId) async {
    _setLoadingProjectDetail(true);
    _clearError();
    _currentProjectId = projectId;

    try {
      _currentProjectDetail = await _projectService.getProjectById(projectId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoadingProjectDetail(false);
    }
  }

  /// Limpia los datos del proyecto actual
  void clearCurrentProject() {
    _currentProjectDetail = null;
    _currentProjectId = null;
    _clearError();
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (hasNextPage && !_isLoading) {
      final nextOffset = (_currentPage + 1) * 10;
      await fetchProjects(offset: nextOffset);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_currentPage > 0 && !_isLoading) {
      final prevOffset = (_currentPage - 1) * 10;
      await fetchProjects(offset: prevOffset);
    }
  }

  void clearProjects() {
    _projects = [];
    _errorMessage = null;
    notifyListeners();
  }
}
