import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  final String deviceId;
  final String deviceName;

  AlertModel({
    required super.timestamp,
    required super.temperature,
    required super.humidity,
    required super.message,
    required this.deviceId,
    required this.deviceName,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final utcTime = DateTime.parse(json['time']).toUtc();
    final istTime = utcTime.add(const Duration(hours: 5, minutes: 30));

    final temp = (json['temperature'] as num).toDouble();
    final hum = (json['humidity'] as num).toDouble();

    return AlertModel(
      timestamp: istTime,
      temperature: temp,
      humidity: hum,
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? 'Unknown',
      message:
          'Alert: ${temp.toStringAsFixed(1)}°C / ${hum.toStringAsFixed(1)}% humidity',
    );
  }
}
