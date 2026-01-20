import '../../domain/entities/sensor_data_entity.dart';
import '../../../config/domain/entities/config_entities.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final List<String> rooms; //
  final String selectedRoom; //
  final List<SensorData> sensorData; // [Point1, Point2, Point3...]
  final ThresholdsEntity thresholds;

  HomeLoaded({
    required this.rooms,
    required this.selectedRoom,
    required this.sensorData,
    required this.thresholds,
  });

  // Helper to update specific fields easily
  HomeLoaded copyWith({
    List<String>? rooms,
    String? selectedRoom,
    List<SensorData>? sensorData,
    ThresholdsEntity? thresholds,
  }) {
    return HomeLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      sensorData: sensorData ?? this.sensorData,
      thresholds: thresholds ?? this.thresholds,
    );
  }
}
