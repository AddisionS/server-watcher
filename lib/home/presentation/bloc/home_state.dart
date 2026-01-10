import '../../domain/entities/sensor_data_entity.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final List<String> rooms; // ["Kitchen", "Server"]
  final String selectedRoom; // "Kitchen"
  final List<SensorData> sensorData; // [Point1, Point2, Point3...]

  HomeLoaded({
    required this.rooms,
    required this.selectedRoom,
    required this.sensorData,
  });

  // Helper to update specific fields easily
  HomeLoaded copyWith({
    List<String>? rooms,
    String? selectedRoom,
    List<SensorData>? sensorData,
  }) {
    return HomeLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      sensorData: sensorData ?? this.sensorData,
    );
  }
}
