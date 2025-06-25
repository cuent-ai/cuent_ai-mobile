import 'package:flutter/material.dart';
import '../models/script_detail_model.dart';
import '../services/script_service.dart';

class ScriptDetailProvider with ChangeNotifier {
  ScriptDetail? _currentScript;
  bool _isLoadingScript = false;
  String? _scriptError;
  final ScriptService _scriptService = ScriptService();

  // Getters
  ScriptDetail? get currentScript => _currentScript;
  bool get isLoadingScript => _isLoadingScript;
  String? get scriptError => _scriptError;
  bool get hasCurrentScript => _currentScript != null;

  // Assets helpers
  List<ScriptAsset> get currentAssets => _currentScript?.assets ?? [];
  bool get hasAssets => currentAssets.isNotEmpty;
  int get totalAssets => currentAssets.length;
  int get finishedAssets =>
      currentAssets.where((asset) => asset.isFinished).length;
  List<ScriptAsset> get audioAssets =>
      currentAssets.where((asset) => asset.hasAudio).toList();
  List<ScriptAsset> get videoAssets =>
      currentAssets.where((asset) => asset.hasVideo).toList();

  /// Obtiene los detalles completos de un script incluyendo sus assets
  Future<void> fetchScriptDetail(String scriptId) async {
    _isLoadingScript = true;
    _scriptError = null;
    notifyListeners();

    try {
      final response = await _scriptService.getScriptById(scriptId);
      _currentScript = response.script;
      _scriptError = null;
    } catch (e) {
      _scriptError = e.toString();
      _currentScript = null;
      print('Error fetching script detail: $e');
    } finally {
      _isLoadingScript = false;
      notifyListeners();
    }
  }

  /// Limpia el script actual
  void clearCurrentScript() {
    _currentScript = null;
    _scriptError = null;
    notifyListeners();
  }

  /// Obtiene assets por tipo
  List<ScriptAsset> getAssetsByType(String type) {
    return currentAssets.where((asset) => asset.type == type).toList();
  }

  /// Obtiene assets que tienen audio
  List<ScriptAsset> getAudioAssets() {
    return currentAssets.where((asset) => asset.hasAudio).toList();
  }

  /// Obtiene assets que tienen video
  List<ScriptAsset> getVideoAssets() {
    return currentAssets.where((asset) => asset.hasVideo).toList();
  }

  /// Obtiene assets terminados
  List<ScriptAsset> getFinishedAssets() {
    return currentAssets.where((asset) => asset.isFinished).toList();
  }
}
