import 'package:duri_care/models/zone_model.dart';

class IotDeviceModel {
  final int id;
  final int? zoneId;
  final int iotCode;
  final String name;
  final String? type;
  final String? status;
  final ZoneModel? zone;

  IotDeviceModel({
    required this.id,
    this.zoneId,
    required this.iotCode,
    required this.name,
    this.type,
    this.status,
    this.zone,
  });

  factory IotDeviceModel.fromMap(Map<String, dynamic> map) {
    return IotDeviceModel(
      id: map['id'],
      zoneId: map['zone_id'],
      iotCode: map['iot_code'] ?? map['code'] ?? 0,
      name: map['name'] ?? 'Unknown Device',
      type: map['type'],
      status: map['status'],
      zone: map['zone'] != null ? ZoneModel.fromMap(map['zone']) : null,
    );
  }
}
