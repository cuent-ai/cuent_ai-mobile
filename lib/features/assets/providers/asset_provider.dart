import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import '../services/asset_service.dart';

class AssetProvider extends ChangeNotifier {
  final AssetService _assetService = AssetService();

  List<AssetModel> _assets = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;
  String? _currentProjectId;

  List<AssetModel> get assets => _assets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _currentPage < _totalPages - 1;
  String? get currentProjectId => _currentProjectId;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchAssets({required String projectId, int offset = 0}) async {
    _setLoading(true);
    _clearError();
    _currentProjectId = projectId;

    try {
      final assetsResponse = await _assetService.getAssets(
        projectId: projectId,
        offset: offset,
      );
      _assets = assetsResponse.data;
      _currentPage = offset ~/ 10; // Assuming limit is 10
      _totalPages = assetsResponse.pages;

      // Sort assets by position
      _assets.sort((a, b) => a.position.compareTo(b.position));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNextPage() async {
    if (hasNextPage && !_isLoading && _currentProjectId != null) {
      final nextOffset = (_currentPage + 1) * 10;
      await fetchAssets(projectId: _currentProjectId!, offset: nextOffset);
    }
  }

  Future<void> loadPreviousPage() async {
    if (_currentPage > 0 && !_isLoading && _currentProjectId != null) {
      final prevOffset = (_currentPage - 1) * 10;
      await fetchAssets(projectId: _currentProjectId!, offset: prevOffset);
    }
  }

  void clearAssets() {
    _assets = [];
    _errorMessage = null;
    _currentProjectId = null;
    _currentPage = 0;
    _totalPages = 1;
    notifyListeners();
  }
}
