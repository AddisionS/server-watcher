import 'dart:async';
import 'dart:math';
import '../models/sensor_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<String>> fetchRooms();
  Stream<SensorModel> getSensorStream(String room);
}

class HomeMockDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<String>> fetchRooms() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      'AB1 room 001',
      'Administrative Block',
      'AB2 room 002',
      'AB3 room 003',
    ];
  }

  @override
  Stream<SensorModel> getSensorStream(String room) {
    // This creates a stream that "ticks" every 2 seconds
    return Stream.periodic(const Duration(seconds: 2), (_) {
      final random = Random();

      // Simulate different data based on room
      // Server Room is hotter!
      double baseTemp = room == 'Server Room' ? 25.0 : 20.0;

      return SensorModel(
        timestamp: DateTime.now(),
        // Random temp between baseTemp and baseTemp + 5
        temperature: baseTemp + random.nextDouble() * 5,
        // Random humidity between 40% and 60%
        humidity: 40.0 + random.nextDouble() * 20,
      );
    });
  }
}
