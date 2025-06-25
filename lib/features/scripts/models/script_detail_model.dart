// Modelo para los assets de un script individual
class ScriptAsset {
  final String id;
  final String type;
  final String? videoUrl;
  final String? audioUrl;
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
    this.videoUrl,
    this.audioUrl,
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
      videoUrl:
          json['video_url']?.isNotEmpty == true ? json['video_url'] : null,
      audioUrl:
          json['audio_url']?.isNotEmpty == true ? json['audio_url'] : null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'line': line,
      'audio_state': audioState,
      'video_state': videoState,
      'duration': duration,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get isFinished => audioState == 'FINISHED' && videoState == 'FINISHED';
  bool get isAudioFinished => audioState == 'FINISHED';
  bool get isVideoFinished => videoState == 'FINISHED';
  bool get isTTS => type == 'TTS';
  String get displayDuration {
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Modelo para script individual con detalles completos
class ScriptDetail {
  final String id;
  final int promptTokens;
  final int completionTokens;
  final int totalToken;
  final int totalCuentoken;
  final String state;
  final String textEntry;
  final String processedText;
  final String? mixedAudio;
  final String? mixedMedia;
  final List<ScriptAsset> assets;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScriptDetail({
    required this.id,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalToken,
    required this.totalCuentoken,
    required this.state,
    required this.textEntry,
    required this.processedText,
    this.mixedAudio,
    this.mixedMedia,
    required this.assets,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScriptDetail.fromJson(Map<String, dynamic> json) {
    return ScriptDetail(
      id: json['id'] ?? '',
      promptTokens: json['promt_tokens'] ?? 0, // Note: API has typo "promt"
      completionTokens: json['completion_tokens'] ?? 0,
      totalToken: json['total_token'] ?? 0,
      totalCuentoken: json['total_cuentoken'] ?? 0,
      state: json['state'] ?? '',
      textEntry: json['text_entry'] ?? '',
      processedText: json['processed_text'] ?? '',
      mixedAudio:
          json['mixed_audio']?.isNotEmpty == true ? json['mixed_audio'] : null,
      mixedMedia:
          json['mixed_media']?.isNotEmpty == true ? json['mixed_media'] : null,
      assets:
          json['assets'] != null
              ? (json['assets'] as List)
                  .map((asset) => ScriptAsset.fromJson(asset))
                  .toList()
              : [],
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
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isFinished => state == 'FINISHED';
  bool get isPending => state == 'PENDING';
  bool get isInProgress => state == 'IN_PROGRESS';
  bool get hasMixedAudio => mixedAudio != null && mixedAudio!.isNotEmpty;
  bool get hasMixedMedia => mixedMedia != null && mixedMedia!.isNotEmpty;
  bool get hasAssets => assets.isNotEmpty;
  int get totalAssets => assets.length;
  int get finishedAssets => assets.where((asset) => asset.isFinished).length;
  List<ScriptAsset> get audioAssets =>
      assets.where((asset) => asset.hasAudio).toList();
  List<ScriptAsset> get videoAssets =>
      assets.where((asset) => asset.hasVideo).toList();
  String get displayText => textEntry.isNotEmpty ? textEntry : processedText;
}

// Modelo para respuesta de script individual
class ScriptDetailResponse {
  final ScriptDetail script;
  final String message;

  ScriptDetailResponse({required this.script, required this.message});

  factory ScriptDetailResponse.fromJson(Map<String, dynamic> json) {
    return ScriptDetailResponse(
      script: ScriptDetail.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}
