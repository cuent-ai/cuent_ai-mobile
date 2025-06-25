import 'package:flutter/material.dart';
import '../models/script_model.dart';
import '../models/script_detail_model.dart' as detail;
import '../services/script_service.dart';

class ScriptProvider extends ChangeNotifier {
  final ScriptService _scriptService = ScriptService();

  // Estado para todos los scripts
  List<ScriptModel> _allScripts = [];
  Map<String, List<ScriptModel>> _scriptsByProject = {};

  // Estado para scripts del proyecto actual
  List<ScriptModel> _currentProjectScripts = [];
  String? _currentProjectId;

  // Estado para el script actual con detalles
  detail.ScriptDetailResponse? _currentScriptDetail;
  String? _currentScriptId;

  // Estados de carga y error
  bool _isLoading = false;
  bool _isLoadingScriptDetail = false;
  String? _errorMessage;

  // Getters
  List<ScriptModel> get allScripts => _allScripts;
  Map<String, List<ScriptModel>> get scriptsByProject => _scriptsByProject;
  List<ScriptModel> get currentProjectScripts => _currentProjectScripts;
  String? get currentProjectId => _currentProjectId;
  detail.ScriptDetailResponse? get currentScriptDetail => _currentScriptDetail;
  String? get currentScriptId => _currentScriptId;
  bool get isLoading => _isLoading;
  bool get isLoadingScriptDetail => _isLoadingScriptDetail;
  String? get errorMessage => _errorMessage;

  // Helper getters
  bool get hasScripts => _allScripts.isNotEmpty;
  bool get hasCurrentProjectScripts => _currentProjectScripts.isNotEmpty;
  int get scriptsCountForCurrentProject => _currentProjectScripts.length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingScriptDetail(bool loading) {
    _isLoadingScriptDetail = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtiene todos los scripts y los agrupa por proyecto
  Future<void> fetchAllScripts() async {
    _setLoading(true);
    _clearError();

    try {
      _scriptsByProject = await _scriptService.getScriptsGroupedByProject();

      // También mantenemos una lista plana de todos los scripts
      _allScripts = [];
      _scriptsByProject.values.forEach((scripts) {
        _allScripts.addAll(scripts);
      });

      // Ordenamos todos los scripts por fecha
      _allScripts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene los scripts de un proyecto específico
  Future<void> fetchScriptsForProject(String projectId) async {
    _setLoading(true);
    _clearError();
    _currentProjectId = projectId;

    try {
      _currentProjectScripts = await _scriptService.getScriptsByProject(
        projectId,
      );

      // Ordenamos por fecha de creación (más recientes primero)
      _currentProjectScripts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene el detalle completo de un script con sus assets
  Future<void> fetchScriptDetail(String scriptId) async {
    _setLoadingScriptDetail(true);
    _clearError();
    _currentScriptId = scriptId;

    try {
      _currentScriptDetail = await _scriptService.getScriptById(scriptId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoadingScriptDetail(false);
    }
  }

  /// Obtiene los scripts para un proyecto si no están cargados
  List<ScriptModel> getScriptsForProject(String projectId) {
    if (_scriptsByProject.containsKey(projectId)) {
      return _scriptsByProject[projectId]!;
    }

    // Si no están cargados, retornamos lista vacía y cargamos en background
    fetchScriptsForProject(projectId);
    return [];
  }

  /// Limpia los datos del proyecto actual
  void clearCurrentProject() {
    _currentProjectScripts = [];
    _currentProjectId = null;
    _clearError();
    notifyListeners();
  }

  /// Limpia los datos del script actual
  void clearCurrentScript() {
    _currentScriptDetail = null;
    _currentScriptId = null;
    _clearError();
    notifyListeners();
  }

  /// Limpia todos los datos
  void clearAll() {
    _allScripts = [];
    _scriptsByProject = {};
    _currentProjectScripts = [];
    _currentProjectId = null;
    _currentScriptDetail = null;
    _currentScriptId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresca los datos actuales
  Future<void> refresh() async {
    if (_currentProjectId != null) {
      await fetchScriptsForProject(_currentProjectId!);
    } else {
      await fetchAllScripts();
    }
  }

  /// Obtiene estadísticas de scripts para un proyecto
  Map<String, int> getScriptStatsForProject(String projectId) {
    final scripts = getScriptsForProject(projectId);

    int finished = 0;
    int pending = 0;
    int inProgress = 0;

    for (final script in scripts) {
      if (script.isFinished) {
        finished++;
      } else if (script.isPending) {
        pending++;
      } else if (script.isInProgress) {
        inProgress++;
      }
    }

    return {
      'total': scripts.length,
      'finished': finished,
      'pending': pending,
      'inProgress': inProgress,
    };
  }
}
