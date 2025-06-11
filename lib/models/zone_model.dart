class ZoneModel {
  final int id;
  final String name;
  final bool isActive;
  final int zoneCode;
  final int duration;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  ZoneModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.duration,
    required this.zoneCode,
    this.createdAt,
    this.deletedAt,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      zoneCode: json['zone_code'],
      duration: json['duration'],
    );
  }
  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'] is String ? int.parse(map['id']) : (map['id'] as int? ?? 0),
      name: map['name'] ?? '',
      isActive: map['is_active'] ?? false,
      zoneCode:
          map['zone_code'] is String
              ? int.parse(map['zone_code'])
              : (map['zone_code'] as int? ?? 1),
      duration:
          map['manual_duration'] is String
              ? int.parse(map['manual_duration'])
              : (map['manual_duration'] as int? ?? 5),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'is_active': isActive,
    'zone_code': zoneCode,
    'duration': duration,
    'created_at': createdAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
