import '../../domain/entities/sensor_data_entity.dart';
import '../../../config/domain/entities/config_entities.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  // REMOVED: final List<String> rooms;

  final String selectedDeviceId; // RENAMED
  final List<SensorData> sensorData;
  final ThresholdsEntity thresholds;

  HomeLoaded({
    required this.selectedDeviceId,
    required this.sensorData,
    required this.thresholds,
  });

  HomeLoaded copyWith({
    String? selectedDeviceId,
    List<SensorData>? sensorData,
    ThresholdsEntity? thresholds,
  }) {
    return HomeLoaded(
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      sensorData: sensorData ?? this.sensorData,
      thresholds: thresholds ?? this.thresholds,
    );
  }
}
