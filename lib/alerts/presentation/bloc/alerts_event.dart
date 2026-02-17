abstract class AlertsEvent {}

class AlertsInitialLoad extends AlertsEvent {}

class AlertsDeviceChanged extends AlertsEvent {
  final String deviceId;
  AlertsDeviceChanged(this.deviceId);
}
