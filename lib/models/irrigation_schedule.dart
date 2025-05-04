class IrrigationScheduleModel {
  final int id;
  final DateTime scheduledAt;
  final int duration;
  final bool executed;
  final int statusId;

  IrrigationScheduleModel({
    required this.id,
    required this.scheduledAt,
    required this.duration,
    required this.executed,
    required this.statusId,
  });

  factory IrrigationScheduleModel.fromMap(Map<String, dynamic> map) {
    return IrrigationScheduleModel(
      id: map['id'],
      scheduledAt: DateTime.parse(map['scheduled_at']),
      duration: map['duration'] ?? 0,
      executed: map['executed'] ?? false,
      statusId: map['status_id'],
    );
  }
}
