import 'dart:convert';
import 'package:http/http.dart' as http;

// Debug utility to test your backend API directly
class ApiTestUtil {
  static const String baseUrl =
      'https://cuent-ai-core-326160083778.us-central1.run.app/api/v1';

  // Test login with admin credentials
  static Future<void> testLogin() async {
    print('🔄 Testing login...');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@gmail.com',
          'password': 'changeme123',
        }),
      );

      print('📄 Login Response Status: ${response.statusCode}');
      print('📄 Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Login successful!');
        print('🔑 Token: ${data['access_token'] ?? data['token']}');
        print('👤 User: ${data['user'] ?? data}');
      } else {
        print('❌ Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Login error: $e');
    }
  }

  // Test registration with new user
  static Future<void> testRegister() async {
    print('🔄 Testing registration...');
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.post(
        Uri.parse('$baseUrl/users/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Test User $timestamp',
          'email': 'testuser$timestamp@gmail.com',
          'password': 'changeme123',
        }),
      );

      print('📄 Register Response Status: ${response.statusCode}');
      print('📄 Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Registration successful!');
        print('🔑 Token: ${data['access_token'] ?? data['token']}');
        print('👤 User: ${data['user'] ?? data}');
      } else {
        print('❌ Registration failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Registration error: $e');
    }
  }

  // Test API connectivity
  static Future<void> testConnectivity() async {
    print('🔄 Testing API connectivity...');
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📄 Connectivity Status: ${response.statusCode}');
      print('✅ API is reachable!');
    } catch (e) {
      print('❌ API connectivity error: $e');
    }
  }
}

// To test, add this to any widget's initState or button onPressed:
// ApiTestUtil.testConnectivity();
// ApiTestUtil.testLogin();
// ApiTestUtil.testRegister();
