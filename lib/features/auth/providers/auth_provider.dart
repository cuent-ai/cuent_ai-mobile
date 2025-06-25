import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token != null) {
        final userData = prefs.getString(AppConstants.userKey);
        if (userData != null) {
          final userJson = jsonDecode(userData);
          _user = UserModel.fromJson(userJson);
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      _errorMessage = 'Error al verificar autenticación';
    }
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _user = UserModel.fromJson(result['user']);
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, result['token']);
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(_user!.toJson()),
        );

        _setLoading(false);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Error al iniciar sesión';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Intenta nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(name, email, password);

      if (result['success']) {
        _user = UserModel.fromJson(result['user']);
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, result['token']);
        await prefs.setString(
          AppConstants.userKey,
          jsonEncode(_user!.toJson()),
        );

        _setLoading(false);
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Error al registrarse';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Intenta nuevamente.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);

      _user = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
    }

    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
