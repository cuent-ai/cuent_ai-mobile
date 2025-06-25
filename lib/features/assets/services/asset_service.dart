import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asset_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/token_manager.dart';

class AssetService {
  static const String assetsEndpoint = '/assets';

  Future<AssetsResponse> getAssets({
    String? projectId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      // Get the token from storage
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = <String, String>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      // Add project_id if provided
      if (projectId != null) {
        queryParams['project_id'] = projectId;
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}$assetsEndpoint',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AssetsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }
}
