import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful login
    if (email == 'test@example.com' && password == '123456') {
      return {
        'success': true,
        'token': 'mock_token_123',
        'user': {
          'id': '1',
          'name': 'Usuario Test',
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        }
      };
    } else {
      return {
        'success': false,
        'message': 'Credenciales incorrectas'
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful registration
    return {
      'success': true,
      'token': 'mock_token_456',
      'user': {
        'id': '2',
        'name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
