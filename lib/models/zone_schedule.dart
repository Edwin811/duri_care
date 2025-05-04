import 'package:duri_care/models/irrigation_schedule.dart';

class ZoneScheduleModel {
  final int id;
  final int zoneId;
  final IrrigationScheduleModel schedule;

  ZoneScheduleModel({
    required this.id,
    required this.zoneId,
    required this.schedule,
  });

  factory ZoneScheduleModel.fromMap(Map<String, dynamic> map) {
    return ZoneScheduleModel(
      id: map['id'],
      zoneId: map['zone_id'],
      schedule: IrrigationScheduleModel.fromMap(map['schedule']),
    );
  }
}
