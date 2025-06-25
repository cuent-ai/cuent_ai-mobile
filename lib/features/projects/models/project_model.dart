class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String cuentokens;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cuentokens,
    required this.state,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
