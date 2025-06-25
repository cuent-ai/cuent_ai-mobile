import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    return await http
        .post(
          url,
          headers: {'Content-Type': 'application/json', ...?headers},
          body: jsonEncode(body),
        )
        .timeout(timeoutDuration);
  }

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

    return await http
        .get(url, headers: {'Content-Type': 'application/json', ...?headers})
        .timeout(timeoutDuration);
  }
}
