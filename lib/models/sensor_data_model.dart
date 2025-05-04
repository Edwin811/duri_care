class SensorDataModel {
  final int id;
  final int deviceId;
  final double soilMoisture;
  final double humidity;
  final bool isRaining;
  final DateTime createdAt;

  SensorDataModel({
    required this.id,
    required this.deviceId,
    required this.soilMoisture,
    required this.humidity,
    required this.isRaining,
    required this.createdAt,
  });

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'],
      deviceId: map['device_id'],
      soilMoisture: (map['soil_moisture'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      isRaining: map['is_raining'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
