import 'dart:math';
import '../../../../home/data/models/sensor_model.dart'; // Reuse Model

abstract class HistoryRemoteDataSource {
  Future<List<SensorModel>> fetchHistory(String room);
}

class HistoryMockDataSourceImpl implements HistoryRemoteDataSource {
  @override
  Future<List<SensorModel>> fetchHistory(String room) async {
    // 1. Simulate HTTPS Latency (Network Call)
    await Future.delayed(const Duration(seconds: 1));

    final List<SensorModel> history = [];
    final random = Random();
    final now = DateTime.now();

    // 2. Logic: Generate 24 hours of data
    // We assume the backend gives us 1 point every 15 minutes (Moving Average)
    // 24 hours * 4 points/hour = 96 points
    for (int i = 0; i < 96; i++) {
      // Calculate time going backwards (0 mins, 15 mins ago, 30 mins ago...)
      final timestamp = now.subtract(Duration(minutes: i * 15));

      // Simulate Temperature Logic
      // Server room is hotter (25-30), others cooler (20-25)
      // We add sine wave math to simulate day/night cycle for realism
      double baseTemp = room == 'Server Room' ? 28.0 : 22.0;
      double dayNightVariance =
          sin(i / 10) * 2; // Temperature fluctuates over time

      history.add(
        SensorModel(
          timestamp: timestamp,
          temperature: baseTemp + dayNightVariance + random.nextDouble(),
          humidity: 50.0 + random.nextDouble() * 10,
        ),
      );
    }

    return history;
  }
}
