import '../../domain/entities/sensor_data_entity.dart';

class SensorModel extends SensorData {
  SensorModel({
    required super.timestamp,
    required super.temperature,
    required super.humidity,
  });

  // Factory to create from JSON (Good practice for later)
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
    );
  }
}
