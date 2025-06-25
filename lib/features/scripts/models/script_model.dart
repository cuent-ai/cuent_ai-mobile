class ScriptModel {
  final String id;
  final String projectId;
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

  ScriptModel({
    required this.id,
    required this.projectId,
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

  factory ScriptModel.fromJson(Map<String, dynamic> json) {
    return ScriptModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
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
      'project_id': projectId,
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

class ScriptsResponse {
  final List<ScriptModel> data;
  final int total;
  final int limit;
  final int offset;
  final int pages;

  ScriptsResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
    required this.pages,
  });

  factory ScriptsResponse.fromJson(Map<String, dynamic> json) {
    return ScriptsResponse(
      data:
          (json['data'] as List)
              .map((script) => ScriptModel.fromJson(script))
              .toList(),
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 10,
      offset: json['offset'] ?? 0,
      pages: json['pages'] ?? 1,
    );
  }
}

// Modelo para un solo script con detalles completos incluyendo assets
class ScriptDetailResponse {
  final ScriptModel script;
  final List<ScriptAsset> assets;
  final String message;

  ScriptDetailResponse({
    required this.script,
    required this.assets,
    required this.message,
  });

  factory ScriptDetailResponse.fromJson(Map<String, dynamic> json) {
    final scriptData = json['data'];
    return ScriptDetailResponse(
      script: ScriptModel.fromJson(scriptData),
      assets:
          (scriptData['assets'] as List? ?? [])
              .map((asset) => ScriptAsset.fromJson(asset))
              .toList(),
      message: json['message'] ?? '',
    );
  }
}

// Modelo para los assets dentro de un script
class ScriptAsset {
  final String id;
  final String type;
  final String videoUrl;
  final String audioUrl;
  final String line;
  final String audioState;
  final String videoState;
  final double duration;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScriptAsset({
    required this.id,
    required this.type,
    required this.videoUrl,
    required this.audioUrl,
    required this.line,
    required this.audioState,
    required this.videoState,
    required this.duration,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScriptAsset.fromJson(Map<String, dynamic> json) {
    return ScriptAsset(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      videoUrl: json['video_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      line: json['line'] ?? '',
      audioState: json['audio_state'] ?? '',
      videoState: json['video_state'] ?? '',
      duration: (json['duration'] ?? 0.0).toDouble(),
      position: json['position'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Helper getters
  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasAudio => audioUrl.isNotEmpty;
  bool get isVideoReady => videoState == 'FINISHED';
  bool get isAudioReady => audioState == 'FINISHED';
  bool get isFinished => audioState == 'FINISHED' && videoState == 'FINISHED';
}
