class SensorDataModel {
  final int id;
  final int deviceId;
  final int soilMoisture;
  final int airTemperature;
  final int airHumidity;
  final int rainfallIntensity;
  final DateTime createdAt;

  SensorDataModel({
    required this.id,
    required this.deviceId,
    required this.soilMoisture,
    required this.airTemperature,
    required this.airHumidity,
    required this.rainfallIntensity,
    required this.createdAt,
  });

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'],
      deviceId: map['device_id'],
      soilMoisture: map['soil_moisture'],
      airTemperature: map['air_temperature'],
      airHumidity: map['air_humidity'],
      rainfallIntensity: map['rainfall_intensity'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
