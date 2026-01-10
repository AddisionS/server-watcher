import '../../domain/entities/sensor_data_entity.dart';

abstract class HomeEvent {}

class HomeInitialLoad extends HomeEvent {}

class HomeRoomChanged extends HomeEvent {
  final String room;
  HomeRoomChanged(this.room);
}

// This event is triggered internally by the BLoC when the stream gives data
class HomeDataUpdated extends HomeEvent {
  final SensorData data;
  HomeDataUpdated(this.data);
}
