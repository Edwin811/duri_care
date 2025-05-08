class ZoneModel {
  final int id;
  final String name;
  final bool isActive;
  final int zoneCode;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  ZoneModel({
    required this.id,
    required this.name,
    required this.isActive,
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
    );
  }

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'] ?? 'Unknown Zone',
      isActive: map['is_active'] ?? false,
      zoneCode: map['zone_code'] ?? 0,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_active': isActive,
    'zone_code': zoneCode,
  };
}
