class ZoneUserModel {
  final int id;
  final int zoneId;
  final String userId;

  ZoneUserModel({
    required this.id,
    required this.zoneId,
    required this.userId,
  });

  factory ZoneUserModel.fromMap(Map<String, dynamic> map) {
    return ZoneUserModel(
      id: map['id'],
      zoneId: map['zone_id'],
      userId: map['user_id'],
    );
  }
}
