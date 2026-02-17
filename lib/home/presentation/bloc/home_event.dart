import '../../domain/entities/sensor_data_entity.dart';

abstract class HomeEvent {}

class HomeInitialLoad extends HomeEvent {}

class HomeStopPolling extends HomeEvent {}

class HomeDeviceChanged extends HomeEvent {
  final String deviceId;
  HomeDeviceChanged(this.deviceId);
}

class HomeDataUpdated extends HomeEvent {
  final SensorData data;
  HomeDataUpdated(this.data);
}
