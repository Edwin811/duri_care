class ZoneModel {
  final int id;
  final int zoneCode;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final int? deletedAt;

  ZoneModel({
    required this.id,
    required this.zoneCode,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.deletedAt,
  });

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      zoneCode: map['zone_code'],
      name: map['name'],
      isActive: map['isActive'],
      createdAt: DateTime.parse(map['created_at']),
      deletedAt: map['deleted_at'],
    );
  }
}
