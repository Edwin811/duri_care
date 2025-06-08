import 'package:duri_care/models/irrigation_schedule.dart';

class ZoneScheduleModel {
  final int zoneId;
  final IrrigationScheduleModel schedule;

  ZoneScheduleModel({required this.zoneId, required this.schedule});
  factory ZoneScheduleModel.fromMap(Map<String, dynamic> map) {
    final scheduleData = map['schedule'];
    if (scheduleData == null) {
      throw Exception('Schedule data is null in ZoneScheduleModel.fromMap');
    }

    return ZoneScheduleModel(
      zoneId: map['zone_id'],
      schedule: IrrigationScheduleModel.fromMap(
        scheduleData as Map<String, dynamic>,
      ),
    );
  }
}
