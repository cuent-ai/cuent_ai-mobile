import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/token_manager.dart';

class ProjectService {
  static const String projectsEndpoint = '/projects';

  Future<ProjectsResponse> getProjects() async {
    try {
      // Get the token from storage
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$projectsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProjectsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }
}
