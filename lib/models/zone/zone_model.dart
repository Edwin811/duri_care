class ZoneModel {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  ZoneModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
