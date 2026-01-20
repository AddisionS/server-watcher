import 'dart:math';
import '../../domain/entities/alert_entity.dart'; // We can use Entity directly for mocks to save time

abstract class AlertsRemoteDataSource {
  Future<List<AlertEntity>> fetchAlerts(String room);
}

class AlertsMockDataSourceImpl implements AlertsRemoteDataSource {
  @override
  Future<List<AlertEntity>> fetchAlerts(String room) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate HTTP

    final List<AlertEntity> alerts = [];
    final now = DateTime.now();
    final random = Random();

    // Generate 10 fake alerts over the last few days
    for (int i = 0; i < 10; i++) {
      // Logic: Random times in the past 48 hours
      final timestamp = now.subtract(Duration(hours: random.nextInt(48)));

      // Simulate High Temp (> 30)
      double temp = 30.0 + random.nextDouble() * 5;
      double hum = 50.0;

      alerts.add(
        AlertEntity(
          timestamp: timestamp,
          temperature: temp,
          humidity: hum,
          message: "Critical Threshold Breached: > 30°C",
        ),
      );
    }

    // Sort by newest first
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return alerts;
  }
}
