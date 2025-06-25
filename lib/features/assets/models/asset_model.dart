class AssetModel {
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

  AssetModel({
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

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      type: json['type'],
      videoUrl: json['video_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      line: json['line'],
      audioState: json['audio_state'],
      videoState: json['video_state'],
      duration: (json['duration'] as num).toDouble(),
      position: json['position'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasAudio => audioUrl.isNotEmpty;
  bool get isVideoReady => videoState == 'FINISHED';
  bool get isAudioReady => audioState == 'FINISHED';
}

class AssetsResponse {
  final List<AssetModel> data;
  final int total;
  final int limit;
  final int offset;
  final int pages;

  AssetsResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
    required this.pages,
  });

  factory AssetsResponse.fromJson(Map<String, dynamic> json) {
    return AssetsResponse(
      data:
          (json['data'] as List)
              .map((asset) => AssetModel.fromJson(asset))
              .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      pages: json['pages'],
    );
  }
}
