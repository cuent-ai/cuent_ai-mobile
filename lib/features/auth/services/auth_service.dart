import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/token_manager.dart';
import '../../../core/utils/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiClient.post(AppConstants.loginEndpoint, {
        'email': email.trim(),
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful login
        final token = data['access_token'] ?? data['token'];
        if (token != null) {
          await TokenManager.saveToken(token);
        }

        return {
          'success': true,
          'token': token,
          'user': {
            'id':
                data['user']?['id']?.toString() ?? data['id']?.toString() ?? '',
            'name': data['user']?['name'] ?? data['name'] ?? '',
            'email': data['user']?['email'] ?? data['email'] ?? email,
            'created_at':
                data['user']?['created_at'] ??
                data['created_at'] ??
                DateTime.now().toIso8601String(),
          },
        };
      } else {
        // Error response
        String errorMessage = 'Credenciales incorrectas';

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.post(AppConstants.registerEndpoint, {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration
        final token = data['access_token'] ?? data['token'];
        if (token != null) {
          await TokenManager.saveToken(token);
        }

        return {
          'success': true,
          'token': token,
          'user': {
            'id':
                data['user']?['id']?.toString() ?? data['id']?.toString() ?? '',
            'name': data['user']?['name'] ?? data['name'] ?? name,
            'email': data['user']?['email'] ?? data['email'] ?? email,
            'created_at':
                data['user']?['created_at'] ??
                data['created_at'] ??
                DateTime.now().toIso8601String(),
          },
        };
      } else {
        // Error response
        String errorMessage = 'Error al crear la cuenta';

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? data['error'] ?? errorMessage;
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Register error: $e'); // Debug log
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Tiempo de espera agotado. Verifica tu conexión.';
    } else if (error.toString().contains('SocketException')) {
      return 'Sin conexión a internet. Verifica tu red.';
    }
    return 'Error de conexión. Intenta nuevamente.';
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
