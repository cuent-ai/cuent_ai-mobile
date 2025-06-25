class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String cuentokens;
  final String state;
  final List<ProjectScript>? scripts; // Nueva propiedad opcional para scripts
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cuentokens,
    required this.state,
    this.scripts, // Opcional
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cuentokens: json['cuentokens'] ?? '',
      state: json['state'],
      scripts:
          json['scripts'] != null
              ? (json['scripts'] as List)
                  .map((script) => ProjectScript.fromJson(script))
                  .toList()
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cuentokens': cuentokens,
      'state': state,
      'scripts': scripts?.map((script) => script.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get hasScripts => scripts != null && scripts!.isNotEmpty;
  int get scriptsCount => scripts?.length ?? 0;
}

// Modelo para los scripts que vienen dentro del proyecto
class ProjectScript {
  final String id;
  final int promptTokens;
  final int completionTokens;
  final int totalToken;
  final int totalCuentoken;
  final String state;
  final String textEntry;
  final String processedText;
  final String mixedAudio;
  final String mixedMedia;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectScript({
    required this.id,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalToken,
    required this.totalCuentoken,
    required this.state,
    required this.textEntry,
    required this.processedText,
    required this.mixedAudio,
    required this.mixedMedia,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectScript.fromJson(Map<String, dynamic> json) {
    return ProjectScript(
      id: json['id'] ?? '',
      promptTokens: json['promt_tokens'] ?? 0, // Note: API has typo "promt"
      completionTokens: json['completion_tokens'] ?? 0,
      totalToken: json['total_token'] ?? 0,
      totalCuentoken: json['total_cuentoken'] ?? 0,
      state: json['state'] ?? '',
      textEntry: json['text_entry'] ?? '',
      processedText: json['processed_text'] ?? '',
      mixedAudio: json['mixed_audio'] ?? '',
      mixedMedia: json['mixed_media'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_token': totalToken,
      'total_cuentoken': totalCuentoken,
      'state': state,
      'text_entry': textEntry,
      'processed_text': processedText,
      'mixed_audio': mixedAudio,
      'mixed_media': mixedMedia,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isFinished => state == 'FINISHED';
  bool get isPending => state == 'PENDING';
  bool get isInProgress => state == 'IN_PROGRESS';
  bool get hasMixedAudio => mixedAudio.isNotEmpty;
  bool get hasMixedMedia => mixedMedia.isNotEmpty;
  String get displayText => textEntry.isNotEmpty ? textEntry : processedText;
}

// Modelo para respuesta de proyecto individual con detalles
class ProjectDetailResponse {
  final ProjectModel project;
  final String message;

  ProjectDetailResponse({required this.project, required this.message});

  factory ProjectDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponse(
      project: ProjectModel.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}

class ProjectsResponse {
  final List<ProjectModel> data;
  final int total;
  final int limit;
  final int offset;
  final int pages;

  ProjectsResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
    required this.pages,
  });

  factory ProjectsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectsResponse(
      data:
          (json['data'] as List)
              .map((project) => ProjectModel.fromJson(project))
              .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      pages: json['pages'],
    );
  }
}
