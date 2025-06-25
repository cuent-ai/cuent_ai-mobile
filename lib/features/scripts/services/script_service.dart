import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/script_model.dart';
import '../models/script_detail_model.dart'
    as detail; // Alias para evitar conflictos
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/token_manager.dart';

class ScriptService {
  static const String scriptsEndpoint = '/scripts';

  /// Obtiene todos los scripts sin filtrar por proyecto
  Future<ScriptsResponse> getAllScripts({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${AppConstants.baseUrl}$scriptsEndpoint').replace(
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ScriptsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load scripts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching scripts: $e');
    }
  }

  /// Obtiene los scripts de un proyecto específico
  Future<List<ScriptModel>> getScriptsByProject(String projectId) async {
    try {
      // Primero obtenemos todos los scripts
      final allScriptsResponse = await getAllScripts(
        limit: 100,
      ); // Aumentamos el límite para obtener más scripts

      // Filtramos por proyecto
      final projectScripts =
          allScriptsResponse.data
              .where((script) => script.projectId == projectId)
              .toList();

      return projectScripts;
    } catch (e) {
      throw Exception('Error fetching scripts for project: $e');
    }
  }

  /// Obtiene un script específico por ID con todos sus detalles y assets
  Future<detail.ScriptDetailResponse> getScriptById(String scriptId) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}$scriptsEndpoint/$scriptId',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return detail.ScriptDetailResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load script details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching script details: $e');
    }
  }

  /// Agrupa todos los scripts por proyecto
  Future<Map<String, List<ScriptModel>>> getScriptsGroupedByProject() async {
    try {
      final allScriptsResponse = await getAllScripts(
        limit: 1000,
      ); // Obtenemos muchos scripts
      final Map<String, List<ScriptModel>> groupedScripts = {};

      for (final script in allScriptsResponse.data) {
        if (script.projectId.isNotEmpty) {
          if (!groupedScripts.containsKey(script.projectId)) {
            groupedScripts[script.projectId] = [];
          }
          groupedScripts[script.projectId]!.add(script);
        }
      }

      // Ordenamos los scripts por fecha de creación dentro de cada proyecto
      groupedScripts.forEach((projectId, scripts) {
        scripts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });

      return groupedScripts;
    } catch (e) {
      throw Exception('Error grouping scripts by project: $e');
    }
  }
}
