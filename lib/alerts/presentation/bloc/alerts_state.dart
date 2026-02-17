import '../../domain/entities/alert_entity.dart';

abstract class AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsError extends AlertsState {
  final String message;
  AlertsError(this.message);
}

class AlertsLoaded extends AlertsState {
  // REMOVED: rooms
  final String selectedDeviceId; // RENAMED
  final List<AlertEntity> alerts;

  AlertsLoaded({required this.selectedDeviceId, required this.alerts});

  AlertsLoaded copyWith({String? selectedDeviceId, List<AlertEntity>? alerts}) {
    return AlertsLoaded(
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      alerts: alerts ?? this.alerts,
    );
  }
}
