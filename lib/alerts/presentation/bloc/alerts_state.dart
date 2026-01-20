import '../../domain/entities/alert_entity.dart';

abstract class AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsError extends AlertsState {
  final String message;
  AlertsError(this.message);
}

class AlertsLoaded extends AlertsState {
  final List<String> rooms;
  final String selectedRoom;
  final List<AlertEntity> alerts;

  AlertsLoaded({
    required this.rooms,
    required this.selectedRoom,
    required this.alerts,
  });

  AlertsLoaded copyWith({
    List<String>? rooms,
    String? selectedRoom,
    List<AlertEntity>? alerts,
  }) {
    return AlertsLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      alerts: alerts ?? this.alerts,
    );
  }
}
