import '../../domain/entities/sensor_data_entity.dart';

class SensorModel extends SensorData {
  SensorModel({
    required super.timestamp,
    required super.temperature,
    required super.humidity,
  });

  // Factory to create from JSON (Good practice for later)
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    final utcTime = DateTime.parse(json['timestamp']).toUtc();
    final istTime = DateTime.fromMillisecondsSinceEpoch(
      utcTime.add(const Duration(hours: 5, minutes: 30)).millisecondsSinceEpoch,
    );

    return SensorModel(
      timestamp: istTime,
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
    );
  }
}
