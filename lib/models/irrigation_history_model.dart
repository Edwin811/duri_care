class IrrigationHistoryModel {
  final int id;
  final int zoneId;
  final String executedBy;
  final DateTime startedAt;
  final int duration;
  final String type;
  final String message;
  final DateTime createdAt;

  IrrigationHistoryModel({
    required this.id,
    required this.zoneId,
    required this.executedBy,
    required this.startedAt,
    required this.duration,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory IrrigationHistoryModel.fromMap(Map<String, dynamic> map) {
    return IrrigationHistoryModel(
      id: map['id'],
      zoneId: map['zone_id'],
      executedBy: map['executed_by'],
      startedAt: DateTime.parse(map['started_at']),
      duration: map['duration'],
      type: map['type'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
