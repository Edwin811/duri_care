import 'package:duri_care/models/zone/zone_model.dart';

class IoTDevice {
  final int id;
  final String name;
  final String type;
  final String status;
  final ZoneModel? zone;

  IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.zone,
  });
}
